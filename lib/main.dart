import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/theme.dart';
import 'core/locale_service.dart';
import 'core/app_localizations.dart';
import 'services/usage_service.dart';
import 'ui/home_screen.dart';
import 'ui/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar Google Mobile Ads solo en plataformas móviles (no en web)
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }
  runApp(const PhrasedApp());
}

class PhrasedApp extends StatefulWidget {
  const PhrasedApp({super.key});

  @override
  State<PhrasedApp> createState() => _PhrasedAppState();
}

class _PhrasedAppState extends State<PhrasedApp> {
  bool _isDarkMode = false;
  Locale _locale = LocaleService.spanish;
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final locale = await LocaleService.getLocale();
      final hasSeenOnboarding = await UsageService.hasSeenOnboarding();

      // El reseteo diario se maneja automáticamente en getDailyUsage()
      // No es necesario forzar reseteo en cada inicio

      if (mounted) {
        setState(() {
          _locale = locale;
          _hasSeenOnboarding = hasSeenOnboarding;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Si hay un error durante la inicialización, mostrar la app de todas formas
      print('Error durante inicialización: $e');
      if (mounted) {
        setState(() {
          _locale = LocaleService.spanish;
          _hasSeenOnboarding = false;
          _isLoading = false;
        });
      }
    }
  }

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void toggleLocale() async {
    final newLocale = LocaleService.toggleLocale(_locale);
    await LocaleService.setLocale(newLocale);
    setState(() {
      _locale = newLocale;
    });
  }

  Widget _buildHome() {
    if (_hasSeenOnboarding) {
      return HomeScreen(
        onThemeToggle: toggleTheme,
        isDarkMode: _isDarkMode,
        onLocaleToggle: toggleLocale,
        currentLocale: _locale,
      );
    } else {
      return OnboardingScreen(
        onThemeToggle: toggleTheme,
        isDarkMode: _isDarkMode,
        onLocaleToggle: toggleLocale,
        currentLocale: _locale,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        title: 'Phrased',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('en', 'US'),
          Locale('es'), // Fallback para español
          Locale('en'), // Fallback para inglés
        ],
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Phrased',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [LocaleService.spanish, LocaleService.english],
      home: _buildHome(),
    );
  }
}
