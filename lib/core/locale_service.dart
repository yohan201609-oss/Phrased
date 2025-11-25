import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const String _localeKey = 'app_locale';
  static const Locale spanish = Locale('es');
  static const Locale english = Locale('en');

  static Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    
    if (localeCode == 'en') {
      return english;
    }
    return spanish; // Por defecto español
  }

  static Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  static Locale toggleLocale(Locale currentLocale) {
    return currentLocale == spanish ? english : spanish;
  }
}

