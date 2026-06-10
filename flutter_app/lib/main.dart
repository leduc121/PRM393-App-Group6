import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';

void main() {
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
          return null;
        },
      ),
    );
  }
}
