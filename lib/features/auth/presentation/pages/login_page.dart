import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:memorysparks/core/routes/app_routes.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/core/theme/app_theme.dart';
import 'package:memorysparks/features/auth/presentation/providers/auth_provider.dart';
import 'package:memorysparks/features/subscription/presentation/providers/freemium_provider.dart';
import 'package:memorysparks/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:memorysparks/core/utils/snackbar_utils.dart';

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
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.background,
      ),
      backgroundColor: colors.background,
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
                      color: colors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.loginDescription,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Urbanist',
                      color: colors.textSecondary,
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
    final colors = context.appColors;
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      enableSuggestions: false,
      textCapitalization: TextCapitalization.none,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'[^a-zA-Z0-9@._-]')),
      ],
      style: TextStyle(
        fontFamily: 'Urbanist',
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.email,
        labelStyle: TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w400,
          color: colors.textSecondary,
        ),
        prefixIcon: Icon(Icons.email_outlined, color: colors.textSecondary),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
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
    final colors = context.appColors;
    return Consumer<AuthProvider>(
      builder: (context, provider, _) {
        return TextField(
          controller: _passwordController,
          obscureText: !provider.isPasswordVisible,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.password,
            labelStyle: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
            ),
            prefixIcon: Icon(Icons.lock_outline, color: colors.textSecondary),
            suffixIcon: IconButton(
              icon: Icon(
                provider.isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: colors.textSecondary,
              ),
              onPressed: provider.togglePasswordVisibility,
            ),
            filled: true,
            fillColor: colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.border),
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
    final colors = context.appColors;
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
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
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
                      SnackBarUtils.show(
                        context,
                        message: authProvider.error!,
                        type: SnackBarType.error,
                      );
                      return;
                    }

                    if (user != null && mounted) {
                      // Initialize FreemiumProvider with user ID
                      await context
                          .read<FreemiumProvider>()
                          .initialize(user.id);

                      // ✅ Reset loading state immediately before navigation
                      authProvider.resetLoadingState();
                      if (mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.main);
                      }
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
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.dontHaveAccount,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
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
            final success = await provider.signInWithApple();

            if (provider.error != null) {
              if (mounted) {
                SnackBarUtils.show(
                  context,
                  message: provider.error!,
                  type: SnackBarType.error,
                );
              }
              return;
            }

            if (success && mounted) {
              // Initialize FreemiumProvider with user ID
              final user = provider.currentUser;
              if (user != null) {
                await context.read<FreemiumProvider>().initialize(user.id);
              }

              // ✅ Reset loading state immediately before navigation
              provider.resetLoadingState();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.main);
              }
            } else if (mounted) {
              // 🚨 Debug: Authentication failed but no error
              debugPrint(
                  '🚨 Apple Sign In: Authentication failed but no error reported');
              debugPrint('🚨 success: $success');
              debugPrint('🚨 isAuthenticated: ${provider.isAuthenticated}');
              debugPrint('🚨 currentUser: ${provider.currentUser}');
              debugPrint('🚨 error: ${provider.error}');
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
                  SnackBarUtils.show(
                    context,
                    message: provider.error!,
                    type: SnackBarType.error,
                  );
                }
                return;
              }

              if (success && mounted) {
                // Initialize FreemiumProvider with user ID
                final user = provider.currentUser;
                if (user != null) {
                  await context.read<FreemiumProvider>().initialize(user.id);
                }

                // ✅ Reset loading state immediately before navigation
                provider.resetLoadingState();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.main);
                }
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
