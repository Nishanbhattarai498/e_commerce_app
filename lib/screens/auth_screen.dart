import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

enum AuthMode { login, signup }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  AuthMode _mode = AuthMode.login;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  bool get _isLogin => _mode == AuthMode.login;

  void _resetOtpState() {
    if (!_otpSent) return;
    setState(() {
      _otpSent = false;
      _otpController.clear();
    });
  }

  Future<void> _resendOtp() async {
    if (_emailController.text.trim().isEmpty ||
        !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email first.')),
      );
      return;
    }

    final authService = context.read<AuthService>();
    final email = _emailController.text.trim();

    try {
      String? firstName;
      String? lastName;
      if (!_isLogin && _nameController.text.trim().isNotEmpty) {
        final names = _nameController.text.trim().split(' ');
        firstName = names.isNotEmpty ? names.first : null;
        lastName = names.length > 1 ? names.sublist(1).join(' ') : null;
      }

      await authService.sendEmailOtp(
        email: email,
        shouldCreateUser: !_isLogin,
        firstName: firstName,
        lastName: lastName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New code sent to $email')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final authService = context.read<AuthService>();
    final email = _emailController.text.trim();

    try {
      if (!_otpSent) {
        String? firstName;
        String? lastName;

        if (!_isLogin && _nameController.text.trim().isNotEmpty) {
          final names = _nameController.text.trim().split(' ');
          firstName = names.isNotEmpty ? names.first : null;
          lastName = names.length > 1 ? names.sublist(1).join(' ') : null;
        }

        await authService.sendEmailOtp(
          email: email,
          shouldCreateUser: !_isLogin,
          firstName: firstName,
          lastName: lastName,
        );

        if (!mounted) return;
        setState(() {
          _otpSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'We sent a 6-digit code to $email. Enter it below to continue.',
            ),
          ),
        );
      } else {
        final otp = _otpController.text.trim();
        if (otp.length < 6) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter the 6-digit code.')),
          );
          return;
        }

        await authService.verifyEmailOtp(
          email: email,
          token: otp,
        );

        if (!mounted) return;
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = context.watch<AuthService>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildHeroSection(theme),
              Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: _buildFormCard(authService.isLoading, theme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Luxe Commerce',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            _isLogin ? 'Welcome back' : 'Create account',
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isLogin
                ? 'Sign in to continue discovering curated products.'
                : 'Join us to unlock exclusive drops and seasonal deals.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(bool isLoading, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: AuthMode.values.map((mode) {
                  final isSelected = _mode == mode;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_mode == mode) return;
                        setState(() {
                          _mode = mode;
                          _otpSent = false;
                          _otpController.clear();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          mode == AuthMode.login ? 'Login' : 'Sign Up',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                isSelected ? Colors.white : theme.primaryColor,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            if (!_isLogin) ...[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              onChanged: (_) => _resetOtpState(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email required';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (_otpSent) ...[
              Text(
                'Enter the 6-digit code we emailed to you.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: 'One-time code',
                  prefixIcon: Icon(Icons.shield_outlined),
                  counterText: '',
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: isLoading ? null : _resendOtp,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Resend code'),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lock_clock_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'We send a secure OTP to your email. Enter it to ${_isLogin ? 'sign in instantly' : 'finish creating your account'}.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_otpSent ? 'Verify & Continue' : 'Send OTP'),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/home', (route) => false);
              },
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Skip for now'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or continue with',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(Icons.apple, 'Apple'),
                _buildSocialButton(Icons.g_mobiledata, 'Google'),
                _buildSocialButton(Icons.facebook, 'Facebook'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: OutlinedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label sign-in coming soon'),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Icon(icon),
        ),
      ),
    );
  }
}
