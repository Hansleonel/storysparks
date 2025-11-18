import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:memorysparks/core/dependency_injection/service_locator.dart';
import 'package:memorysparks/core/providers/new_story_indicator_provider.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/core/constants/genre_constants.dart';
import 'package:memorysparks/features/story/domain/usecases/update_story_rating_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/delete_story_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/save_story_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/update_story_status_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/continue_story_usecase.dart';
import '../../domain/entities/story.dart';
import '../providers/story_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:memorysparks/l10n/app_localizations.dart';
import 'dart:io';
import '../widgets/continue_story_dialog.dart';
import '../widgets/share_story_modal.dart';
import 'package:memorysparks/core/widgets/confirmation_dialog.dart';
import 'package:memorysparks/core/utils/snackbar_utils.dart';

class GeneratedStoryPage extends StatefulWidget {
  final Story story;
  final bool isFromLibrary;
  final VoidCallback? onIncrementReadCount;
  final VoidCallback? onStoryStateChanged;

  const GeneratedStoryPage({
    super.key,
    required this.story,
    this.isFromLibrary = false,
    this.onIncrementReadCount,
    this.onStoryStateChanged,
  });

  @override
  State<GeneratedStoryPage> createState() => _GeneratedStoryPageState();
}

class _GeneratedStoryPageState extends State<GeneratedStoryPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _storyKey = GlobalKey();
  bool _hasIncrementedReadCount = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late StoryProvider _storyProvider;

  @override
  void initState() {
    super.initState();
    // Print story content for debugging
    debugPrint('\n📚 ===== Story Debug Info ===== 📚\n');
    debugPrint('📌 Title: ${widget.story.title}\n');
    debugPrint('💭 Memory: ${widget.story.memory}\n');
    debugPrint('📖 Content: ${widget.story.content}\n');
    debugPrint('🏁 ========================== 🏁\n');
    _initializeProviderAndAnimations();
  }

  void _initializeProviderAndAnimations() {
    _storyProvider = StoryProvider(
      updateRatingUseCase: getIt<UpdateStoryRatingUseCase>(),
      deleteStoryUseCase: getIt<DeleteStoryUseCase>(),
      saveStoryUseCase: getIt<SaveStoryUseCase>(),
      updateStoryStatusUseCase: getIt<UpdateStoryStatusUseCase>(),
      continueStoryUseCase: getIt<ContinueStoryUseCase>(),
    )..setStory(widget.story, isFromLibrary: widget.isFromLibrary);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    _storyProvider.updateScrollPosition(
      _scrollController.position.maxScrollExtent,
      _scrollController.offset,
    );
  }

  // Método para realizar scroll automático después de una continuación
  void _scrollAfterContinuation() {
    debugPrint('🔄 Scrolling after continuation');
    if (!_scrollController.hasClients) return;

    // Añadir un retraso mayor para asegurar que el contenido se haya renderizado completamente
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted || !_scrollController.hasClients) return;

      // Obtener información sobre la posición actual y el tamaño del contenido
      final currentOffset = _scrollController.offset;
      final maxOffset = _scrollController.position.maxScrollExtent;
      final viewportHeight = _scrollController.position.viewportDimension;

      // Calcular un punto de destino que muestre la nueva continuación
      // Intentamos posicionar el scroll para que muestre el separador de continuación
      // y parte del nuevo contenido

      // Si estamos muy cerca del final, no es necesario hacer scroll
      if (maxOffset - currentOffset < viewportHeight * 0.2) {
        debugPrint('⚠️ Already at the end of content, no scroll needed');
        return;
      }

      // Calcular un desplazamiento adaptativo basado en el tamaño de la pantalla
      // y la posición actual
      final screenHeight = MediaQuery.of(context).size.height;
      final scrollAmount =
          screenHeight * 0.4; // 40% de la altura de la pantalla

      final targetOffset = currentOffset + scrollAmount;
      final safeOffset = targetOffset.clamp(0.0, maxOffset);

      debugPrint(
          '📏 Current: $currentOffset, Max: $maxOffset, Target: $safeOffset');
      debugPrint('📱 Screen height: $screenHeight, Viewport: $viewportHeight');

      // Realizar el scroll con animación
      _scrollController.animateTo(
        safeOffset,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
      );

      debugPrint(
          '🔄 Scrolling after continuation: $currentOffset -> $safeOffset');
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _controller.dispose();
    _storyProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _storyProvider,
      child: Consumer<StoryProvider>(
        builder: (context, provider, _) {
          debugPrint(
              '🔄 Building GeneratedStoryPage - isExpanded: ${provider.isExpanded}, isAtBottom: ${provider.isAtBottom}');
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () {
                  if (!provider.isSaved && !widget.isFromLibrary) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => ConfirmationDialog(
                        icon: Icons.warning_rounded,
                        iconColor: const Color(0xFFEF4444),
                        title: AppLocalizations.of(context)!.exitWithoutSaving,
                        message: AppLocalizations.of(context)!
                            .exitWithoutSavingMessage,
                        cancelText: AppLocalizations.of(context)!.cancel,
                        confirmText: AppLocalizations.of(context)!.exit,
                        onConfirm: () {
                          Navigator.pop(context); // Cerrar diálogo
                          Navigator.pop(context); // Volver atrás
                        },
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        await ShareStoryModal.show(
                          context,
                          widget.story,
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.share_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: provider.isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        )
                      : Icon(
                          provider.isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          color: provider.isSaved
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                  onPressed: provider.isSaving
                      ? null
                      : () async {
                          if (provider.isSaved) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => ConfirmationDialog(
                                icon: Icons.delete_outline,
                                iconColor: Colors.red,
                                title: AppLocalizations.of(context)!
                                    .deleteFromSaved,
                                message: AppLocalizations.of(context)!
                                    .deleteConfirmation,
                                cancelText:
                                    AppLocalizations.of(context)!.cancel,
                                confirmText:
                                    AppLocalizations.of(context)!.delete,
                                onConfirm: () async {
                                  Navigator.pop(context); // Cerrar diálogo
                                  await provider.deleteStory();
                                  if (mounted) {
                                    Navigator.pop(context); // Volver atrás
                                    widget.onStoryStateChanged
                                        ?.call(); // Actualizar biblioteca
                                    SnackBarUtils.show(
                                      context,
                                      message: AppLocalizations.of(context)!
                                          .storyDeletedSuccess,
                                      type: SnackBarType.success,
                                    );
                                  }
                                },
                              ),
                            );
                          } else {
                            final success = await provider.saveStory();
                            if (success && mounted) {
                              widget.onStoryStateChanged?.call();

                              // Marcar que hay una nueva historia guardada
                              final notificationProvider =
                                  context.read<NewStoryIndicatorProvider>();
                              if (provider.story?.id != null) {
                                await notificationProvider.markNewStoryAdded(
                                    provider.story!.id.toString());
                              }

                              SnackBarUtils.show(
                                context,
                                message: AppLocalizations.of(context)!
                                    .storySavedSuccess,
                                type: SnackBarType.success,
                              );
                            } else if (mounted) {
                              SnackBarUtils.show(
                                context,
                                message: AppLocalizations.of(context)!
                                    .storyDeleteError,
                                type: SnackBarType.error,
                              );
                            }
                          }
                        },
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SafeArea(
              bottom: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: AspectRatio(
                                  aspectRatio: 2 / 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child:
                                          widget.story.customImagePath != null
                                              ? Image.file(
                                                  File(widget
                                                      .story.customImagePath!),
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.asset(
                                                  widget.story.imageUrl,
                                                  fit: BoxFit.cover,
                                                ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _StoryDetails(
                                genre: widget.story.genre,
                                onStoryStateChanged:
                                    widget.onStoryStateChanged),
                            const SizedBox(height: 16),
                            _StoryContent(
                              storyKey: _storyKey,
                              scrollController: _scrollController,
                              onStartReading: () async {
                                if (!_hasIncrementedReadCount &&
                                    widget.onIncrementReadCount != null) {
                                  _hasIncrementedReadCount = true;
                                  widget.onIncrementReadCount!();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: provider.isExpanded && provider.isAtBottom
                ? ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FloatingActionButton.extended(
                        backgroundColor: AppColors.primary,
                        onPressed: provider.isContinuing
                            ? null
                            : () async {
                                debugPrint(
                                    '🔘 FAB pressed - Showing continue story dialog');

                                // Mostrar el diálogo de opciones de continuación
                                final result =
                                    await showDialog<Map<String, dynamic>>(
                                  context: context,
                                  builder: (context) =>
                                      const ContinueStoryDialog(),
                                );

                                if (result != null && mounted) {
                                  bool success = false;

                                  if (result['mode'] == 'automatic') {
                                    debugPrint(
                                        '🤖 Continuing story automatically');
                                    success = await provider.continueStory();
                                  } else if (result['mode'] == 'custom') {
                                    final direction =
                                        result['direction'] as String;
                                    debugPrint(
                                        '📝 Continuing story with direction: $direction');
                                    success = await provider
                                        .continueStoryWithDirection(direction);
                                  }

                                  if (success && mounted) {
                                    // Realizar scroll automático después de la continuación
                                    _scrollAfterContinuation();
                                    widget.onStoryStateChanged?.call();
                                    SnackBarUtils.show(
                                      context,
                                      message: AppLocalizations.of(context)!
                                          .storyContinuedSuccess,
                                      type: SnackBarType.success,
                                    );
                                  } else if (mounted) {
                                    SnackBarUtils.show(
                                      context,
                                      message: provider.error ??
                                          AppLocalizations.of(context)!
                                              .storyContinueError,
                                      type: SnackBarType.error,
                                    );
                                  }
                                }
                              },
                        icon: provider.isContinuing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.auto_stories,
                                color: Colors.white),
                        label: Text(
                          provider.isContinuing
                              ? AppLocalizations.of(context)!.continuing
                              : AppLocalizations.of(context)!.continueStory,
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}

class _StoryDetails extends StatelessWidget {
  final String genre;
  final VoidCallback? onStoryStateChanged;

  const _StoryDetails({
    required this.genre,
    this.onStoryStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();
    final rating = provider.rating;

    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.yourStory,
          style: const TextStyle(
            fontFamily: 'Playfair',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            RatingBar.builder(
              initialRating: rating,
              minRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 24,
              unratedColor: AppColors.accent.withOpacity(0.3),
              itemBuilder: (context, _) => const Icon(
                Icons.star_rounded,
                color: AppColors.accent,
              ),
              onRatingUpdate: (newRating) async {
                if (provider.isSaved) {
                  // Si la historia ya está guardada, actualizamos directamente en la base de datos
                  await provider.updateRating(newRating);
                  onStoryStateChanged?.call(); // Actualizamos la biblioteca
                } else {
                  // Si la historia no está guardada, solo actualizamos el rating en memoria
                  provider.setRating(newRating);
                }
              },
            ),
            const SizedBox(height: 4),
            Text(
              '${rating.toStringAsFixed(1)}/5.0',
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            _GenreChip(genre: GenreConstants.fromString(genre)),
            _GenreChip(
              genre: Genre.happy,
              label: '#${AppLocalizations.of(context)!.story}',
            ),
            _GenreChip(
              genre: Genre.happy,
              label: '#${AppLocalizations.of(context)!.memory}',
            ),
          ],
        ),
      ],
    );
  }
}

class _StoryContent extends StatefulWidget {
  final GlobalKey storyKey;
  final VoidCallback onStartReading;
  final ScrollController scrollController;

  const _StoryContent({
    required this.storyKey,
    required this.onStartReading,
    required this.scrollController,
  });

  @override
  State<_StoryContent> createState() => _StoryContentState();
}

class _StoryContentState extends State<_StoryContent> {
  bool _hasScrolled = false;

  void _handleExpand(bool isExpanded) {
    if (isExpanded && !_hasScrolled) {
      _hasScrolled = true;
      widget.onStartReading();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.storyKey.currentContext != null) {
          final context = widget.storyKey.currentContext!;
          final box = context.findRenderObject() as RenderBox;
          final offset = box.localToGlobal(Offset.zero);

          // Calculamos la posición actual del scroll
          final currentOffset = widget.scrollController.offset;
          // Calculamos la posición objetivo teniendo en cuenta el padding y la altura de la pantalla
          final targetOffset =
              offset.dy - MediaQuery.of(context).size.height * 0.3;
          // Calculamos la distancia total del scroll
          final scrollDistance = (targetOffset - currentOffset).abs();

          // Ajustamos la duración basada en la distancia para que sea más natural
          final duration = Duration(
            milliseconds: (scrollDistance * 0.5).clamp(800, 1200).toInt(),
          );

          widget.scrollController.animateTo(
            targetOffset,
            duration: duration,
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.select((StoryProvider p) => p.isExpanded);
    final story = context.select((StoryProvider p) => p.story!);
    final isMemoryExpanded =
        context.select((StoryProvider p) => p.isMemoryExpanded);

    // Solo ejecutamos el scroll cuando cambia isExpanded a true
    _handleExpand(isExpanded);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recuerdo Original',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(
                            ClipboardData(text: story.memory));
                        if (context.mounted) {
                          SnackBarUtils.show(
                            context,
                            message:
                                AppLocalizations.of(context)!.copiedToClipboard,
                            type: SnackBarType.success,
                            duration: const Duration(seconds: 2),
                          );
                        }
                      },
                      child: const Icon(
                        Icons.copy_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () =>
                      context.read<StoryProvider>().toggleMemoryExpanded(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Text(
                          story.memory,
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: isMemoryExpanded ? null : 1,
                          overflow:
                              isMemoryExpanded ? null : TextOverflow.ellipsis,
                        ),
                      ),
                      if (story.memory.length > 50)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: AnimatedCrossFade(
                            firstChild: Text(
                              AppLocalizations.of(context)!.seeMore,
                              style: const TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            secondChild: Text(
                              AppLocalizations.of(context)!.seeLess,
                              style: const TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            crossFadeState: isMemoryExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 200),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!isExpanded)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.read<StoryProvider>().toggleExpanded(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.startReading,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          if (isExpanded) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.generatedStory,
                  style: const TextStyle(
                    fontFamily: 'Playfair',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      // TODO: Implementar reproducción
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              key: widget.storyKey,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StoryContentText(content: story.content),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StoryContentText extends StatelessWidget {
  final String content;

  const _StoryContentText({required this.content});

  @override
  Widget build(BuildContext context) {
    // Obtener las partes procesadas del provider
    final provider = context.watch<StoryProvider>();
    final parts = provider.storyParts;

    if (parts.isEmpty) {
      // Si no hay partes procesadas (caso improbable), mostrar el texto completo
      return Text(
        content,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 16,
          height: 1.6,
          color: AppColors.textPrimary,
        ),
      );
    }

    // Si solo hay una parte (sin continuaciones), mostrar el texto normal
    if (parts.length == 1) {
      return Text(
        parts[0],
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 16,
          height: 1.6,
          color: AppColors.textPrimary,
        ),
      );
    }

    // Si hay continuaciones, construir un widget con separadores
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primera parte (historia original)
        Text(
          parts[0],
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 16,
            height: 1.6,
            color: AppColors.textPrimary,
          ),
        ),

        // Por cada continuación, agregar un separador y el texto
        for (int i = 1; i < parts.length; i++) ...[
          const SizedBox(height: 16),

          // Separador visual
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.accent.withOpacity(0.3),
                  width: 1,
                ),
                bottom: BorderSide(
                  color: AppColors.accent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              color: AppColors.accent.withOpacity(0.05),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_stories,
                  size: 16,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'Continuación ${i}',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Texto de la continuación
          Text(
            parts[i],
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 16,
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

class _GenreChip extends StatelessWidget {
  final Genre genre;
  final String? label;

  const _GenreChip({required this.genre, this.label});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label ??
            (genre.key == 'genreHappy'
                ? l10n.genreHappy
                : genre.key == 'genreSad'
                    ? l10n.genreSad
                    : genre.key == 'genreRomantic'
                        ? l10n.genreRomantic
                        : genre.key == 'genreNostalgic'
                            ? l10n.genreNostalgic
                            : genre.key == 'genreAdventure'
                                ? l10n.genreAdventure
                                : l10n.genreFamily),
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
