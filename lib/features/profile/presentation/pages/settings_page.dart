import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memorysparks/core/dependency_injection/service_locator.dart';
import 'package:memorysparks/core/routes/app_routes.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/l10n/app_localizations.dart';
import 'package:memorysparks/core/widgets/confirmation_dialog.dart';
import '../providers/settings_provider.dart';
import 'package:memorysparks/features/auth/presentation/providers/auth_provider.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)?.settings ?? 'Settings',
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Your account has been deleted successfully',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            print(
                                '❌ SettingsPage: Error al eliminar cuenta: ${authProvider.error}');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error deleting account: ${authProvider.error}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error deleting account: $e',
                                ),
                                backgroundColor: Colors.red,
                              ),
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
                  _SettingsItem(
                    icon: Icons.language_outlined,
                    title: AppLocalizations.of(context)?.language ?? 'Language',
                    onTap: () {
                      // TODO: Navigate to language page
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.dark_mode_outlined,
                    title: AppLocalizations.of(context)?.theme ?? 'Theme',
                    onTap: () {
                      // TODO: Navigate to theme page
                    },
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
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
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.searchSettings ??
                'Search settings',
            hintStyle: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            prefixIcon:
                const Icon(Icons.search, color: AppColors.textSecondary),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  // If you want to add a trailing icon, uncomment the following line
  // final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    // this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? AppColors.textPrimary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  color: textColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            // trailing ??
            Icon(
              Icons.chevron_right,
              color: textColor ?? AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
