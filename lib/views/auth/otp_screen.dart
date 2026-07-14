import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';

class OtpScreen extends StatefulWidget {
  /// When [email] is provided (e.g. navigating from registration), the screen
  /// skips the email-entry step and auto-triggers OTP sending.
  final String? email;

  const OtpScreen({super.key, this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    if (widget.email != null && widget.email!.isNotEmpty) {
      _emailController.text = widget.email!;
      // Auto-send OTP after the first frame so the provider is available
      WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_emailFormKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.sendOtp(_emailController.text.trim());

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully! Please check your email.'),
            backgroundColor: AppColors.income,
          ),
        );
        setState(() {
          _otpSent = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to send OTP'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (!_codeFormKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOtp(
      _emailController.text.trim(),
      _codeController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP matches! Retrying login session...'),
            backgroundColor: AppColors.income,
          ),
        );
        
        // Refresh auth status in case the verification automatically cookies or logs us in
        await authProvider.checkAuthStatus();
        
        if (mounted) {
          if (authProvider.isAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          } else {
            // OTP verification matches, but we must log in normally. Pop back.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification completed! Please sign in using your credentials.'),
                backgroundColor: AppColors.income,
              ),
            );
            Navigator.of(context).pop();
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Invalid OTP code'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkBg, Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: !_otpSent
                  ? Form(
                      key: _emailFormKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Verify Identity via OTP',
                            style: Theme.of(context).textTheme.headlineLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Enter your email address to receive a 6-digit OTP verification code.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 36),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted),
                            ),
                          ),
                          const SizedBox(height: 24),
                          authProvider.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _sendOtp,
                                  child: const Text('Send Verification Code'),
                                ),
                        ],
                      ),
                    )
                  : Form(
                      key: _codeFormKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Confirm OTP Code',
                            style: Theme.of(context).textTheme.headlineLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Enter the 6-digit OTP code sent to ${_emailController.text}.',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 36),
                          TextFormField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter the verification code';
                              }
                              if (value.trim().length != 6) {
                                return 'OTP must be exactly 6 digits';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Code',
                              prefixIcon: Icon(Icons.security, color: AppColors.textMuted),
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 24),
                          authProvider.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _verifyOtp,
                                  child: const Text('Verify and Continue'),
                                ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _otpSent = false;
                              });
                            },
                            child: const Text(
                              'Change email address',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
