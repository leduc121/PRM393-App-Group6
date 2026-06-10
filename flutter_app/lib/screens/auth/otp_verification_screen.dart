import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';
import 'dart:async';
import 'package:pinput/pinput.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? error;
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final state = context.read<SportZoneState>();
    final otp = _otpController.text;
    if (otp.length < 6) {
      setState(() => error = 'Vui lòng nhập đủ 6 số OTP');
      return;
    }
    final errMessage = await state.verifyOtpAsync(widget.email, otp);
    if (errMessage == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xác thực thành công! Vui lòng đăng nhập.')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() => error = errMessage);
    }
  }

  Future<void> _resendOtp() async {
    final state = context.read<SportZoneState>();
    final errMessage = await state.resendOtpAsync(widget.email);
    if (errMessage == null) {
      _startTimer();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi lại mã OTP!')),
      );
    } else {
      setState(() => error = errMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    final h = MediaQuery.of(context).size.height;

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: SportZoneTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: SportZoneTheme.primary, width: 2),
      borderRadius: BorderRadius.circular(12),
    );

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
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
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
                    const Icon(Icons.mark_email_read_outlined, size: 64, color: SportZoneTheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'XÁC THỰC OTP',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: SportZoneTheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mã xác thực gồm 6 số đã được gửi đến:',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SportZoneTheme.secondary),
                    ),
                    Text(
                      widget.email,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Pinput(
                        length: 6,
                        controller: _otpController,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        showCursor: true,
                        onCompleted: (pin) {
                          if (!state.isLoadingAuth) _verifyOtp();
                        },
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SportZoneTheme.error),
                      ),
                    ],
                    const SizedBox(height: 32),
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
                        onPressed: state.isLoadingAuth ? null : _verifyOtp,
                        child: state.isLoadingAuth
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                              )
                            : Text(
                                'XÁC NHẬN',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: SportZoneTheme.onPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Chưa nhận được mã? ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SportZoneTheme.secondary),
                        ),
                        GestureDetector(
                          onTap: _secondsLeft == 0 && !state.isLoadingAuth ? _resendOtp : null,
                          child: Text(
                            _secondsLeft > 0 ? 'Gửi lại sau s' : 'Gửi lại ngay',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: _secondsLeft == 0 ? SportZoneTheme.primary : SportZoneTheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
