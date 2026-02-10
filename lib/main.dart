import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/storage/preferences_service.dart';
import 'providers/user_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/language_provider.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/onboarding/language_selection_screen.dart';
import 'screens/onboarding/profile_setup_screen.dart';
import 'screens/home/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await PreferencesService.instance.initialize();

  runApp(const LingoNativeApp());
}

class LingoNativeApp extends StatelessWidget {
  const LingoNativeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: MaterialApp(
        title: 'LingoNative AI',
        debugShowCheckedModeBanner: false,
        
        // Theme
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // Localization
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
          Locale('ne'),
          Locale('zh'),
          Locale('fr'),
          Locale('es'),
          Locale('ja'),
          Locale('ar'),
          Locale('de'),
          Locale('ko'),
          Locale('ru'),
          Locale('pt'),
          Locale('it'),
        ],

        // Navigation
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/welcome': (context) => const WelcomeScreen(),
          '/language-selection': (context) => const LanguageSelectionScreen(),
          '/profile-setup': (context) => const ProfileSetupScreen(),
          '/chat': (context) => const ChatScreen(),
        },
      ),
    );
  }
}

/// Splash Screen - Determines initial route based on onboarding status
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Small delay for splash effect
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final prefs = PreferencesService.instance;
    final userProvider = context.read<UserProvider>();

    // Load user profile
    await userProvider.loadProfile();

    if (!mounted) return;

    // Determine initial route
    if (userProvider.hasProfile) {
      // User has completed onboarding
      Navigator.of(context).pushReplacementNamed('/chat');
    } else if (prefs.isFirstLaunch) {
      // First time user
      Navigator.of(context).pushReplacementNamed('/welcome');
    } else {
      // Returning user but profile incomplete
      Navigator.of(context).pushReplacementNamed('/language-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            Text(
              'LingoNative AI',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Personal Language Tutor',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
