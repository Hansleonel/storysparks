import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:storysparks/core/dependency_injection/service_locator.dart';
import 'package:storysparks/core/routes/app_routes.dart';
import 'package:storysparks/features/auth/domain/usecases/login_usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:storysparks/features/auth/presentation/pages/login_page.dart';
import 'package:storysparks/features/auth/presentation/providers/auth_provider.dart';
import 'package:storysparks/features/library/presentation/providers/library_provider.dart';
import 'package:storysparks/features/profile/domain/repositories/story_repository.dart';
import 'package:storysparks/features/profile/presentation/providers/story_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
            getIt<SignOutUseCase>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LibraryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StoryProvider(getIt<StoryRepository>()),
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
