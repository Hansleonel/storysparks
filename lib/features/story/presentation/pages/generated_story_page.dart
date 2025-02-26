import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:storysparks/core/dependency_injection/service_locator.dart';
import 'package:storysparks/core/theme/app_colors.dart';
import 'package:storysparks/core/constants/genre_constants.dart';
import 'package:storysparks/features/story/domain/usecases/update_story_rating_usecase.dart';
import 'package:storysparks/features/story/domain/usecases/delete_story_usecase.dart';
import 'package:storysparks/features/story/domain/usecases/save_story_usecase.dart';
import 'package:storysparks/features/story/domain/usecases/update_story_status_usecase.dart';
import 'package:storysparks/features/story/domain/usecases/continue_story_usecase.dart';
import 'package:storysparks/features/story/domain/usecases/get_story_by_id_usecase.dart';
import '../../domain/entities/story.dart';
import '../providers/story_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

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
    debugPrint('🔢 Continuation Count: ${widget.story.continuationCount}\n');
    debugPrint('📊 ID: ${widget.story.id}\n');
    debugPrint('📊 Rating: ${widget.story.rating}\n');
    debugPrint('🏁 ========================== 🏁\n');
    _initializeProviderAndAnimations();

    // Recargar la historia desde la base de datos después de la inicialización
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadStoryFromDatabase();
    });
  }

  void _initializeProviderAndAnimations() {
    _storyProvider = StoryProvider(
      updateRatingUseCase: getIt<UpdateStoryRatingUseCase>(),
      deleteStoryUseCase: getIt<DeleteStoryUseCase>(),
      saveStoryUseCase: getIt<SaveStoryUseCase>(),
      updateStoryStatusUseCase: getIt<UpdateStoryStatusUseCase>(),
      continueStoryUseCase: getIt<ContinueStoryUseCase>(),
      getStoryByIdUseCase: getIt<GetStoryByIdUseCase>(),
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

  Future<void> _reloadStoryFromDatabase() async {
    if (widget.story.id != null) {
      await _storyProvider.reloadStoryFromDatabase();
      debugPrint(
          '🔄 GeneratedStoryPage: Historia recargada desde la base de datos');
      debugPrint(
          '🔢 GeneratedStoryPage: Contador de continuaciones actualizado: ${_storyProvider.story?.continuationCount}');
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    _storyProvider.updateScrollPosition(
      _scrollController.position.maxScrollExtent,
      _scrollController.offset,
    );
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

          // Log para depuración del contador de continuaciones
          if (provider.story != null) {
            debugPrint(
                '📊 GeneratedStoryPage: Story ID: ${provider.story!.id}');
            debugPrint(
                '🔢 GeneratedStoryPage: Continuation Count: ${provider.story!.continuationCount}');
          }

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
                      builder: (context) => AlertDialog(
                        title: const Text(
                          '¿Salir sin guardar?',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        content: const Text(
                          'Esta historia es única y se perderá si sales sin guardarla. ¿Estás seguro de que quieres salir?',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Cerrar diálogo
                              Navigator.pop(context); // Volver atrás
                            },
                            child: const Text(
                              'Salir',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_outlined,
                      color: AppColors.textPrimary),
                  onPressed: () {
                    // TODO: Implementar compartir
                  },
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
                              builder: (context) => AlertDialog(
                                title: Text(
                                  AppLocalizations.of(context)!.deleteFromSaved,
                                  style: const TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: Text(
                                  AppLocalizations.of(context)!
                                      .deleteConfirmation,
                                  style: const TextStyle(
                                    fontFamily: 'Urbanist',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                        AppLocalizations.of(context)!.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await provider.deleteStory();
                                      if (mounted) {
                                        Navigator.pop(
                                            context); // Cerrar diálogo
                                        Navigator.pop(context); // Volver atrás
                                        widget.onStoryStateChanged
                                            ?.call(); // Actualizar biblioteca
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(context)!
                                                  .storyDeletedSuccess,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Urbanist',
                                              ),
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!.delete,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            final success = await provider.saveStory();
                            if (success && mounted) {
                              widget.onStoryStateChanged?.call();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!
                                        .storySavedSuccess,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!
                                        .storyDeleteError,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
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
                                debugPrint('🔘 FAB pressed - Continuing story');
                                debugPrint(
                                    '📊 Before continuation - Story ID: ${provider.story!.id}');
                                debugPrint(
                                    '🔢 Before continuation - Continuation Count: ${provider.story!.continuationCount}');

                                final success = await provider.continueStory();

                                if (success && mounted) {
                                  debugPrint('✅ Continuation successful');
                                  debugPrint(
                                      '📊 After continuation - Story ID: ${provider.story!.id}');
                                  debugPrint(
                                      '🔢 After continuation - Continuation Count: ${provider.story!.continuationCount}');

                                  // Asegurarse de que la historia se recargue desde la base de datos
                                  await provider.reloadStoryFromDatabase();
                                  debugPrint(
                                      '🔄 Historia recargada después de la continuación');
                                  debugPrint(
                                      '🔢 Contador de continuaciones después de recargar: ${provider.story!.continuationCount}');

                                  widget.onStoryStateChanged?.call();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(context)!
                                            .storyContinuedSuccess,
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontFamily: 'Urbanist',
                                        ),
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                } else if (mounted) {
                                  debugPrint('❌ Continuation failed');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        provider.error ??
                                            AppLocalizations.of(context)!
                                                .storyContinueError,
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontFamily: 'Urbanist',
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
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
    final story = provider.story!;

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
            if (story.continuationCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message:
                          'Número de veces que esta historia ha sido continuada',
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.auto_stories,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          if (story.continuationCount > 1)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 10,
                                  minHeight: 10,
                                ),
                                child: Text(
                                  story.continuationCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${story.continuationCount == 1 ? 'Continuada' : 'Continuada ${story.continuationCount} veces'}',
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
                const Text(
                  'Recuerdo Original',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
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
                Row(
                  children: [
                    _CopyButton(content: story.content),
                    const SizedBox(width: 12),
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
    // Buscar las marcas de continuación en el contenido
    final parts = content.split('\n\n--- Continuación ---\n\n');

    if (parts.length <= 1) {
      // Si no hay continuaciones, mostrar el texto normal
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

class _CopyButton extends StatelessWidget {
  final String content;

  const _CopyButton({required this.content});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: provider.isCopied
            ? AppColors.success.withOpacity(0.1)
            : AppColors.primary.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: (provider.isCopied ? AppColors.success : AppColors.primary)
                .withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          provider.isCopied ? Icons.check_rounded : Icons.content_copy_rounded,
          size: 20,
          color: provider.isCopied ? AppColors.success : AppColors.primary,
        ),
        onPressed: () {
          provider.copyStoryToClipboard();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Historia copiada al portapapeles',
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                ),
              ),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }
}
