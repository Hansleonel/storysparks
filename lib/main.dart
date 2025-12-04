import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:memorysparks/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:memorysparks/features/story/domain/usecases/update_story_status_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memorysparks/core/dependency_injection/service_locator.dart';
import 'package:memorysparks/core/routes/app_routes.dart';
import 'package:memorysparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:memorysparks/features/auth/domain/usecases/login_usecase.dart';
import 'package:memorysparks/features/auth/domain/usecases/register_usecase.dart';
import 'package:memorysparks/features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:memorysparks/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:memorysparks/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:memorysparks/features/auth/presentation/pages/login_page.dart';
import 'package:memorysparks/features/auth/presentation/providers/auth_provider.dart';
import 'package:memorysparks/features/library/presentation/providers/library_provider.dart';
import 'package:memorysparks/features/navigation/presentation/pages/main_navigation.dart';
import 'package:memorysparks/features/story/domain/usecases/delete_story_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/save_story_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/update_story_rating_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/continue_story_usecase.dart';
import 'package:memorysparks/features/story/presentation/providers/story_provider.dart';
import 'package:memorysparks/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:memorysparks/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/delete_all_stories_for_user_usecase.dart';
import 'package:memorysparks/core/providers/new_story_indicator_provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio background service
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.memorysparks.audio',
    androidNotificationChannelName: 'Story Audio',
    androidNotificationOngoing: true,
  );

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  setupServiceLocator();

  // Check for existing session BEFORE building the app
  // This is instant since Supabase already loaded tokens from local storage
  final hasSession = Supabase.instance.client.auth.currentUser != null;
  debugPrint('🔍 Main: Session check - hasSession: $hasSession');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            getIt<LoginUseCase>(),
            getIt<SignInWithAppleUseCase>(),
            getIt<SignInWithGoogleUseCase>(),
            getIt<SignOutUseCase>(),
            getIt<RegisterUseCase>(),
            getIt<DeleteAccountUseCase>(),
            getIt<DeleteAllStoriesForUserUseCase>(),
            getIt<SubscriptionProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LibraryProvider(getIt<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => StoryProvider(
            updateRatingUseCase: getIt<UpdateStoryRatingUseCase>(),
            deleteStoryUseCase: getIt<DeleteStoryUseCase>(),
            saveStoryUseCase: getIt<SaveStoryUseCase>(),
            updateStoryStatusUseCase: getIt<UpdateStoryStatusUseCase>(),
            continueStoryUseCase: getIt<ContinueStoryUseCase>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<SubscriptionProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => NewStoryIndicatorProvider(),
        ),
      ],
      child: MyApp(hasSession: hasSession),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool hasSession;

  const MyApp({super.key, required this.hasSession});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize AuthProvider with existing session if available
    if (widget.hasSession) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AuthProvider>().initializeFromExistingSession();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemorySparks',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Navigate directly to MainNavigation if session exists
      home: widget.hasSession ? const MainNavigation() : const LoginPage(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
    );
  }
}
