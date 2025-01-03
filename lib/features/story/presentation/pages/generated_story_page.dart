import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:storysparks/core/theme/app_colors.dart';
import '../../domain/entities/story.dart';
import '../providers/story_provider.dart';

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

class _GeneratedStoryPageState extends State<GeneratedStoryPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _storyKey = GlobalKey();
  bool _hasIncrementedReadCount = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToStory() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final context = _storyKey.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        final offset = box.localToGlobal(Offset.zero);

        _scrollController.animateTo(
          offset.dy - MediaQuery.of(context).size.height * 0.1,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoryProvider()
        ..setStory(widget.story, isFromLibrary: widget.isFromLibrary),
      child: Builder(
        builder: (context) {
          final provider = context.watch<StoryProvider>();

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
                  icon: Icon(
                    provider.isSaving
                        ? Icons.sync
                        : (provider.isSaved
                            ? Icons.bookmark
                            : Icons.bookmark_outline),
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
                                title: const Text(
                                  'Eliminar de guardados',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: const Text(
                                  '¿Estás seguro de que quieres eliminar esta historia de tus guardados?',
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
                                      provider.unsaveStory();
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Historia eliminada de guardados',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Eliminar',
                                      style: TextStyle(
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
                                const SnackBar(
                                  content: Text(
                                    'Historia guardada correctamente',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Error al guardar la historia',
                                    style: TextStyle(color: AppColors.white),
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
                                      child: Image.asset(
                                        _getHeaderImage(widget.story.genre),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _StoryDetails(genre: widget.story.genre),
                            const SizedBox(height: 16),
                            _StoryContent(
                              storyKey: _storyKey,
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
          );
        },
      ),
    );
  }

  String _getHeaderImage(String genre) {
    switch (genre.toLowerCase()) {
      case 'feliz':
        return 'assets/images/happiness.png';
      case 'romántico':
        return 'assets/images/romantic.png';
      case 'nostálgico':
        return 'assets/images/nostalgic.png';
      case 'aventura':
        return 'assets/images/adventure.png';
      case 'familiar':
        return 'assets/images/familiar.png';
      case 'triste':
        return 'assets/images/sadness.png';
      default:
        return 'assets/images/nostalgic.png';
    }
  }
}

class _StoryDetails extends StatelessWidget {
  final String genre;

  const _StoryDetails({
    required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    final rating = context.watch<StoryProvider>().rating;

    return Column(
      children: [
        Text(
          'Tu Historia',
          style: const TextStyle(
            fontFamily: 'Playfair',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: AppColors.accent,
                size: 20,
              );
            }),
            const SizedBox(width: 8),
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
            _GenreChip(genre: genre),
            _GenreChip(genre: 'historia'),
            _GenreChip(genre: 'recuerdo'),
          ],
        ),
      ],
    );
  }
}

class _StoryContent extends StatefulWidget {
  final GlobalKey storyKey;
  final VoidCallback onStartReading;

  const _StoryContent({
    required this.storyKey,
    required this.onStartReading,
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
          Scrollable.ensureVisible(
            widget.storyKey.currentContext!,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            alignment: 0.1,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.select((StoryProvider p) => p.isExpanded);
    final story = context.select((StoryProvider p) => p.story!);

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
                Text(
                  story.memory,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                child: const Text(
                  'Empezar a leer',
                  style: TextStyle(
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
                const Text(
                  'Historia Generada',
                  style: TextStyle(
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
              child: Text(
                story.content,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String genre;

  const _GenreChip({required this.genre});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '#$genre',
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
