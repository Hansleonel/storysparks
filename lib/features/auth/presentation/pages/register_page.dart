import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memorysparks/core/routes/app_routes.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();

  // Controladores de estado de validación
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _usernameError;
  bool _isCheckingUsername = false;

  // Expresiones regulares para validaciones
  final _emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  final _usernameRegExp = RegExp(r'^[a-zA-Z0-9_]+$');

  late AppLocalizations l10n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    l10n = AppLocalizations.of(context)!;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Validación de email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return l10n.emailRequired;
    }
    if (!_emailRegExp.hasMatch(value)) {
      return l10n.invalidEmailFormat;
    }
    return null;
  }

  // Validación de contraseña
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return l10n.passwordRequired;
    }
    if (value.length < 8) {
      return l10n.passwordMinLength;
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return l10n.passwordUppercase;
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return l10n.passwordLowercase;
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return l10n.passwordNumber;
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return l10n.passwordSpecial;
    }
    return null;
  }

  // Validación de username
  String? _validateUsernameSync(String? value) {
    if (value == null || value.isEmpty) {
      return l10n.usernameRequired;
    }
    if (value.length < 3 || value.length > 30) {
      return l10n.usernameLength;
    }
    if (!_usernameRegExp.hasMatch(value)) {
      return l10n.usernameInvalidChars;
    }
    return _usernameError;
  }

  // Verificar disponibilidad del username
  Future<void> _checkUsernameAvailability(String username) async {
    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
    });

    try {
      final existingUser = await Supabase.instance.client
          .from('profiles')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      if (existingUser != null) {
        setState(() {
          _usernameError = l10n.usernameExists;
        });
      }
    } catch (e) {
      setState(() {
        _usernameError = l10n.profileUpdateError;
      });
    } finally {
      setState(() {
        _isCheckingUsername = false;
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AuthProvider>().register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(),
          fullName: _fullNameController.text.trim(),
          bio: _bioController.text.trim(),
        );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.createAccount,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontFamily: 'Playfair',
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.fillInformation,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Urbanist',
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: _emailController,
                  label: l10n.email,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  helperText: l10n.emailHelperText,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.none,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                        RegExp(r'[^a-zA-Z0-9@._-]')),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _usernameController,
                  label: l10n.username,
                  prefixIcon: Icons.person_outline,
                  validator: _validateUsernameSync,
                  onChanged: (value) {
                    if (value.length >= 3) {
                      _checkUsernameAvailability(value);
                    }
                  },
                  helperText: l10n.usernameHelperText,
                  suffixIcon: _isCheckingUsername
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        )
                      : null,
                  errorText: _usernameError,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.none,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: l10n.password,
                  prefixIcon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  validator: _validatePassword,
                  helperText: l10n.passwordHelperText,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.none,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: l10n.confirmPassword,
                  prefixIcon: Icons.lock_outline,
                  obscureText: !_isConfirmPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.confirmPasswordRequired;
                    }
                    if (value != _passwordController.text) {
                      return l10n.passwordsDontMatch;
                    }
                    return null;
                  },
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.none,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _fullNameController,
                  label: l10n.fullName,
                  prefixIcon: Icons.badge_outlined,
                  helperText: l10n.optional,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s]')),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _bioController,
                  label: l10n.bio,
                  prefixIcon: Icons.edit_note_outlined,
                  maxLines: 3,
                  helperText: l10n.optional,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 32),
                if (authProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      authProvider.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            l10n.register,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.alreadyHaveAccount,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.login,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    Widget? suffixIcon,
    int? maxLines,
    String? helperText,
    String? errorText,
    bool autocorrect = true,
    bool enableSuggestions = true,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: obscureText ? 1 : maxLines,
      style: const TextStyle(
        fontFamily: 'Urbanist',
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: AppColors.white,
        suffixIcon: suffixIcon,
        helperText: helperText,
        helperMaxLines: 5,
        errorText: errorText,
        errorMaxLines: 3,
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w500,
        ),
      ),
      onChanged: onChanged,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
    );
  }
}
