import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class ColorExtractor {
  ColorExtractor._();

  static final Map<String, Color> _cache = {};

  static Future<Color> fromFile(String filePath) async {
    if (_cache.containsKey(filePath)) return _cache[filePath]!;

    try {
      final file = File(filePath);
      if (!file.existsSync()) return AppColors.primary;

      final bytes = await file.readAsBytes();
      final color = await _extractDominant(bytes);
      _cache[filePath] = color;
      return color;
    } catch (_) {
      return AppColors.primary;
    }
  }

  static Future<Color> fromAsset(String assetPath) async {
    if (_cache.containsKey(assetPath)) return _cache[assetPath]!;

    try {
      final bytes = await rootBundle.load(assetPath);
      final color = await _extractDominant(bytes.buffer.asUint8List());
      _cache[assetPath] = color;
      return color;
    } catch (_) {
      return AppColors.primary;
    }
  }

  static Future<Color> fromAlbumArtString(String? albumArt) async {
    if (albumArt == null || albumArt.isEmpty) return AppColors.primary;
    if (albumArt.startsWith('assets/')) return fromAsset(albumArt);
    return fromFile(albumArt);
  }

  static Future<Color> _extractDominant(List<int> bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(
        Uint8List.fromList(bytes),
        targetWidth: 50,
        targetHeight: 50,
      );
      final frame = await codec.getNextFrame();
      final imageData = await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      if (imageData == null) return AppColors.primary;

      final pixels = imageData.buffer.asUint8List();
      final colorCounts = <int, int>{};

      for (int i = 0; i < pixels.length; i += 4) {
        final r = pixels[i];
        final g = pixels[i + 1];
        final b = pixels[i + 2];
        final a = pixels[i + 3];

        if (a < 128) continue;

        final quantized = _quantize(r, g, b);
        colorCounts[quantized] = (colorCounts[quantized] ?? 0) + 1;
      }

      if (colorCounts.isEmpty) return AppColors.primary;

      final sorted = colorCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sorted.take(10)) {
        final color = _fromQuantized(entry.key);
        if (_isVibrant(color)) return color;
      }

      return _fromQuantized(sorted.first.key);
    } catch (_) {
      return AppColors.primary;
    }
  }

  static int _quantize(int r, int g, int b) {
    final qr = (r >> 4) << 4;
    final qg = (g >> 4) << 4;
    final qb = (b >> 4) << 4;
    return (qr << 16) | (qg << 8) | qb;
  }

  static Color _fromQuantized(int value) {
    final r = (value >> 16) & 0xFF;
    final g = (value >> 8) & 0xFF;
    final b = value & 0xFF;
    return Color.fromARGB(255, r, g, b);
  }

  static bool _isVibrant(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.saturation > 0.35 &&
        hsl.lightness > 0.15 &&
        hsl.lightness < 0.85;
  }

  static Color darken(Color color, [double amount = 0.3]) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  static Color lighten(Color color, [double amount = 0.2]) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  static Color withMinSaturation(Color color, [double minSat = 0.4]) {
    final hsl = HSLColor.fromColor(color);
    if (hsl.saturation >= minSat) return color;
    return hsl.withSaturation(minSat).toColor();
  }

  static Color adaptiveTextColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  static Color ensureContrast(Color foreground, Color background) {
    final fgLum = foreground.computeLuminance();
    final bgLum = background.computeLuminance();
    final lighter = max(fgLum, bgLum);
    final darker = min(fgLum, bgLum);
    final contrast = (lighter + 0.05) / (darker + 0.05);
    if (contrast >= 3.0) return foreground;
    return adaptiveTextColor(background);
  }

  static void clearCache() => _cache.clear();

  static void removeFromCache(String key) => _cache.remove(key);
}