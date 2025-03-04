import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:storysparks/features/story/domain/usecases/update_story_status_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:storysparks/core/dependency_injection/service_locator.dart';
import 'package:storysparks/core/routes/app_routes.dart';
import 'package:storysparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:storysparks/features/auth/domain/usecases/login_usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/register_usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:storysparks/features/auth/presentation/pages/login_page.dart';
import 'package:storysparks/features/auth/presentation/providers/auth_provider.dart';
import 'package:storysparks/features/library/presentation/providers/library_provider.dart';
import 'package:storysparks/features/story/domain/usecases/delete_story_usecase.dart';
import 'package:storysparks/features/story/domain/usecases/save_story_usecase.dart';
import 'package:storysparks/features/story/domain/usecases/update_story_rating_usecase.dart';
import 'package:storysparks/features/story/domain/usecases/continue_story_usecase.dart';
import 'package:storysparks/features/story/presentation/providers/story_provider.dart';
import 'package:storysparks/features/subscription/presentation/providers/subscription_provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  setupServiceLocator();

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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StorySparks',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
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
