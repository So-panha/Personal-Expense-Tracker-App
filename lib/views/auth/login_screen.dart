import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'social_auth_button.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Authentication failed'),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkBg, Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header logo/icon
                    Center(
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Titles
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Keep track of your finance easily.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Email Input
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: 16),

                    // Password Input
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Forgot Password Row
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    authProvider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _submit,
                            child: const Text('Login'),
                          ),
                    const SizedBox(height: 24),



                    // ─────── Social sign-in ───────
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.white24)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or continue with',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Colors.white24)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SocialAuthButton(
                      label: 'Sign in with Google',
                      iconAsset: 'assets/images/google.png',
                      isLoading: authProvider.isLoading,
                      onPressed: () async {
                        final success = await authProvider.loginWithGoogle();
                        if (mounted && success) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const DashboardScreen()),
                          );
                        } else if (mounted && authProvider.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authProvider.error!),
                              backgroundColor: AppColors.expense,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    SocialAuthButton(
                      label: 'Sign in with Facebook',
                      iconAsset: 'assets/images/facebook.png',
                      isLoading: authProvider.isLoading,
                      onPressed: () async {
                        final success = await authProvider.loginWithFacebook();
                        if (mounted && success) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const DashboardScreen()),
                          );
                        } else if (mounted && authProvider.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authProvider.error!),
                              backgroundColor: AppColors.expense,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Signup Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.primary,
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
        ),
      ),
    );
  }
}
