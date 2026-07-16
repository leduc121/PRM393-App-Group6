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
  final String initialRoute;

  const SportZoneApp({super.key, this.initialRoute = '/splash'});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SportZoneState(),
      child: MaterialApp(
        title: 'SportZone',
        debugShowCheckedModeBanner: false,
        theme: SportZoneTheme.lightTheme,
        initialRoute: initialRoute,
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
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
            final email = settings.arguments?.toString() ?? '';
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
