import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';


class GeminiClient {
  static const _modelName = 'gemini-3.5-flash';
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  static Future<String> getChatBotResponse(
    String userPrompt,
    List<ChatMessage> historyPrompts,
  ) async {
    if (_apiKey.isEmpty || _apiKey == 'MY_GEMINI_API_KEY') {
      await Future.delayed(const Duration(milliseconds: 700));
      return _fallbackReply(userPrompt);
    }

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 60);

    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent?key=$_apiKey',
      );
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(_requestBody(userPrompt, historyPrompts)));

      final response = await request.close().timeout(
        const Duration(seconds: 60),
      );
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return 'Tôi gặp chút gián đoạn kết nối. Bạn vui lòng hỏi lại để SportZone Bot hỗ trợ nhé!';
      }

      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List<dynamic>?;
      final content = candidates?.isNotEmpty == true
          ? candidates!.first['content'] as Map<String, dynamic>?
          : null;
      final parts = content?['parts'] as List<dynamic>?;
      final text = parts?.isNotEmpty == true
          ? parts!.first['text'] as String?
          : null;

      return text?.trim().isNotEmpty == true
          ? text!.trim()
          : 'Hệ thống hỗ trợ bận một chút, vui lòng nhắn lại giúp tôi nhé!';
    } catch (_) {
      return 'Chào bạn! Có vẻ mạng đang trễ. Về size giày Nike Dunk Low, form này ôm nhẹ nên nếu chân dày, bạn hãy cân nhắc tăng thêm 0.5 hoặc 1 size nhé.';
    } finally {
      client.close(force: true);
    }
  }

  static Map<String, dynamic> _requestBody(
    String userPrompt,
    List<ChatMessage> historyPrompts,
  ) {
    final contents = historyPrompts
        .map(
          (message) => {
            'role': message.isUser ? 'user' : 'model',
            'parts': [
              {'text': message.message},
            ],
          },
        )
        .toList();

    contents.add({
      'role': 'user',
      'parts': [
        {'text': userPrompt},
      ],
    });

    return {
      'contents': contents,
      'systemInstruction': {
        'parts': [
          {
            'text':
                'You are SportZone Bot, an expert AI assistant for SportZone, a premium sports fashion and sneaker retailer. '
                'Respond in Vietnamese. Be concise, helpful, professional, sporty, and use a friendly retail advisor tone. '
                'You know these SportZone products: Nike Air Zoom giá 3.500.000đ, Pegasus 40 giá 2.800.000đ, '
                'Nike Dunk Low Retro giá 2.990.000đ, Adidas Jersey 23/24 giá 1.950.000đ, Giày Nitro Elite v2 giá 3.120.000đ, '
                'Quần Short Chạy Bộ Pro giá 850.000đ. Recommend sizes: 38 is 23.5cm, 39 is 24cm, 40 is 25cm, '
                '41 is 26cm, 42 is 27cm. Encourage purchasing from SportZone.',
          },
        ],
      },
    };
  }

  static String _fallbackReply(String userMessage) {
    final lower = userMessage.toLowerCase();
    if (lower.contains('nike') || lower.contains('size')) {
      return 'Với Nike Dunk Low, bạn nên tăng 0.5 đến 1 size nếu chân dày. Ví dụ size 40 hoặc 41 nếu chân bạn dài 25cm.';
    }
    if (lower.contains('adidas')) {
      return 'Áo đấu sân nhà 23/24 rất thoáng khí và phù hợp cho hoạt động ngoài trời, bạn có thể chọn size vừa với vòng ngực.';
    }
    return 'Chào bạn! SportZone gợi ý bạn chọn sản phẩm phù hợp với phong cách tập luyện và kích cỡ hiện tại của bạn. Bạn cần tư vấn sản phẩm nào?';
  }
}

