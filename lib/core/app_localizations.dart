import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Títulos y textos principales
  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get credits => _localizedValues[locale.languageCode]!['credits']!;
  String get restart => _localizedValues[locale.languageCode]!['restart']!;
  String get whatDoYouWantToExpress => _localizedValues[locale.languageCode]!['whatDoYouWantToExpress']!;
  String get addImage => _localizedValues[locale.languageCode]!['addImage']!;
  String get tone => _localizedValues[locale.languageCode]!['tone']!;
  String get length => _localizedValues[locale.languageCode]!['length']!;
  String get rephrase => _localizedValues[locale.languageCode]!['rephrase']!;
  String get results => _localizedValues[locale.languageCode]!['results']!;
  
  // Mensajes
  String get creditsReset => _localizedValues[locale.languageCode]!['creditsReset']!;
  String get pleaseEnterTextOrImage => _localizedValues[locale.languageCode]!['pleaseEnterTextOrImage']!;
  String get dailyLimitReached => _localizedValues[locale.languageCode]!['dailyLimitReached']!;
  String get copiedToClipboard => _localizedValues[locale.languageCode]!['copiedToClipboard']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  
  // Diálogo de imagen
  String get selectImage => _localizedValues[locale.languageCode]!['selectImage']!;
  String get takePhoto => _localizedValues[locale.languageCode]!['takePhoto']!;
  String get chooseFromGallery => _localizedValues[locale.languageCode]!['chooseFromGallery']!;
  String get errorTakingPhoto => _localizedValues[locale.languageCode]!['errorTakingPhoto']!;
  String get errorSelectingImage => _localizedValues[locale.languageCode]!['errorSelectingImage']!;
  String get removeAll => _localizedValues[locale.languageCode]!['removeAll']!;
  
  // Temas
  String get lightMode => _localizedValues[locale.languageCode]!['lightMode']!;
  String get darkMode => _localizedValues[locale.languageCode]!['darkMode']!;
  
  // Onboarding
  String get welcomeToPhrased => _localizedValues[locale.languageCode]!['welcomeToPhrased']!;
  String get onboardingStep1 => _localizedValues[locale.languageCode]!['onboardingStep1']!;
  String get onboardingStep2 => _localizedValues[locale.languageCode]!['onboardingStep2']!;
  String get onboardingStep3 => _localizedValues[locale.languageCode]!['onboardingStep3']!;
  String get getStarted => _localizedValues[locale.languageCode]!['getStarted']!;
  
  // Tonos
  List<String> get tones {
    if (locale.languageCode == 'en') {
      return ['Witty', 'Professional', 'Minimalist', 'Emotional'];
    }
    return ['Ingenioso', 'Profesional', 'Minimalista', 'Emotivo'];
  }
  
  // Longitudes
  List<String> get lengths {
    if (locale.languageCode == 'en') {
      return ['Short', 'Long'];
    }
    return ['Corto', 'Largo'];
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'es': {
      'appTitle': 'Phrased',
      'credits': 'Créditos',
      'restart': 'Reiniciar',
      'whatDoYouWantToExpress': '¿Qué quieres expresar hoy?',
      'addImage': 'Agregar imagen',
      'tone': 'Tono:',
      'length': 'Longitud:',
      'rephrase': 'Generar post',
      'results': 'Resultados:',
      'creditsReset': 'Créditos reiniciados',
      'pleaseEnterTextOrImage': 'Por favor, ingresa un texto o selecciona una imagen',
      'dailyLimitReached': 'Has alcanzado el límite diario de 2 usos',
      'copiedToClipboard': 'Copiado al portapapeles',
      'error': 'Error',
      'selectImage': 'Seleccionar imagen',
      'takePhoto': 'Tomar foto',
      'chooseFromGallery': 'Elegir de galería',
      'errorTakingPhoto': 'Error al tomar foto',
      'errorSelectingImage': 'Error al seleccionar imagen',
      'removeAll': 'Eliminar todas',
      'lightMode': 'Modo claro',
      'darkMode': 'Modo oscuro',
      'welcomeToPhrased': 'Bienvenido a Phrased',
      'onboardingStep1': 'Expresa tu idea o sube una foto.',
      'onboardingStep2': 'Elige el tono perfecto para tu audiencia.',
      'onboardingStep3': 'Obtén captions virales generados por IA.',
      'getStarted': 'Comenzar',
    },
    'en': {
      'appTitle': 'Phrased',
      'credits': 'Credits',
      'restart': 'Restart',
      'whatDoYouWantToExpress': 'What do you want to express today?',
      'addImage': 'Add image',
      'tone': 'Tone:',
      'length': 'Length:',
      'rephrase': 'Generate post',
      'results': 'Results:',
      'creditsReset': 'Credits reset',
      'pleaseEnterTextOrImage': 'Please enter text or select an image',
      'dailyLimitReached': 'You have reached the daily limit of 2 uses',
      'copiedToClipboard': 'Copied to clipboard',
      'error': 'Error',
      'selectImage': 'Select image',
      'takePhoto': 'Take photo',
      'chooseFromGallery': 'Choose from gallery',
      'errorTakingPhoto': 'Error taking photo',
      'errorSelectingImage': 'Error selecting image',
      'removeAll': 'Remove all',
      'lightMode': 'Light mode',
      'darkMode': 'Dark mode',
      'welcomeToPhrased': 'Welcome to Phrased',
      'onboardingStep1': 'Express your idea or upload a photo.',
      'onboardingStep2': 'Choose the perfect tone for your audience.',
      'onboardingStep3': 'Get viral AI-generated captions.',
      'getStarted': 'Get Started',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

