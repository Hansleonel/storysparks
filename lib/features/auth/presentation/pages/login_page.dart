import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:storysparks/core/routes/app_routes.dart';
import 'package:storysparks/core/theme/app_colors.dart';
import 'package:storysparks/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.welcomeBack,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontFamily: 'Playfair',
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.loginDescription,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Urbanist',
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
              ),
              const SizedBox(height: 32),
              _buildEmailField(),
              const SizedBox(height: 20),
              _buildPasswordField(),
              const SizedBox(height: 20),
              _buildRememberMeAndForgotPassword(),
              const SizedBox(height: 40),
              _buildLoginButton(),
              const SizedBox(height: 20),
              _buildSignUpLink(),
              const SizedBox(height: 20),
              _buildAppleSignInButton(),
              const SizedBox(height: 20),
              _buildGoogleSignInButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      enableSuggestions: false,
      textCapitalization: TextCapitalization.none,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'[^a-zA-Z0-9@._-]')),
      ],
      style: const TextStyle(
        fontFamily: 'Urbanist',
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.email,
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
    return Consumer<AuthProvider>(
      builder: (context, provider, _) {
        return TextField(
          controller: _passwordController,
          obscureText: !provider.isPasswordVisible,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.password,
            labelStyle: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            prefixIcon:
                const Icon(Icons.lock_outline, color: AppColors.textSecondary),
            suffixIcon: IconButton(
              icon: Icon(
                provider.isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: provider.togglePasswordVisibility,
            ),
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
      },
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
        Text(
          AppLocalizations.of(context)!.rememberMe,
          style: const TextStyle(
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
            AppLocalizations.of(context)!.forgotPassword,
            style: const TextStyle(
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

                    if (authProvider.error != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(authProvider.error!),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (user != null && mounted) {
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
                : Text(
                    AppLocalizations.of(context)!.signIn,
                    style: const TextStyle(
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
        Text(
          AppLocalizations.of(context)!.dontHaveAccount,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.register);
          },
          child: Text(
            AppLocalizations.of(context)!.signUp,
            style: const TextStyle(
              color: AppColors.primary,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppleSignInButton() {
    if (!Platform.isIOS) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    return Consumer<AuthProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SignInWithAppleButton(
          text: l10n.signInWithApple,
          height: 48,
          style: SignInWithAppleButtonStyle.black,
          onPressed: () async {
            await provider.signInWithApple();

            if (provider.error != null) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }

            if (provider.isAuthenticated && mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.main);
            }
          },
        );
      },
    );
  }

  Widget _buildGoogleSignInButton() {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AuthProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Image.asset(
              'assets/images/google_icon.png',
              height: 24,
              width: 24,
            ),
            label: Text(
              l10n.signInWithGoogle,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () async {
              final success = await provider.signInWithGoogle();

              if (provider.error != null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.error!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              if (success && mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.main);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        );
      },
    );
  }
}
