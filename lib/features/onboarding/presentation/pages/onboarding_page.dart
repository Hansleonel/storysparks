import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storysparks/core/routes/app_routes.dart';
import 'package:storysparks/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:storysparks/features/onboarding/presentation/widgets/progress_indicator.dart';
import 'package:storysparks/features/onboarding/presentation/widgets/memory_feature_card.dart';
import 'package:storysparks/features/onboarding/presentation/widgets/testimonial_card.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Reset the onboarding provider's current page when the onboarding page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OnboardingProvider>(context, listen: false);
      if (provider.currentPage != 0) {
        provider.resetCurrentPage();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<OnboardingProvider>(context);

    // Determine if we're on the third slide (index 2)
    final bool isThirdSlide = provider.currentPage == 2;

    return Container(
      decoration: BoxDecoration(
        // Apply romantic.png background image only for the third slide
        image: isThirdSlide
            ? const DecorationImage(
                image: AssetImage('assets/images/romantic.png'),
                fit: BoxFit.cover,
              )
            : null,
        // Enhanced gradient that maintains app style but looks more polished
        gradient: isThirdSlide
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.1, 0.4, 0.8],
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.65),
                  Colors.black.withOpacity(0.5),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.4, 1.0],
                colors: const [
                  Color(0xFF6E5FFC), // Slightly deeper purple at top-left
                  Color(0xFF7A79F9), // Original purple in the middle
                  Color(0xFF504FF6), // Original deep purple at bottom-right
                ],
              ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              OnboardingProgressIndicator(
                progress: (provider.currentPage + 1) / 3,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const ClampingScrollPhysics(),
                  onPageChanged: (index) {
                    provider.setCurrentPage(index);
                  },
                  children: const [
                    _CongratulationsPage(),
                    _TestimonialsPage(),
                    _GoalSurveyPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          decoration: BoxDecoration(
            color: isThirdSlide
                ? Colors.black.withOpacity(0.2)
                : Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              if (provider.currentPage < 2) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                provider.completeOnboarding().then((_) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: isThirdSlide
                  ? Colors.black.withOpacity(0.9)
                  : const Color(0xFF504FF6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  provider.currentPage < 2 ? l10n.next : l10n.getStarted,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CongratulationsPage extends StatelessWidget {
  const _CongratulationsPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context).languageCode;

    // Choose the appropriate icon based on the current locale
    final String congratulationsIcon = currentLocale == 'en'
        ? 'assets/icons/congratulations_en_icon.svg'
        : 'assets/icons/congratulations_es_icon.svg';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              congratulationsIcon,
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 32),
            MemoryFeatureCard(
              title: l10n.featureMemories,
              icon: 'assets/icons/feature_memory.svg',
              backgroundImage: 'assets/images/romantic.png',
            ),
            MemoryFeatureCard(
              title: l10n.featureStyle,
              icon: 'assets/icons/feature_style.svg',
              backgroundImage: 'assets/images/nostalgic.png',
            ),
            MemoryFeatureCard(
              title: l10n.featureShare,
              icon: 'assets/icons/feature_share.svg',
              backgroundImage: 'assets/images/happiness.png',
            ),
            MemoryFeatureCard(
              title: l10n.featureAI,
              icon: 'assets/icons/feature_ai.svg',
              backgroundImage: 'assets/images/adventure.png',
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalSurveyPage extends StatelessWidget {
  const _GoalSurveyPage({Key? key}) : super(key: key);

  String _getLocalizedGoal(BuildContext context, GoalType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case GoalType.transformMemories:
        return l10n.goalTransformMemories;
      case GoalType.createStories:
        return l10n.goalCreateStories;
      case GoalType.improveWriting:
        return l10n.goalImproveWriting;
      case GoalType.exploreIdeas:
        return l10n.goalExploreIdeas;
      case GoalType.other:
        return l10n.goalOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            l10n.whatIsYourGoal,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontFamily: 'Playfair',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: Consumer<OnboardingProvider>(
              builder: (context, provider, _) {
                return Column(
                  children: provider.availableGoalTypes.map((type) {
                    final isSelected = provider.selectedGoalType == type;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => provider.setGoalType(type),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: const [0.0, 0.6, 1.0],
                                colors: isSelected
                                    ? [
                                        Colors.black.withOpacity(0.65),
                                        Colors.black.withOpacity(0.45),
                                        Colors.black.withOpacity(0.3),
                                      ]
                                    : [
                                        Colors.black.withOpacity(0.5),
                                        Colors.black.withOpacity(0.35),
                                        Colors.black.withOpacity(0.2),
                                      ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(isSelected ? 0.4 : 0.3),
                                  blurRadius: isSelected ? 10 : 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _getLocalizedGoal(context, type),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Urbanist',
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                      shadows: const [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                          color: Colors.black45,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TestimonialsPage extends StatefulWidget {
  const _TestimonialsPage();

  @override
  State<_TestimonialsPage> createState() => _TestimonialsPageState();
}

class _TestimonialsPageState extends State<_TestimonialsPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'Sofía',
      'age': '27',
      'profession': 'Diseñadora Gráfica',
      'messageKey': 'testimonialLoveStory',
      'rating': 5,
    },
    {
      'name': 'Lucía',
      'age': '22',
      'profession': 'Ingeniera Civil',
      'messageKey': 'testimonialGrandmaTrip',
      'rating': 5,
    },
    {
      'name': 'Diego',
      'age': '20',
      'profession': 'Estudiante',
      'messageKey': 'testimonialChildhoodMemory',
      'rating': 5,
    },
    {
      'name': 'Valentina',
      'age': '19',
      'profession': 'Estudiante',
      'messageKey': 'testimonialUniversityDay',
      'rating': 5,
    },
    {
      'name': 'Mateo',
      'age': '24',
      'profession': 'Estudiante',
      'messageKey': 'testimonialSouthAmericaTrip',
      'rating': 4,
    },
    {
      'name': 'Carmen',
      'age': '35',
      'profession': 'Escritora',
      'messageKey': 'testimonialWriterMemories',
      'rating': 5,
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        autoScroll();
      }
    });
  }

  void autoScroll() {
    if (!mounted) return;

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;

      if (currentScroll >= maxScroll) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.animateTo(
          currentScroll + 80,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }

      autoScroll();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                const Color(0xFF6E5FFC).withOpacity(0.25),
                const Color(0xFF7A79F9).withOpacity(0.2),
                const Color(0xFF504FF6).withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            l10n.testimonialsSectionTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontFamily: 'Playfair',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: _testimonials.length,
            itemBuilder: (context, index) {
              final testimonial = _testimonials[index];
              final l10n = AppLocalizations.of(context)!;

              // Determinar la clave de traducción para la profesión
              String? professionKey;
              switch (testimonial['profession']) {
                case 'Diseñadora Gráfica':
                  professionKey = 'professionGraphicDesigner';
                  break;
                case 'Ingeniera Civil':
                  professionKey = 'professionCivilEngineer';
                  break;
                case 'Estudiante':
                  professionKey = 'professionStudent';
                  break;
                case 'Escritora':
                  professionKey = 'professionWriter';
                  break;
              }

              // Obtener el mensaje traducido
              final messageKey = testimonial['messageKey'];
              final translatedMessage =
                  _getTestimonialMessage(l10n, messageKey);

              // Obtener la traducción de la profesión si existe una clave
              final translatedProfession = professionKey != null
                  ? _getTranslation(l10n, professionKey)
                  : testimonial['profession'];

              return TestimonialCard(
                name: testimonial['name'],
                message: translatedMessage,
                rating: testimonial['rating'],
                profession: translatedProfession,
                age: testimonial['age'],
              );
            },
          ),
        ),
      ],
    );
  }

  // Método auxiliar para obtener traducciones de manera segura
  String? _getTranslation(AppLocalizations l10n, String key) {
    try {
      switch (key) {
        case 'professionGraphicDesigner':
          return l10n.professionGraphicDesigner;
        case 'professionCivilEngineer':
          return l10n.professionCivilEngineer;
        case 'professionStudent':
          return l10n.professionStudent;
        case 'professionWriter':
          return l10n.professionWriter;
        default:
          return null;
      }
    } catch (e) {
      print('Error getting translation for $key: $e');
      return null;
    }
  }

  // Método auxiliar para obtener los mensajes de testimonios traducidos
  String _getTestimonialMessage(AppLocalizations l10n, String key) {
    try {
      switch (key) {
        case 'testimonialLoveStory':
          return l10n.testimonialLoveStory;
        case 'testimonialGrandmaTrip':
          return l10n.testimonialGrandmaTrip;
        case 'testimonialChildhoodMemory':
          return l10n.testimonialChildhoodMemory;
        case 'testimonialUniversityDay':
          return l10n.testimonialUniversityDay;
        case 'testimonialSouthAmericaTrip':
          return l10n.testimonialSouthAmericaTrip;
        case 'testimonialWriterMemories':
          return l10n.testimonialWriterMemories;
        default:
          return "No message found";
      }
    } catch (e) {
      print('Error getting testimonial message for $key: $e');
      return "Error loading message";
    }
  }
}
