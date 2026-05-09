import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF191414);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color cardBackground = Color(0xFF282828);
  static const Color primary = Color(0xFF1DB954);
  static const Color accent = Color(0xFF1DB954);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textDisabled = Color(0xFF535353);

  static const Color divider = Color(0xFF282828);
  static const Color ripple = Color(0x141DB954);

  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF1DB954);
  static const Color warning = Color(0xFFFFD700);
}

class AppDimensions {
  AppDimensions._();

  static const double miniPlayerHeight = 80.0;
  static const double bottomNavHeight = kBottomNavigationBarHeight;
  static const double albumArtBorderRadius = 12.0;
  static const double cardBorderRadius = 14.0;
  static const double buttonBorderRadius = 30.0;
  static const double chipBorderRadius = 20.0;

  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  static const double iconSizeS = 18.0;
  static const double iconSizeM = 22.0;
  static const double iconSizeL = 28.0;
  static const double iconSizeXL = 38.0;

  static const double nowPlayingAlbumSize = 260.0;
  static const double miniPlayerAlbumSize = 46.0;
  static const double songTileAlbumSize = 50.0;
  static const double playlistCardAlbumSize = 160.0;

  static double listBottomPadding(BuildContext context) {
    return kBottomNavigationBarHeight + miniPlayerHeight + paddingM;
  }
}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle screenTitle = TextStyle(
    color: Colors.white,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static const TextStyle screenSubtitle = TextStyle(
    color: Color(0xFF808080),
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
  );

  static const TextStyle sectionLabel = TextStyle(
    color: Color(0xFF5A5A5A),
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
  );

  static const TextStyle songTitle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle songTitleActive = TextStyle(
    color: AppColors.primary,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle songArtist = TextStyle(
    color: Color(0xFF737373),
    fontSize: 12,
  );

  static const TextStyle nowPlayingTitle = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
  );

  static const TextStyle nowPlayingArtist = TextStyle(
    color: Color(0xFF8C8C8C),
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle timeLabel = TextStyle(
    color: Color(0xFF737373),
    fontSize: 11,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle badgeLabel = TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle chipLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle chipLabelActive = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 13,
  );

  static const TextStyle miniPlayerTitle = TextStyle(
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle miniPlayerArtist = TextStyle(
    color: Color(0xFF737373),
    fontSize: 11,
  );
}

class AppDurations {
  AppDurations._();

  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 400);
  static const Duration slideTransition = Duration(milliseconds: 320);
  static const Duration albumRotation = Duration(seconds: 12);
  static const Duration debounce = Duration(milliseconds: 300);
}

class AppAssets {
  AppAssets._();

  static const String defaultAlbumArt = 'assets/images/default_album_art.png';
  static const String sampleSongsPath = 'assets/audio/sample_songs/';

  static const List<String> sampleSongs = [
    '${sampleSongsPath}50 Năm Về Sau.mp3',
    '${sampleSongsPath}Không Buông.mp3',
    '${sampleSongsPath}Tuyển Bạn Gái.mp3',
  ];
}