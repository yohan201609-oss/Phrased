import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_localizations.dart';
import '../core/locale_service.dart';
import '../services/usage_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final VoidCallback onLocaleToggle;
  final Locale currentLocale;

  const OnboardingScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.onLocaleToggle,
    required this.currentLocale,
  });

  Future<void> _handleGetStarted(BuildContext context) async {
    await UsageService.setOnboardingSeen();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            onThemeToggle: onThemeToggle,
            isDarkMode: isDarkMode,
            onLocaleToggle: onLocaleToggle,
            currentLocale: currentLocale,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          // Botón de cambio de idioma mejorado
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onLocaleToggle,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.grey[900]?.withOpacity(0.5)
                        : Colors.grey[100]?.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark 
                          ? Colors.grey[700]!.withOpacity(0.3)
                          : Colors.grey[300]!.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.language_rounded,
                        size: 18,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentLocale == LocaleService.spanish ? 'ES' : 'EN',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 22,
            ),
            onPressed: onThemeToggle,
            tooltip: isDarkMode ? l10n.lightMode : l10n.darkMode,
            color: isDark ? Colors.white : Colors.black,
            padding: const EdgeInsets.all(12),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo y Título
              Column(
                children: [
                  const SizedBox(height: 20),
                  // Logo centrado
                  Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icons/icon.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Título
                  Text(
                    l10n.welcomeToPhrased,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // Pasos
              Column(
                children: [
                  _buildStep(
                    context: context,
                    icon: Icons.edit_outlined,
                    text: l10n.onboardingStep1,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),
                  _buildStep(
                    context: context,
                    icon: Icons.palette_outlined,
                    text: l10n.onboardingStep2,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),
                  _buildStep(
                    context: context,
                    icon: Icons.auto_awesome,
                    text: l10n.onboardingStep3,
                    isDark: isDark,
                  ),
                ],
              ),

              // Botón
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleGetStarted(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.getStarted,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required BuildContext context,
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey[900]
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.white : Colors.black,
            size: 24,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

