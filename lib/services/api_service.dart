import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html' as io;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  // Tu API KEY (copiada de tu código anterior)
  static const String apiKey = 'AIzaSyAWShQiIxiwL0z0pOhFa14hSa8IUtbglag';

  static Future<List<String>> generateCaptions(
    String input,
    String tone, {
    List<String>? imagePaths,
    String languageCode = 'es',
    String length = 'short', // 'short' o 'long'
  }) async {
    // Convertir rutas a XFile para compatibilidad con web
    List<XFile>? imageFiles;
    if (imagePaths != null && imagePaths.isNotEmpty) {
      imageFiles = imagePaths.map((path) => XFile(path)).toList();
    }
    return generateCaptionsWithFiles(
      input,
      tone,
      imageFiles: imageFiles,
      languageCode: languageCode,
      length: length,
    );
  }

  static Future<List<String>> generateCaptionsWithFiles(
    String input,
    String tone, {
    List<XFile>? imageFiles,
    String languageCode = 'es',
    String length = 'short', // 'short' o 'long'
  }) async {
    // ¡USAMOS EL MODELO QUE APARECIÓ EN TU LISTA!
    // gemini-2.0-flash es increíblemente rápido.
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey.trim()}',
    );

    print("🚀 Conectando con Gemini 2.0 Flash...");

    try {
      final hasImages = imageFiles != null && imageFiles.isNotEmpty;
      final imageCount = hasImages ? imageFiles.length : 0;

      // Construir el prompt según si hay imágenes o no y el idioma
      String promptText;
      final isEnglish = languageCode == 'en';
      final lengthLower = length.toLowerCase();
      final isLong = lengthLower == 'long' || lengthLower == 'largo';
      final lengthText = isLong 
          ? (isEnglish ? "long and detailed" : "largas y detalladas")
          : (isEnglish ? "short" : "cortas");

      if (hasImages) {
        if (input.trim().isNotEmpty) {
          if (imageCount == 1) {
            promptText = isEnglish
                ? "Act as a social media expert. Analyze the provided image and the context text: '$input'. Generate 5 $lengthText Instagram caption options based on the image and context. Tone: '$tone'. Include hashtags. IMPORTANT: Your response must be ONLY a valid JSON array of strings, example: [\"text 1\", \"text 2\"]. Do not use markdown ```json or anything extra."
                : "Actúa como un experto en redes sociales. Analiza la imagen proporcionada y el texto de contexto: '$input'. Genera 5 opciones de captions $lengthText para Instagram basadas en la imagen y el contexto. Tono: '$tone'. Incluye hashtags. IMPORTANTE: Tu respuesta debe ser ÚNICAMENTE un Array JSON válido de strings, ejemplo: [\"texto 1\", \"texto 2\"]. No uses markdown ```json ni nada extra.";
          } else {
            promptText = isEnglish
                ? "Act as a social media expert. Analyze the $imageCount provided images and the context text: '$input'. Generate 5 $lengthText Instagram caption options based on the images and context. Tone: '$tone'. Include hashtags. IMPORTANT: Your response must be ONLY a valid JSON array of strings, example: [\"text 1\", \"text 2\"]. Do not use markdown ```json or anything extra."
                : "Actúa como un experto en redes sociales. Analiza las $imageCount imágenes proporcionadas y el texto de contexto: '$input'. Genera 5 opciones de captions $lengthText para Instagram basadas en las imágenes y el contexto. Tono: '$tone'. Incluye hashtags. IMPORTANTE: Tu respuesta debe ser ÚNICAMENTE un Array JSON válido de strings, ejemplo: [\"texto 1\", \"texto 2\"]. No uses markdown ```json ni nada extra.";
          }
        } else {
          if (imageCount == 1) {
            promptText = isEnglish
                ? "Act as a social media expert. Analyze the provided image and generate 5 $lengthText Instagram caption options based on the image. Tone: '$tone'. Include hashtags. IMPORTANT: Your response must be ONLY a valid JSON array of strings, example: [\"text 1\", \"text 2\"]. Do not use markdown ```json or anything extra."
                : "Actúa como un experto en redes sociales. Analiza la imagen proporcionada y genera 5 opciones de captions $lengthText para Instagram basadas en la imagen. Tono: '$tone'. Incluye hashtags. IMPORTANTE: Tu respuesta debe ser ÚNICAMENTE un Array JSON válido de strings, ejemplo: [\"texto 1\", \"texto 2\"]. No uses markdown ```json ni nada extra.";
          } else {
            promptText = isEnglish
                ? "Act as a social media expert. Analyze the $imageCount provided images and generate 5 $lengthText Instagram caption options based on the images. Tone: '$tone'. Include hashtags. IMPORTANT: Your response must be ONLY a valid JSON array of strings, example: [\"text 1\", \"text 2\"]. Do not use markdown ```json or anything extra."
                : "Actúa como un experto en redes sociales. Analiza las $imageCount imágenes proporcionadas y genera 5 opciones de captions $lengthText para Instagram basadas en las imágenes. Tono: '$tone'. Incluye hashtags. IMPORTANTE: Tu respuesta debe ser ÚNICAMENTE un Array JSON válido de strings, ejemplo: [\"texto 1\", \"texto 2\"]. No uses markdown ```json ni nada extra.";
          }
        }
      } else {
        promptText = isEnglish
            ? "Act as a social media expert. Generate 5 $lengthText Instagram caption options based on: '$input'. Tone: '$tone'. Include hashtags. IMPORTANT: Your response must be ONLY a valid JSON array of strings, example: [\"text 1\", \"text 2\"]. Do not use markdown ```json or anything extra."
            : "Actúa como un experto en redes sociales. Genera 5 opciones de captions $lengthText para Instagram basadas en: '$input'. Tono: '$tone'. Incluye hashtags. IMPORTANTE: Tu respuesta debe ser ÚNICAMENTE un Array JSON válido de strings, ejemplo: [\"texto 1\", \"texto 2\"]. No uses markdown ```json ni nada extra.";
      }

      // Construir las partes del mensaje
      List<Map<String, dynamic>> parts = [
        {"text": promptText},
      ];

      // Si hay imágenes, agregarlas al request
      if (hasImages && imageFiles != null) {
        for (final imageFile in imageFiles) {
          try {
            // Usar readAsBytes() de XFile que funciona tanto en web como en móviles
            final imageBytes = await imageFile.readAsBytes();
            final base64Image = base64Encode(imageBytes);

            // Detectar MIME type basado en la extensión o el nombre del archivo
            String mimeType = 'image/jpeg';
            final path = imageFile.path.toLowerCase();
            if (path.endsWith('.png')) {
              mimeType = 'image/png';
            } else if (path.endsWith('.gif')) {
              mimeType = 'image/gif';
            } else if (path.endsWith('.webp')) {
              mimeType = 'image/webp';
            }

            parts.add({
              "inlineData": {"mimeType": mimeType, "data": base64Image},
            });
            print("📸 Imagen agregada al request (${mimeType})");
          } catch (e) {
            print("⚠️ Error procesando imagen ${imageFile.path}: $e");
            // Continuar con las demás imágenes si hay error
          }
        }
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {"parts": parts},
          ],
          "generationConfig": {
            "temperature": 0.7, 
            "maxOutputTokens": isLong ? 2000 : 800
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null) {
          String rawText = data['candidates'][0]['content']['parts'][0]['text'];

          // Limpieza de Markdown
          rawText = rawText
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();

          // Reparación básica de JSON
          if (!rawText.startsWith('[')) {
            int startIndex = rawText.indexOf('[');
            if (startIndex != -1) rawText = rawText.substring(startIndex);
          }
          if (!rawText.endsWith(']')) {
            int endIndex = rawText.lastIndexOf(']');
            if (endIndex != -1) rawText = rawText.substring(0, endIndex + 1);
          }

          try {
            final List<dynamic> jsonList = jsonDecode(rawText);
            return jsonList.map((e) => e.toString()).toList();
          } catch (e) {
            print("Error parseando: $rawText");
            final errorMsg = languageCode == 'en'
                ? "The AI responded but there was a format error."
                : "La IA respondió pero hubo un error de formato.";
            return [errorMsg];
          }
        }
      } else {
        print("ERROR API: ${response.statusCode} - ${response.body}");

        // Manejar diferentes códigos de error HTTP
        String errorMessage;
        final isEnglish = languageCode == 'en';
        switch (response.statusCode) {
          case 400:
            errorMessage = isEnglish
                ? "Invalid request. Check the entered data."
                : "Solicitud inválida. Verifica los datos ingresados.";
            break;
          case 401:
            errorMessage = isEnglish
                ? "Authentication error: The API key is not valid."
                : "Error de autenticación: La clave de API no es válida.";
            break;
          case 403:
            errorMessage = isEnglish
                ? "Access error: You do not have permissions to use this service."
                : "Error de acceso: No tienes permisos para usar este servicio.";
            break;
          case 429:
            errorMessage = isEnglish
                ? "Request limit reached: Try again later."
                : "Límite de solicitudes alcanzado: Intenta más tarde.";
            break;
          case 500:
          case 502:
          case 503:
            errorMessage = isEnglish
                ? "Server error: The service is temporarily unavailable."
                : "Error del servidor: El servicio no está disponible temporalmente.";
            break;
          default:
            errorMessage = isEnglish
                ? "Server error (${response.statusCode}). Try again."
                : "Error del servidor (${response.statusCode}). Intenta nuevamente.";
        }

        throw Exception(errorMessage);
      }

      final noResponseMsg = languageCode == 'en'
          ? "No response was generated."
          : "No se generó respuesta.";
      return [noResponseMsg];
    } on io.SocketException catch (e) {
      print("ERROR DE CONEXIÓN: $e");
      final connectionError = languageCode == 'en'
          ? "Connection error: Could not connect to the server. Check your internet connection."
          : "Error de conexión: No se pudo conectar con el servidor. Verifica tu conexión a internet.";
      return [connectionError];
    } on http.ClientException catch (e) {
      print("ERROR DE CLIENTE: $e");
      final clientError = languageCode == 'en'
          ? "Connection error: Could not establish connection. Check your internet connection."
          : "Error de conexión: No se pudo establecer la conexión. Verifica tu conexión a internet.";
      return [clientError];
    } on FormatException catch (e) {
      print("ERROR DE FORMATO: $e");
      final formatErrorMsg = languageCode == 'en'
          ? "Error processing server response."
          : "Error al procesar la respuesta del servidor.";
      return [formatErrorMsg];
    } on Exception catch (e) {
      // Si el Exception ya tiene un mensaje formateado, usarlo directamente
      final message = e.toString().replaceFirst('Exception: ', '');
      return [message];
    } catch (e) {
      print("EXCEPCIÓN: $e");
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('socket') ||
          errorMessage.contains('connection') ||
          errorMessage.contains('host lookup') ||
          errorMessage.contains('network')) {
        final networkError = languageCode == 'en'
            ? "Connection error: Check your internet connection and try again."
            : "Error de conexión: Verifica tu conexión a internet e intenta nuevamente.";
        return [networkError];
      }
      final unexpectedError = languageCode == 'en'
          ? "Unexpected error: ${e.toString()}"
          : "Error inesperado: ${e.toString()}";
      return [unexpectedError];
    }
  }
}
