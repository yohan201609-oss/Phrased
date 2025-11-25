import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class UsageService {
  static Future<int> getDailyUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(AppConstants.lastUsageDateKey);
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // Si es un nuevo día, resetear el contador
    if (lastDate != today) {
      await prefs.setString(AppConstants.lastUsageDateKey, today);
      await prefs.setInt(AppConstants.usageKey, 0);
      return 0;
    }
    
    return prefs.getInt(AppConstants.usageKey) ?? 0;
  }

  static Future<bool> canUse() async {
    final credits = await getRemainingCredits();
    return credits > 0;
  }

  static Future<void> incrementUsage() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Primero verificar y resetear si es necesario (atomicidad)
    final lastDate = prefs.getString(AppConstants.lastUsageDateKey);
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // Si es un nuevo día, resetear el contador primero
    if (lastDate != today) {
      await prefs.setString(AppConstants.lastUsageDateKey, today);
      await prefs.setInt(AppConstants.usageKey, 0);
    }
    
    // Obtener valores actualizados después del posible reseteo
    final currentUsage = prefs.getInt(AppConstants.usageKey) ?? 0;
    final bonusCredits = prefs.getInt('bonus_credits') ?? 0;
    
    // Si hay créditos bonificados, consumirlos primero
    if (bonusCredits > 0) {
      await prefs.setInt('bonus_credits', bonusCredits - 1);
    } else {
      // Si no hay bonificados, consumir del límite diario
      // Validar que no exceda el límite
      if (currentUsage < AppConstants.dailyLimit) {
        await prefs.setInt(AppConstants.usageKey, currentUsage + 1);
      }
    }
  }

  static Future<int> getRemainingCredits() async {
    final prefs = await SharedPreferences.getInstance();
    final usage = await getDailyUsage();
    final bonusCredits = prefs.getInt('bonus_credits') ?? 0;
    // Los créditos bonificados permiten superar el límite diario
    final remaining = (AppConstants.dailyLimit - usage) + bonusCredits;
    // Asegurar que nunca sea negativo
    return remaining < 0 ? 0 : remaining;
  }

  // Agrega créditos bonificados (pueden superar el límite diario)
  static Future<void> addBonusCredits(int amount) async {
    if (amount <= 0) return; // Validar que el monto sea positivo
    final prefs = await SharedPreferences.getInstance();
    final currentBonus = prefs.getInt('bonus_credits') ?? 0;
    await prefs.setInt('bonus_credits', currentBonus + amount);
  }

  // Reinicia los créditos disponibles al máximo
  static Future<void> resetCredits() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // Reseteamos el contador de usos a 0 y actualizamos la fecha
    await prefs.setInt(AppConstants.usageKey, 0);
    await prefs.setString(AppConstants.lastUsageDateKey, today);
  }

  // Fuerza un reseteo inmediato de créditos (útil para cambios de política)
  static Future<void> forceResetCredits() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // Forzamos el reseteo a 0 independientemente de la fecha
    await prefs.setInt(AppConstants.usageKey, 0);
    await prefs.setString(AppConstants.lastUsageDateKey, today);
  }

  // Onboarding
  static const String _seenOnboardingKey = 'seen_onboarding';

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenOnboardingKey) ?? false;
  }

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenOnboardingKey, true);
  }
}

