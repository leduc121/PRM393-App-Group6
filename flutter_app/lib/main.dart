import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Đánh thức server Render ngay khi mở app (không chờ kết quả)
  ApiService.warmUp();
  runApp(const SportZoneApp());
}

class SportZoneApp extends StatelessWidget {
  const SportZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SportZoneState(),
      child: MaterialApp(
        title: 'SportZone',
        debugShowCheckedModeBanner: false,
        theme: SportZoneTheme.lightTheme,
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/otp_verification': (_) => const OtpVerificationScreen(email: ''),
          '/main': (_) => const MainScreen(),
          '/checkout': (_) => const CheckoutScreen(),
          '/order-status': (_) => const OrderStatusScreen(),
          '/profile': (_) => const ProfileScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product') {
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            );
          }
          if (settings.name == '/otp_verification') {
            final email = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(email: email),
            );
          }
          if (settings.name == '/admin/vouchers') {
            return MaterialPageRoute(
              builder: (_) => const VoucherManagementScreen(),
            );
          }
          if (settings.name == '/admin/vouchers/form') {
            final voucher = settings.arguments as Voucher?;
            return MaterialPageRoute(
              builder: (_) => VoucherFormScreen(voucher: voucher),
            );
          }
          return null;
        },
      ),
    );
  }
}
