import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool agreeTerms = false;
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
            height: h * 0.35,
            child: Image.asset(
              'assets/images/auth_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ),
          Positioned(
            top: h * 0.25,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'TẠO TÀI KHOẢN',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: SportZoneTheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trải nghiệm đỉnh cao cùng cộng đồng SportZone.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SportZoneTheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildField('Họ và tên', 'Nguyễn Văn A', nameController),
                    const SizedBox(height: 14),
                    _buildField('Email', 'example@sportzone.vn', emailController),
                    const SizedBox(height: 14),
                    _buildField('Số điện thoại', '09xx xxx xxx', phoneController),
                    const SizedBox(height: 14),
                    _buildField('Mật khẩu', '••••••••', passwordController, obscure: true),
                    const SizedBox(height: 14),
                    _buildField('Xác nhận mật khẩu', '••••••••', confirmController, obscure: true),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: agreeTerms,
                          onChanged: (value) => setState(() => agreeTerms = value ?? false),
                          activeColor: SportZoneTheme.primary,
                        ),
                        const Expanded(
                          child: Text('Tôi đồng ý với Điều khoản dịch vụ và Chính sách bảo mật của SPORTZONE.'),
                        ),
                      ],
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 8),
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
                                final name = nameController.text.trim();
                                final email = emailController.text.trim();
                                final phone = phoneController.text.trim();
                                final pass = passwordController.text;
                                final confirm = confirmController.text;
                                if (name.isEmpty || email.isEmpty || phone.isEmpty || pass.isEmpty) {
                                  setState(() => error = 'Vui lòng hoàn thành mọi vùng nhập của bạn!');
                                } else if (pass != confirm) {
                                  setState(() => error = 'Mật khẩu xác nhận không khớp!');
                                } else if (!agreeTerms) {
                                  setState(() => error = 'Bạn phải đồng ý với các điều khoản của SPORTZONE!');
                                } else {
                                  final errMessage = await state.registerAsync(
                                    fullName: name,
                                    email: email,
                                    password: pass,
                                    phone: phone,
                                  );
                                  if (errMessage == null) {
                                    if (!context.mounted) return;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => OtpVerificationScreen(email: email)),
                                    );
                                  } else {
                                    setState(() => error = errMessage);
                                  }
                                }
                              },
                        child: state.isLoadingAuth
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                              )
                            : Text(
                                'ĐĂNG KÝ',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: SportZoneTheme.onPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
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

  Widget _buildField(String label, String placeholder, TextEditingController controller, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: SportZoneTheme.secondary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: SportZoneTheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
