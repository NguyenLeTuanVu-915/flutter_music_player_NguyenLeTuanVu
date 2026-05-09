import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AlbumArt extends StatelessWidget {
  final String? albumArt;
  final double size;
  final double borderRadius;
  final double? aspectRatio;
  final BoxFit fit;

  const AlbumArt({
    super.key,
    required this.albumArt,
    required this.size,
    this.borderRadius = 12,
    this.aspectRatio,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    final child = _resolveImage();

    if (aspectRatio != null) {
      return AspectRatio(
        aspectRatio: aspectRatio!,
        child: SizedBox.expand(child: child),
      );
    }

    return SizedBox(
      width: size == double.infinity ? null : size,
      height: size == double.infinity ? null : size,
      child: child,
    );
  }

  Widget _resolveImage() {
    if (albumArt == null || albumArt!.isEmpty) {
      return _buildPlaceholder();
    }

    if (albumArt!.startsWith('assets/')) {
      return Image.asset(
        albumArt!,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    if (_isBase64Like(albumArt!)) {
      return _Base64AlbumArt(
        data: albumArt!,
        fit: fit,
        placeholder: _buildPlaceholder(),
      );
    }

    final file = File(albumArt!);
    return Image.file(
      file,
      fit: fit,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  bool _isBase64Like(String value) {
    return value.length > 100 && !value.startsWith('/') && !value.startsWith('assets/');
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size == double.infinity ? null : size,
      height: size == double.infinity ? null : size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground,
            AppColors.primary.withOpacity(0.15),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: AppColors.primary.withOpacity(0.5),
          size: _iconSize(),
        ),
      ),
    );
  }

  double _iconSize() {
    if (size == double.infinity) return 36;
    if (size <= 40) return size * 0.45;
    if (size <= 80) return size * 0.4;
    return size * 0.35;
  }
}

class _Base64AlbumArt extends StatefulWidget {
  final String data;
  final BoxFit fit;
  final Widget placeholder;

  const _Base64AlbumArt({
    required this.data,
    required this.fit,
    required this.placeholder,
  });

  @override
  State<_Base64AlbumArt> createState() => _Base64AlbumArtState();
}

class _Base64AlbumArtState extends State<_Base64AlbumArt> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  void _decode() {
    try {
      _bytes = Uri.parse(
        widget.data.startsWith('data:')
            ? widget.data.split(',').last
            : widget.data,
      ).data?.contentAsBytes();
      _bytes ??= Uri.decodeComponent(widget.data).codeUnits.isEmpty
            ? null
            : Uint8List.fromList(
          widget.data
              .replaceAll(RegExp(r'data:[^,]+,'), '')
              .codeUnits,
        );
    } catch (_) {
      _bytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes == null) return widget.placeholder;
    return Image.memory(
      _bytes!,
      fit: widget.fit,
      errorBuilder: (_, __, ___) => widget.placeholder,
    );
  }
}