import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storysparks/core/routes/app_routes.dart';
import 'package:storysparks/core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back 👋',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: 'Playfair',
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please enter your email & password to sign in.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Urbanist',
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            const SizedBox(height: 60),
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 20),
            _buildRememberMeAndForgotPassword(),
            const SizedBox(height: 40),
            _buildLoginButton(),
            const SizedBox(height: 20),
            _buildSignUpLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(
        fontFamily: 'Urbanist',
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: const TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        prefixIcon:
            const Icon(Icons.email_outlined, color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      style: const TextStyle(
        fontFamily: 'Urbanist',
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: const TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        prefixIcon:
            const Icon(Icons.lock_outline, color: AppColors.textSecondary),
        suffixIcon: const Icon(Icons.visibility_off_outlined,
            color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) => setState(() => _rememberMe = value!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const Text(
          'Remember me',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // TODO: Implement forgot password
          },
          child: Text(
            'Forgot password?',
            style: TextStyle(
              color: AppColors.primary,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return ElevatedButton(
            onPressed: authProvider.isLoading
                ? null
                : () async {
                    final user = await authProvider.login(
                      _emailController.text,
                      _passwordController.text,
                    );
                    if (user != null && mounted) {
                      // Navigate to home page
                      Navigator.pushReplacementNamed(context, AppRoutes.main);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: authProvider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Sign in',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: Navigate to sign up page
          },
          child: Text(
            'Sign up',
            style: TextStyle(
              color: AppColors.primary,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
