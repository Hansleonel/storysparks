import 'package:flutter/material.dart';
import 'package:memorysparks/l10n/app_localizations.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/core/theme/app_theme.dart';

class AuthorStyleDialog extends StatefulWidget {
  final String? currentAuthor;
  final String? currentBook;

  const AuthorStyleDialog({
    super.key,
    this.currentAuthor,
    this.currentBook,
  });

  @override
  State<AuthorStyleDialog> createState() => _AuthorStyleDialogState();
}

class _AuthorStyleDialogState extends State<AuthorStyleDialog> {
  int _selectedOption = 0; // 0 = author, 1 = book, 2 = custom
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _bookController = TextEditingController();
  final TextEditingController _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing values if any
    if (widget.currentAuthor?.isNotEmpty ?? false) {
      _authorController.text = widget.currentAuthor!;
      _selectedOption = 0;
    } else if (widget.currentBook?.isNotEmpty ?? false) {
      _bookController.text = widget.currentBook!;
      _selectedOption = 1;
    }
  }

  @override
  void dispose() {
    _authorController.dispose();
    _bookController.dispose();
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final colors = context.appColors;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Dialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24.0,
                24.0,
                24.0,
                24.0 + keyboardHeight * 0.1,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_stories,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.authorStyleTitle,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Urbanist',
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.authorStyleDescription,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Urbanist',
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Author option
                  _buildOptionCard(
                    title: AppLocalizations.of(context)!.authorStyleAuthor,
                    description: AppLocalizations.of(context)!
                        .authorStyleAuthorDescription,
                    icon: Icons.person_outline,
                    isSelected: _selectedOption == 0,
                    onTap: () => setState(() => _selectedOption = 0),
                  ),

                  // Author input (shown when author is selected)
                  if (_selectedOption == 0) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap:
                          () {}, // Evita que se oculte el teclado al tocar el campo
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.border),
                          borderRadius: BorderRadius.circular(12),
                          color: colors.surface,
                        ),
                        child: TextField(
                          controller: _authorController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!
                                .authorStyleAuthorHint,
                            hintStyle: TextStyle(
                              color: colors.textSecondary,
                              fontFamily: 'Urbanist',
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Book option
                  _buildOptionCard(
                    title: AppLocalizations.of(context)!.authorStyleBook,
                    description: AppLocalizations.of(context)!
                        .authorStyleBookDescription,
                    icon: Icons.book_outlined,
                    isSelected: _selectedOption == 1,
                    onTap: () => setState(() => _selectedOption = 1),
                  ),

                  // Book input (shown when book is selected)
                  if (_selectedOption == 1) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap:
                          () {}, // Evita que se oculte el teclado al tocar el campo
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.border),
                          borderRadius: BorderRadius.circular(12),
                          color: colors.surface,
                        ),
                        child: TextField(
                          controller: _bookController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!
                                .authorStyleBookHint,
                            hintStyle: TextStyle(
                              color: colors.textSecondary,
                              fontFamily: 'Urbanist',
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Custom style option
                  _buildOptionCard(
                    title: AppLocalizations.of(context)!.authorStyleCustom,
                    description: AppLocalizations.of(context)!
                        .authorStyleCustomDescription,
                    icon: Icons.edit_outlined,
                    isSelected: _selectedOption == 2,
                    onTap: () => setState(() => _selectedOption = 2),
                  ),

                  // Custom input (shown when custom is selected)
                  if (_selectedOption == 2) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap:
                          () {}, // Evita que se oculte el teclado al tocar el campo
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.border),
                          borderRadius: BorderRadius.circular(12),
                          color: colors.surface,
                        ),
                        child: TextField(
                          controller: _customController,
                          maxLines: 3,
                          minLines: 3,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!
                                .authorStyleCustomHint,
                            hintStyle: TextStyle(
                              color: colors.textSecondary,
                              fontFamily: 'Urbanist',
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: colors.border),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            String? result;
                            String type = '';

                            if (_selectedOption == 0) {
                              final author = _authorController.text.trim();
                              if (author.isNotEmpty) {
                                result = author;
                                type = 'author';
                              }
                            } else if (_selectedOption == 1) {
                              final book = _bookController.text.trim();
                              if (book.isNotEmpty) {
                                result = book;
                                type = 'book';
                              }
                            } else if (_selectedOption == 2) {
                              final custom = _customController.text.trim();
                              if (custom.isNotEmpty) {
                                result = custom;
                                type = 'custom';
                              }
                            }

                            Navigator.of(context).pop({
                              'text': result,
                              'type': type,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.authorStyleApply,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Clear button (shown if there's existing data)
                  if ((widget.currentAuthor?.isNotEmpty ?? false) ||
                      (widget.currentBook?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop({'clear': true}),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.authorStyleRemove,
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : colors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color:
              isSelected ? AppColors.primary.withOpacity(0.05) : colors.surface,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : colors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : colors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Urbanist',
                      color:
                          isSelected ? AppColors.primary : colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Urbanist',
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
