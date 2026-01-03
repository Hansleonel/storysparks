import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memorysparks/core/dependency_injection/service_locator.dart';
import 'package:memorysparks/core/routes/app_routes.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/core/theme/app_theme.dart';
import 'package:memorysparks/core/providers/theme_provider.dart';
import 'package:memorysparks/core/providers/locale_provider.dart';
import 'package:memorysparks/l10n/app_localizations.dart';
import 'package:memorysparks/core/widgets/confirmation_dialog.dart';
import '../providers/settings_provider.dart';
import 'package:memorysparks/features/auth/presentation/providers/auth_provider.dart';
import 'package:memorysparks/core/utils/snackbar_utils.dart';
import '../widgets/language_selection_modal.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<SettingsProvider>(),
      child: _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)?.settings ?? 'Settings',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              _buildSearchBar(context),
              _buildSection(
                context,
                AppLocalizations.of(context)?.accountSettings ?? 'Account',
                [
                  _SettingsItem(
                    icon: Icons.person_outline,
                    title: AppLocalizations.of(context)?.personalInformation ??
                        'Personal Information',
                    onTap: () {
                      // TODO: Navigate to personal information page
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.security_outlined,
                    title: AppLocalizations.of(context)?.security ?? 'Security',
                    onTap: () {
                      // TODO: Navigate to security page
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.privacy_tip_outlined,
                    title: AppLocalizations.of(context)?.privacy ?? 'Privacy',
                    onTap: () {
                      // TODO: Navigate to privacy page
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.delete_forever_outlined,
                    title: AppLocalizations.of(context)?.deleteAccount ??
                        'Delete Account',
                    onTap: () async {
                      print(
                          '👉 SettingsPage: Usuario ha tocado "Delete Account"');
                      final confirm = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => ConfirmationDialog(
                          icon: Icons.delete_forever_outlined,
                          iconColor: Colors.red,
                          title: AppLocalizations.of(context)
                                  ?.deleteAccountTitle ??
                              'Delete Account',
                          message: AppLocalizations.of(context)
                                  ?.deleteAccountConfirmation ??
                              'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
                          cancelText:
                              AppLocalizations.of(context)?.cancel ?? 'Cancel',
                          confirmText:
                              AppLocalizations.of(context)?.delete ?? 'Delete',
                          onCancel: () {
                            print(
                                '🚫 SettingsPage: Usuario canceló la eliminación de cuenta');
                            Navigator.pop(context, false);
                          },
                          onConfirm: () {
                            print(
                                '⚠️ SettingsPage: Usuario confirmó la eliminación de cuenta');
                            Navigator.pop(context, true);
                          },
                        ),
                      );

                      if (confirm == true) {
                        print(
                            '🔄 SettingsPage: Iniciando proceso de eliminación de cuenta');
                        // Mostrar cargando
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        try {
                          final authProvider = context.read<AuthProvider>();
                          print(
                              '📱 SettingsPage: Llamando a deleteAccount en AuthProvider');
                          final success = await authProvider.deleteAccount();

                          // Cerrar diálogo de carga
                          if (context.mounted) Navigator.pop(context);

                          if (success) {
                            print(
                                '✅ SettingsPage: Cuenta eliminada con éxito, redirigiendo a login');
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.login,
                                (route) => false,
                              );

                              // Mostrar mensaje de éxito
                              SnackBarUtils.show(
                                context,
                                message:
                                    'Your account has been deleted successfully',
                                type: SnackBarType.success,
                              );
                            }
                          } else {
                            print(
                                '❌ SettingsPage: Error al eliminar cuenta: ${authProvider.error}');
                            if (context.mounted) {
                              SnackBarUtils.show(
                                context,
                                message:
                                    'Error deleting account: ${authProvider.error}',
                                type: SnackBarType.error,
                              );
                            }
                          }
                        } catch (e) {
                          print(
                              '💥 SettingsPage: Excepción al eliminar cuenta: $e');
                          // Cerrar diálogo de carga
                          if (context.mounted) Navigator.pop(context);

                          // Mostrar error
                          if (context.mounted) {
                            SnackBarUtils.show(
                              context,
                              message: 'Error deleting account: $e',
                              type: SnackBarType.error,
                            );
                          }
                        }
                      }
                    },
                    textColor: Colors.red,
                  ),
                ],
              ),
              _buildSection(
                context,
                AppLocalizations.of(context)?.preferences ?? 'Preferences',
                [
                  _SettingsItem(
                    icon: Icons.notifications_outlined,
                    title: AppLocalizations.of(context)?.notifications ??
                        'Notifications',
                    onTap: () {
                      // TODO: Navigate to notifications page
                    },
                  ),
                  Consumer<LocaleProvider>(
                    builder: (context, localeProvider, child) {
                      final currentLocale = localeProvider.locale ??
                          WidgetsBinding.instance.platformDispatcher.locale;
                      final languageName =
                          _getLanguageDisplayName(currentLocale.languageCode);

                      return _SettingsItemWithDetail(
                        icon: Icons.language_outlined,
                        title:
                            AppLocalizations.of(context)?.language ?? 'Language',
                        detail: languageName,
                        onTap: () {
                          LanguageSelectionModal.show(context);
                        },
                      );
                    },
                  ),
                  _SettingsItemWithSwitch(
                    icon: Icons.dark_mode_outlined,
                    title: AppLocalizations.of(context)?.darkMode ?? 'Dark Mode',
                  ),
                ],
              ),
              _buildSection(
                context,
                AppLocalizations.of(context)?.help ?? 'Help',
                [
                  _SettingsItem(
                    icon: Icons.help_outline,
                    title: AppLocalizations.of(context)?.helpCenter ??
                        'Help Center',
                    onTap: () {
                      // TODO: Navigate to help center
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.info_outline,
                    title: AppLocalizations.of(context)?.about ?? 'About',
                    onTap: () {
                      // TODO: Navigate to about page
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    provider.error!,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 14,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          final error = await provider.logout();
                          if (error != null && context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Error'),
                                content: Text(error),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.login,
                                (route) => false,
                              );
                            }
                          }
                        },
                  child: Text(
                    AppLocalizations.of(context)?.logout ?? 'Log Out',
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          style: TextStyle(
            fontFamily: 'Urbanist',
            color: colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.searchSettings ??
                'Search settings',
            hintStyle: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 16,
              color: colors.textSecondary,
            ),
            prefixIcon: Icon(Icons.search, color: colors.textSecondary),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            // TODO: Implement settings search
          },
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  String _getLanguageDisplayName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'System';
    }
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? colors.textPrimary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  color: textColor ?? colors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: textColor ?? colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItemWithDetail extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  const _SettingsItemWithDetail({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: colors.textPrimary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  color: colors.textPrimary,
                ),
              ),
            ),
            Text(
              detail,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _SettingsItemWithSwitch extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SettingsItemWithSwitch({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                themeProvider.isDarkMode
                    ? Icons.dark_mode
                    : Icons.dark_mode_outlined,
                color: colors.textPrimary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.setDarkMode(value),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }
}
