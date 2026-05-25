import 'package:google_generative_ai/google_generative_ai.dart';
import 'database.dart';

class GeminiService {
  static const String fallbackResponse =
      "Xin chào! Trợ lý AI đang chạy ở chế độ hồi đáp mẫu (do khóa API Key chưa được bổ sung vào Secrets). \n\n"
      "Để nhận tư vấn thể hình & khuyến mãi tự động 100% bằng AI, bạn hãy thêm khóa 'GEMINI_API_KEY' vào môi trường biên dịch của Flutter nhé! \n\n"
      "Hôm nay, bạn muốn tìm Whey Isolate phục hồi cơ bắp hay Kettlebell tập tại nhà thế? 💪🏋️‍♂️";

  static const String apiErrorResponse =
      "Hệ thống AI Aero đang tạm nghỉ mệt uống nước whey một lát nha! Bạn vui lòng nhắn lại sau 1 phút nha! 💪⚡ (Server response error)";

  static const String networkErrorResponse =
      "Kết nối của bạn đang không tốt lắm, hoặc mạng bận rồi! Đừng lo lắng, hãy kiểm tra lại kết nối và nhắn lại sau nha! 🏃‍♂️💨";

  static Future<String> getChatResponse(
    String userPrompt,
    List<ChatMessage> history,
    String apiKey,
  ) async {
    if (apiKey.isEmpty || apiKey == "MY_GEMINI_API_KEY") {
      return fallbackResponse;
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-3.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system('''
You are 'Aero', the high-energy, friendly fitness/sports AI customer helper for the 'AeroSport Shop'.
The AeroSport shop sells premium fitness products:
1. Aero Pro Whey Isolate (\$49.99, organic grass-fed whey isolate, flavors: Double Dark Chocolate, Vanilla Bean)
2. Pre-Workout Ignition (\$29.99, cosmic blue raspberry, training focus booster)
3. AeroGrip Performance Gloves (\$19.99, mesh nylon with dual gel palms)
4. Pro Adjustable Kettlebell (\$89.99, 10 to 40 lbs adjustable premium cast iron)
5. Therma-Cool Run Tee (\$24.99, colors: Crimson Red, Aero Teal, seamless eco fiber)
6. Carbon-Flex Training Shorts (\$34.99, 2-in-1 compression liner with hidden phone compartment)

Our offline physical locations are:
- Downtown Hub: 158 Nguyen Hue Boulevard, District 1, HCMC (Open 08:00 AM - 10:00 PM)
- Beachside Training Bay: 42 Xuan Thuy Street, Thao Dien, District 2, HCMC (Open 06:00 AM - 09:00 PM)

IMPORTANT INSTRUCTIONS FOR REPLIES:
- You MUST speak in Vietnamese by default in a clear, friendly, and highly athletic tone.
- Use cool sports and fitness emojis (💪, 🏃‍♂️, 🏋️‍♀️, ⚡, 🛒, 🌟).
- Keep answers very short and engaging (maximum 2-3 sentences), since they will be read in small mobile chat bubbles.
- Suggest checkouts under the 'Sản phẩm' tab or 'Đặt mua' buttons inside the app if they ask how to purchase.
- Offer the promo coupon code 'AEROFIT10' for a 10% discount if they show interest or ask for voucher discounts!
        '''),
      );

      // Take last 6 messages for context
      final limitedHistory = history.length > 6
          ? history.sublist(history.length - 6)
          : history;

      // Construct historic content list
      final contentHistory = limitedHistory.map((msg) {
        final role = msg.sender == 'user' ? 'user' : 'model';
        return Content(role, [TextPart(msg.message)]);
      }).toList();

      final chat = model.startChat(history: contentHistory);
      final response = await chat.sendMessage(Content.text(userPrompt));

      return response.text ?? apiErrorResponse;
    } catch (e) {
      return "$networkErrorResponse (Lỗi: ${e.toString()})";
    }
  }
}
