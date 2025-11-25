import 'dart:io' if (dart.library.html) 'dart:html' as io;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants.dart';
import '../core/app_localizations.dart';
import '../core/locale_service.dart';
import '../services/api_service.dart';
import '../services/usage_service.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final VoidCallback onLocaleToggle;
  final Locale currentLocale;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.onLocaleToggle,
    required this.currentLocale,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedTone;
  String? _selectedLength;
  bool _isLoading = false;
  List<String> _captions = [];
  int _remainingCredits = 0; // Se inicializa en 0 y se carga desde el servicio
  List<String> _selectedImagePaths = [];
  List<XFile> _selectedImageFiles = [];
  
  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  
  // Rewarded Ad
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadCredits();
    // Solo cargar anuncios en plataformas móviles (no en web)
    if (!kIsWeb) {
      _loadBannerAd();
      _loadRewardedAd();
    }
  }
  
  void _loadBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdReady = false;
    
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Ad Unit ID de Prueba para Android
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted && _bannerAd == ad) {
            setState(() {
              _isBannerAdReady = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          print('Error al cargar el banner: $err');
          if (mounted) {
            setState(() {
              _isBannerAdReady = false;
            });
          }
          ad.dispose();
          if (_bannerAd == ad) {
            _bannerAd = null;
          }
        },
      ),
    );

    _bannerAd?.load();
  }
  
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // Ad Unit ID de Prueba para Android
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
            _isRewardedAdReady = true;
          });
          
          // Configurar callbacks para cuando se cierre el anuncio
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isRewardedAdReady = false;
              // Recargar un nuevo anuncio inmediatamente
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('Error al mostrar el anuncio bonificado: $error');
              ad.dispose();
              _isRewardedAdReady = false;
              // Recargar un nuevo anuncio
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Error al cargar el anuncio bonificado: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }
  
  void _showRewardedAd() {
    // Los anuncios recompensados no están disponibles en web
    if (kIsWeb) {
      final l10n = AppLocalizations.of(context);
      final message = l10n.locale.languageCode == 'es'
          ? 'Los anuncios recompensados no están disponibles en la versión web.'
          : 'Rewarded ads are not available on the web version.';
      _showSnackBar(message);
      return;
    }
    
    if (_rewardedAd != null && _isRewardedAdReady) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          // El usuario completó el video y ganó la recompensa
          _handleRewardEarned();
        },
      );
    } else {
      // Si el anuncio no está listo, intentar recargarlo
      _loadRewardedAd();
      _showSnackBar('El anuncio no está listo. Por favor, intenta de nuevo en un momento.');
    }
  }
  
  Future<void> _handleRewardEarned() async {
    // Agregar 3 créditos bonificados
    await UsageService.addBonusCredits(3);
    
    // Recargar créditos y actualizar UI
    await _loadCredits();
    
    // Mostrar mensaje de éxito
    final l10n = AppLocalizations.of(context);
    final message = l10n.locale.languageCode == 'es' 
        ? '¡Genial! Tienes 3 créditos extra.'
        : 'Great! You have 3 extra credits.';
    _showSnackBar(message);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    // Inicializar o actualizar el tono si cambió el idioma
    if (_selectedTone == null || !l10n.tones.contains(_selectedTone)) {
      _selectedTone = l10n.tones[0];
    }
    // Inicializar o actualizar la longitud si cambió el idioma
    if (_selectedLength == null || !l10n.lengths.contains(_selectedLength)) {
      _selectedLength = l10n.lengths[0];
    }
  }
  
  String get selectedTone => _selectedTone ?? AppLocalizations.of(context).tones[0];
  String get selectedLength => _selectedLength ?? AppLocalizations.of(context).lengths[0];

  Future<void> _loadCredits() async {
    final credits = await UsageService.getRemainingCredits();
    setState(() {
      _remainingCredits = credits;
    });
  }


  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context);
                    return Text(
                      l10n.selectImage,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Opción de cámara solo disponible en móviles (no en web)
                if (!kIsWeb)
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context);
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        title: Text(
                          l10n.takePhoto,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImageFromCamera();
                        },
                      );
                    },
                  ),
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context);
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.photo_library_outlined,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      title: Text(
                        l10n.chooseFromGallery,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromGallery();
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImagePaths.add(image.path);
          _selectedImageFiles.add(image);
        });
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      _showSnackBar('${l10n.errorTakingPhoto}: ${e.toString()}');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final List<XFile>? images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (images != null && images.isNotEmpty) {
        setState(() {
          _selectedImagePaths.addAll(images.map((img) => img.path));
          _selectedImageFiles.addAll(images);
        });
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      _showSnackBar('${l10n.errorSelectingImage}: ${e.toString()}');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImagePaths.removeAt(index);
      _selectedImageFiles.removeAt(index);
    });
  }

  void _removeAllImages() {
    setState(() {
      _selectedImagePaths.clear();
      _selectedImageFiles.clear();
    });
  }

  Future<void> _generateCaptions() async {
    final l10n = AppLocalizations.of(context);
    
    // Validar que haya al menos texto o imagen
    if (_inputController.text.trim().isEmpty && _selectedImagePaths.isEmpty) {
      _showSnackBar(l10n.pleaseEnterTextOrImage);
      return;
    }

    final canUse = await UsageService.canUse();
    if (!canUse) {
      _showSnackBar(l10n.dailyLimitReached);
      return;
    }

    setState(() {
      _isLoading = true;
      _captions = [];
    });

    try {
      final captions = await ApiService.generateCaptionsWithFiles(
        _inputController.text.trim(),
        selectedTone,
        imageFiles: _selectedImageFiles.isNotEmpty ? _selectedImageFiles : null,
        languageCode: widget.currentLocale.languageCode,
        length: selectedLength,
      );

      await UsageService.incrementUsage();
      await _loadCredits();

      setState(() {
        _captions = captions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      final l10n = AppLocalizations.of(context);
      _showSnackBar('${l10n.error}: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canUse = _remainingCredits > 0;
    final showRewardedAd = _remainingCredits <= 0;

    final l10n = AppLocalizations.of(context);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          l10n.appTitle,
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        titleSpacing: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
        ),
        actions: [
          // Botón de cambio de idioma mejorado
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onLocaleToggle,
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
                        widget.currentLocale == LocaleService.spanish ? 'ES' : 'EN',
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
              widget.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 22,
            ),
            onPressed: widget.onThemeToggle,
            tooltip: widget.isDarkMode ? l10n.lightMode : l10n.darkMode,
            color: isDark ? Colors.white : Colors.black,
            padding: const EdgeInsets.all(12),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Contador de créditos
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                ),
              ),
              child: Text(
                '${l10n.credits}: $_remainingCredits/${AppConstants.dailyLimit}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Previsualización de imágenes
            if (_selectedImagePaths.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ..._selectedImagePaths.asMap().entries.map((entry) {
                      final index = entry.key;
                      final imagePath = entry.value;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: kIsWeb
                                  ? Image.network(
                                      imagePath,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      io.File(imagePath),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _removeImage(index),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              if (_selectedImagePaths.length > 1)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _removeAllImages,
                    child: Text(
                      l10n.removeAll,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
            ],

            // Campo de texto
            TextField(
              controller: _inputController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: l10n.whatDoYouWantToExpress,
                hintStyle: GoogleFonts.inter(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),

            // Botón para seleccionar imagen
            InkWell(
              onTap: _showImageSourceDialog,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 20,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.addImage,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Selector de tono
            Text(
              l10n.tone,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: l10n.tones.map((tone) {
                final isSelected = selectedTone == tone;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTone = tone;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? (isDark ? Colors.grey[800] : Colors.black)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected 
                            ? (isDark ? Colors.grey[800]! : Colors.black)
                            : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      tone,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? Colors.white
                            : (isDark ? Colors.grey[300] : Colors.grey[700]),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            
            // Selector de longitud
            Text(
              l10n.length,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: l10n.lengths.map((length) {
                final isSelected = selectedLength == length;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLength = length;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? (isDark ? Colors.grey[800] : Colors.black)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected 
                            ? (isDark ? Colors.grey[800]! : Colors.black)
                            : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      length,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? Colors.white
                            : (isDark ? Colors.grey[300] : Colors.grey[700]),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Banner publicitario encima del botón (solo en móviles)
            if (!kIsWeb && _isBannerAdReady && _bannerAd != null)
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: _bannerAd!.size.height.toDouble(),
                margin: const EdgeInsets.only(bottom: 24),
                color: Theme.of(context).colorScheme.surface,
                child: _bannerAd != null ? AdWidget(ad: _bannerAd!) : const SizedBox.shrink(),
              ),

            // Botón de generar o ver video
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading 
                    ? null 
                    : (showRewardedAd ? _showRewardedAd : (canUse ? _generateCaptions : null)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: showRewardedAd 
                      ? Colors.amber[800] 
                      : (isDark ? Colors.white : Colors.black),
                  foregroundColor: showRewardedAd 
                      ? Colors.white 
                      : (isDark ? Colors.black : Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            showRewardedAd 
                                ? Colors.white 
                                : (isDark ? Colors.black : Colors.white),
                          ),
                        ),
                      )
                    : Text(
                        showRewardedAd 
                            ? (l10n.locale.languageCode == 'es' 
                                ? 'Ver video (+3 créditos)' 
                                : 'Watch video (+3 credits)')
                            : l10n.rephrase,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),

            // Resultados
            if (_captions.isNotEmpty) ...[
              Text(
                l10n.results,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.displayLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              ..._captions.map((caption) {
                return _CaptionCard(
                  caption: caption,
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _CaptionCard extends StatelessWidget {
  final String caption;

  const _CaptionCard({
    required this.caption,
  });

  Future<void> _shareToWhatsApp(BuildContext context) async {
    try {
      final encodedText = Uri.encodeComponent(caption);
      final url = Uri.parse('whatsapp://send?text=$encodedText');
      
      // Intentar abrir WhatsApp directamente
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // WhatsApp no está instalado - mostrar mensaje y abrir menú de compartir como fallback
        if (context.mounted) {
          final l10n = AppLocalizations.of(context);
          final message = l10n.locale.languageCode == 'es' 
              ? 'No se encontró WhatsApp instalado' 
              : 'WhatsApp not found';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          
          // Fallback: abrir menú de compartir nativo
          await Share.share(caption);
        }
      }
    } catch (e) {
      // Si hay un error al intentar abrir WhatsApp, usar el menú de compartir como fallback
      if (context.mounted) {
        try {
          await Share.share(caption);
        } catch (shareError) {
          // Si también falla el compartir, mostrar mensaje de error
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${l10n.error}: ${e.toString()}',
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  Future<void> _shareToInstagram(BuildContext context) async {
    try {
      // Copiar al portapapeles
      await Clipboard.setData(ClipboardData(text: caption));
      
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        final message = l10n.locale.languageCode == 'es'
            ? 'Caption copiado. ¡Pégalo en Instagram!'
            : 'Caption copied. Paste it on Instagram!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Intentar abrir Instagram
      final instagramUrl = Uri.parse('instagram://app');
      if (await canLaunchUrl(instagramUrl)) {
        await launchUrl(instagramUrl, mode: LaunchMode.externalApplication);
      } else {
        // Si no se puede abrir la app, intentar abrir la web
        final webUrl = Uri.parse('https://instagram.com');
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.error}: ${e.toString()}',
              style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _shareGeneral(BuildContext context) async {
    try {
      await Share.share(caption);
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.error}: ${e.toString()}',
              style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              caption,
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.6,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            // Fila de acciones con 3 botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botón WhatsApp
                IconButton(
                  onPressed: () => _shareToWhatsApp(context),
                  icon: const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    size: 20,
                  ),
                  color: const Color(0xFF25D366), // Color verde de WhatsApp
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'WhatsApp',
                ),
                const SizedBox(width: 4),
                // Botón Instagram
                IconButton(
                  onPressed: () => _shareToInstagram(context),
                  icon: const FaIcon(
                    FontAwesomeIcons.instagram,
                    size: 20,
                  ),
                  color: const Color(0xFFE4405F), // Color rosa de Instagram
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Instagram',
                ),
                const SizedBox(width: 4),
                // Botón Compartir General
                IconButton(
                  onPressed: () => _shareGeneral(context),
                  icon: Icon(
                    Icons.share,
                    size: 20,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Compartir',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

