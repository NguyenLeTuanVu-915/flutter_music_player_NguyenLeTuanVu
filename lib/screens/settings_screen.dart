import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(
                  bottom: kBottomNavigationBarHeight + 88,
                ),
                children: [
                  _buildSectionLabel('Âm thanh'),
                  _buildVolumeCard(context),
                  const SizedBox(height: 8),
                  _buildSectionLabel('Giao diện'),
                  _buildThemeCard(context),
                  const SizedBox(height: 8),
                  _buildAccentColorCard(context),
                  const SizedBox(height: 8),
                  _buildSectionLabel('Thông tin'),
                  _buildInfoCard(context),
                  const SizedBox(height: 8),
                  _buildSectionLabel('Dữ liệu'),
                  _buildDataCard(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cài đặt',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.35),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildVolumeCard(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        return _SettingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                children: [
                  const Icon(Icons.volume_up_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  const Text(
                    'Âm lượng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(audioProvider.volume * 100).round()}%',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                children: [
                  Icon(Icons.volume_mute_rounded,
                      color: Colors.white.withOpacity(0.3), size: 18),
                  Expanded(
                    child: Slider(
                      value: audioProvider.volume.clamp(0.0, 1.0),
                      min: 0.0,
                      max: 1.0,
                      onChanged: audioProvider.setVolume,
                    ),
                  ),
                  Icon(Icons.volume_up_rounded,
                      color: Colors.white.withOpacity(0.3), size: 18),
                ],
              ),
            ),
            _buildDivider(),
            _buildPlaybackSpeedTile(context, audioProvider),
          ],
        );
      },
    );
  }

  Widget _buildPlaybackSpeedTile(
      BuildContext context, AudioProvider audioProvider) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: const Icon(Icons.speed_rounded,
          color: AppColors.primary, size: 20),
      title: const Text(
        'Tốc độ phát',
        style: TextStyle(color: Colors.white, fontSize: 15),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            audioProvider.speed == 1.0
                ? '1.0x'
                : '${audioProvider.speed}x',
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 13),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.3), size: 20),
        ],
      ),
      onTap: () => _showSpeedDialog(context, audioProvider, speeds),
    );
  }

  void _showSpeedDialog(
      BuildContext context,
      AudioProvider audioProvider,
      List<double> speeds,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tốc độ phát'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: speeds.map((speed) {
            final label = speed == 1.0 ? 'Bình thường' : '${speed}x';
            return GestureDetector(
              onTap: () {
                audioProvider.setSpeed(speed);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return _SettingsCard(
          children: [
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              secondary: const Icon(Icons.dark_mode_rounded,
                  color: AppColors.primary, size: 20),
              title: const Text(
                'Giao diện tối',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              subtitle: Text(
                themeProvider.isDarkMode ? 'Đang bật' : 'Đang tắt',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccentColorCard(BuildContext context) {
    final presetColors = [
      const Color(0xFF1DB954),
      const Color(0xFF1E90FF),
      const Color(0xFFFF6B6B),
      const Color(0xFFFFD700),
      const Color(0xFFFF8C00),
      const Color(0xFF9B59B6),
      const Color(0xFF00CED1),
      const Color(0xFFFF69B4),
    ];

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return _SettingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette_rounded,
                          color: themeProvider.accentColor, size: 20),
                      const SizedBox(width: 12),
                      const Text(
                        'Màu chủ đề',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => themeProvider.resetAccentColor(),
                        child: Text(
                          'Đặt lại',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: presetColors.map((color) {
                      final isSelected =
                          themeProvider.accentColor.toARGB32() == color.toARGB32();
                      return GestureDetector(
                        onTap: () => themeProvider.setAccentColor(color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                                : [],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return _SettingsCard(
      children: [
        _buildInfoTile(
          icon: Icons.music_note_rounded,
          label: 'Ứng dụng',
          value: 'Music Player',
        ),
        _buildDivider(),
        _buildInfoTile(
          icon: Icons.info_outline_rounded,
          label: 'Phiên bản',
          value: '1.0.0',
        ),
        _buildDivider(),
        _buildInfoTile(
          icon: Icons.code_rounded,
          label: 'Framework',
          value: 'Flutter',
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(BuildContext context) {
    return _SettingsCard(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: const Icon(Icons.delete_sweep_outlined,
              color: Colors.redAccent, size: 20),
          title: const Text(
            'Xoá tất cả dữ liệu',
            style: TextStyle(color: Colors.redAccent, fontSize: 15),
          ),
          subtitle: Text(
            'Xoá playlist, lịch sử và cài đặt',
            style:
            TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
          ),
          onTap: () => _confirmClear(context),
        ),
      ],
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá dữ liệu'),
        content: const Text(
          'Tất cả playlist, cài đặt và lịch sử phát sẽ bị xoá. Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService().clearAll();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xoá toàn bộ dữ liệu')),
                );
              }
            },
            child: const Text('Xoá',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 48,
      color: Colors.white.withOpacity(0.07),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}