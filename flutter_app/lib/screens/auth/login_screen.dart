import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: h * 0.45,
            child: Image.asset(
              'assets/images/auth_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: h * 0.35,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'ĐĂNG NHẬP',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: SportZoneTheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chào mừng trở lại với SportZone',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SportZoneTheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Email',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: SportZoneTheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: usernameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Nhập email',
                        filled: true,
                        fillColor: SportZoneTheme.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mật khẩu',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: SportZoneTheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Nhập mật khẩu',
                        filled: true,
                        fillColor: SportZoneTheme.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Quên mật khẩu?',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          decoration: TextDecoration.underline,
                          color: SportZoneTheme.secondary,
                        ),
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        error!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SportZoneTheme.error),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SportZoneTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: state.isLoadingAuth
                            ? null
                            : () async {
                                final email = usernameController.text.trim();
                                final password = passwordController.text;
                                if (email.isEmpty || password.isEmpty) {
                                  setState(() {
                                    error = 'Vui lòng điền đầy đủ email và mật khẩu!';
                                  });
                                  return;
                                }
                                final errMessage = await state.loginAsync(email, password);
                                if (errMessage == null) {
                                  state.fetchCategories();
                                  state.fetchBrands();
                                  state.fetchProducts();
                                  if (!context.mounted) return;
                                  Navigator.pushReplacementNamed(context, '/main');
                                } else {
                                  setState(() {
                                    error = errMessage;
                                  });
                                }
                              },
                        child: state.isLoadingAuth
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'ĐĂNG NHẬP',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: SportZoneTheme.onPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Divider(color: SportZoneTheme.borderSubtle),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/register'),
                      child: Text(
                        'Bạn chưa có tài khoản? Đăng ký ngay',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: SportZoneTheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
