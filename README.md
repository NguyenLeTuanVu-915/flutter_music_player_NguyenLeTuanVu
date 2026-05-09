# Offline Music Player

> Ứng dụng nghe nhạc offline được xây dựng bằng Flutter, hỗ trợ quản lý thư viện nhạc, playlist, và phát nhạc nền trên Android.

## Mục lục

- [Tính năng](#tính-năng)
- [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
- [Cài đặt & Chạy dự án](#cài-đặt--chạy-dự-án)
- [Thêm file nhạc để test](#thêm-file-nhạc-để-test)
- [Cấu trúc dự án](#cấu-trúc-dự-án)
- [Công nghệ sử dụng](#công-nghệ-sử-dụng)
- [Thuộc tính nhạc mẫu](#thuộc-tính-nhạc-mẫu)
- [Giới hạn đã biết](#giới-hạn-đã-biết)
- [Cải tiến trong tương lai](#cải-tiến-trong-tương-lai)

## Tính năng

### Phát nhạc
- **Play / Pause / Stop** — điều khiển đầy đủ
- **Next / Previous** — chuyển bài, bấm Previous trong 3 giây đầu để quay lại đầu bài
- **Seek** — tua tiến/lùi qua progress bar kéo thả mượt
- **Shuffle** — phát ngẫu nhiên với lịch sử quay lại (Previous hoạt động đúng khi shuffle)
- **Repeat** — 3 chế độ: Tắt / Lặp tất cả / Lặp một bài
- **Tốc độ phát** — 0.5x đến 2.0x
- **Âm lượng** — slider điều chỉnh realtime, lưu trạng thái qua các lần khởi động
- **Hẹn giờ tắt** — tự dừng sau 15 / 30 / 45 / 60 phút

### Thư viện & Playlist
- **Tải nhạc từ thiết bị** — tự động quét toàn bộ file audio hoặc chọn thủ công qua file picker
- **Tìm kiếm** — tìm theo tên bài, nghệ sĩ, album realtime
- **Sắp xếp** — theo Tên / Nghệ sĩ / Album / Thời lượng
- **Tạo playlist** — đặt tên, thêm / xóa bài, đổi tên, xóa playlist
- **Thêm vào playlist** từ Now Playing hoặc danh sách bài

### Giao diện
- **Mini player** (cao 80px) — hiện ở dưới mọi màn hình, swipe trái/phải để Next/Previous
- **Now Playing screen** — album art xoay, volume slider, queue viewer
- **Dark / Light theme** — chuyển đổi trong cài đặt
- **Màu chủ đề** — chọn 1 trong 8 màu preset
- **Album art** — bo góc, hiện placeholder gradient khi không có ảnh

### Lưu trạng thái
- Âm lượng, bài cuối phát, vị trí shuffle/repeat được lưu qua `SharedPreferences`
- Khôi phục khi khởi động lại app

## Yêu cầu hệ thống

| Mục | Yêu cầu |
|-----|---------|
| Flutter SDK | ≥ 3.4.0 |
| Dart SDK | ≥ 3.4.0 |
| Android | API 21+ (Android 5.0 Lollipop) |
| IDE | Android Studio / VS Code với Flutter extension |

## Screenshots

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/83875a2d-499b-47f2-94ac-89fd098de370" />
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/2a82e4ce-da73-4839-a55c-5ff541984ce1" />
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/b615ff35-edde-4fa2-8ba3-43f437c93348" />
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/32e5798f-04a2-4bca-a6f6-c4c166744e59" />
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/86f24517-15ca-4983-b814-da7e7556950c" />
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/1ba87650-d58f-4bcf-b332-19c9c0fdd339" />
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/b0c4164e-2a49-437c-94ed-d7b54291f92c" />

## Cài đặt & Chạy dự án

### 1. Clone dự án

```bash
git clone https://github.com/<your-username>/offline_music_player.git
cd offline_music_player
```

### 2. Cài dependencies

```bash
flutter pub get
```

### 3. Kiểm tra môi trường

```bash
flutter doctor
```

Đảm bảo không có lỗi với Android toolchain và một thiết bị/emulator đang kết nối.

### 4. Cấp quyền Android

File `android/app/src/main/AndroidManifest.xml` đã có sẵn các quyền:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
```

Với Android 13+ (API 33), app tự động xin quyền `READ_MEDIA_AUDIO`. Với Android 12 trở xuống, app xin quyền `READ_EXTERNAL_STORAGE`.

### 5. Chạy ứng dụng

```bash
# Debug mode
flutter run

# Release mode (tốt hơn cho test nhạc)
flutter run --release
```

## Thêm file nhạc để test

App hỗ trợ **2 cách** nạp nhạc:

### Cách 1 — Nhạc mẫu (Asset, không cần thiết bị thật)

Đặt file `.mp3` vào thư mục:

```
assets/
└── audio/
    └── sample_songs/
        ├── Ten_bai_hat_1.mp3
        ├── Ten_bai_hat_2.mp3
        └── ...
```

Sau đó khai báo trong `pubspec.yaml` (đã có sẵn):

```yaml
flutter:
  assets:
    - assets/audio/sample_songs/
    - assets/images/
```

Chạy lại `flutter pub get` và `flutter run`.

### Cách 2 — Nhạc từ thiết bị thật (Android)

**Bước 1:** Kết nối thiết bị Android, bật USB Debugging.

**Bước 2:** Copy file nhạc vào bộ nhớ thiết bị:

```bash
# Dùng ADB
adb push /path/to/song.mp3 /sdcard/Music/

# Hoặc dùng File Manager trên thiết bị
```

**Bước 3:** Mở app → bấm nút `+` ở góc trên phải màn hình **Nhạc của tôi** để chọn thủ công, hoặc bấm nút refresh để quét tự động.

**Định dạng hỗ trợ:** `.mp3`, `.m4a`, `.flac`, `.aac`, `.ogg`, `.wav`

> **Lưu ý:** App lọc bỏ file có thời lượng dưới 10 giây (notification sounds, ringtones).

## Cấu trúc dự án

```
lib/
├── main.dart                      # Entry point, MultiProvider setup
├── models/
│   ├── song_model.dart            # Data model cho bài hát
│   ├── playlist_model.dart        # Data model cho playlist (immutable)
│   └── playback_state_model.dart  # Trạng thái phát nhạc
├── services/
│   ├── audio_player_service.dart  # Wrapper just_audio
│   ├── storage_service.dart       # SharedPreferences persistence
│   ├── permission_service.dart    # Xin quyền Android/iOS
│   └── playlist_service.dart      # Quét file, file picker
├── providers/
│   ├── audio_provider.dart        # State management phát nhạc
│   ├── playlist_provider.dart     # State management playlist
│   └── theme_provider.dart        # Dark/light theme, accent color
├── screens/
│   ├── home_screen.dart           # Thư viện nhạc chính
│   ├── now_playing_screen.dart    # Màn hình đang phát
│   ├── playlist_screen.dart       # Danh sách & chi tiết playlist
│   ├── all_songs_screen.dart      # Danh sách đầy đủ với A-Z scroller
│   └── settings_screen.dart       # Cài đặt
├── widgets/
│   ├── song_tile.dart             # Item bài hát (animated playing bars)
│   ├── mini_player.dart           # Mini player 80px
│   ├── player_controls.dart       # Nút điều khiển Now Playing
│   ├── progress_bar.dart          # Seek bar kéo thả
│   ├── playlist_card.dart         # Card playlist (3 variant)
│   └── album_art.dart             # Album art với bo góc, placeholder
└── utils/
    ├── constants.dart             # AppColors, AppDimensions, AppTextStyles
    ├── duration_formatter.dart    # Format thời gian mm:ss, phút giây
    └── color_extractor.dart       # Trích màu dominant từ album art

assets/
├── audio/
│   └── sample_songs/              # File nhạc mẫu để demo
└── images/
    └── default_album_art.png      # Ảnh bìa mặc định
```

## Công nghệ sử dụng

| Package | Phiên bản | Mục đích |
|---------|-----------|---------|
| [just_audio](https://pub.dev/packages/just_audio) | ^0.9.36 | Engine phát nhạc chính, hỗ trợ file & asset |
| [audio_service](https://pub.dev/packages/audio_service) | ^0.18.12 | Background playback, media notification |
| [audio_session](https://pub.dev/packages/audio_session) | ^0.1.18 | Quản lý audio session (ngắt khi gọi điện...) |
| [provider](https://pub.dev/packages/provider) | ^6.1.1 | State management (ChangeNotifier) |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | ^2.2.2 | Lưu trạng thái persistent |
| [on_audio_query](https://pub.dev/packages/on_audio_query) | ^2.9.0 | Quét thư viện nhạc của thiết bị Android |
| [file_picker](https://pub.dev/packages/file_picker) | ^8.0.0 | Chọn file thủ công từ storage |
| [permission_handler](https://pub.dev/packages/permission_handler) | ^11.3.0 | Xin quyền READ_MEDIA_AUDIO |
| [rxdart](https://pub.dev/packages/rxdart) | ^0.27.7 | combineLatest4 cho PlaybackState stream |
| [path_provider](https://pub.dev/packages/path_provider) | ^2.1.1 | Đường dẫn thư mục hệ thống |

**Framework:** Flutter 3.x · Dart 3.x · Material Design 3

## Thuộc tính nhạc mẫu

Xem chi tiết tại [`MUSIC_CREDITS.md`](./MUSIC_CREDITS.md).

| Bài hát | Nghệ sĩ | Nguồn |
|---------|---------|-------|
| 50 Năm Về Sau | Đặng Thanh Tuyền | Được sử dụng cho mục đích demo |
| Không Buông | Hngle | Được sử dụng cho mục đích học tập / demo |
| Tuyển Bạn Gái | Ogenus, Dangrangto | Được sử dụng cho mục đích demo |

> Tất cả bản quyền thuộc về nghệ sĩ và nhà phát hành gốc. Các file nhạc chỉ được sử dụng cho mục đích demo, không phân phối thương mại.

## Giới hạn đã biết

| # | Vấn đề | Nguyên nhân |
|---|--------|-------------|
| 1 | Background playback chưa hiện notification media player | `audio_service` đã tích hợp nhưng chưa cấu hình `AudioHandler` đầy đủ |
| 2 | Album art chưa tự động lấy từ metadata ID3 | `on_audio_query` không trả về artwork binary trên tất cả thiết bị |
| 3 | iOS chưa được test | Chỉ test trên Android; `permission_handler` và `on_audio_query` có thể cần cấu hình thêm cho iOS |
| 4 | Không hỗ trợ streaming / nhạc online | App được thiết kế hoàn toàn offline |
| 5 | Màu chủ đề chưa áp dụng lên 100% widget | Một số widget dùng `AppColors.primary` const thay vì `Theme.of(context).colorScheme.primary` |
| 6 | Chưa hỗ trợ playlist import/export | Playlist chỉ lưu trong `SharedPreferences` của app |

## Cải tiến trong tương lai

- [ ] **Background playback notification** — hiện media controls trong notification bar và lock screen
- [ ] **ID3 metadata reader** — đọc artwork, lyrics, year từ tag MP3/FLAC
- [ ] **Equalizer** — bộ cân bằng âm thanh tích hợp
- [ ] **Crossfade** — chuyển bài mượt với fade in/out
- [ ] **Sleep timer nâng cao** — fade out dần trước khi tắt
- [ ] **Widget màn hình chính** — mini player trên Home screen Android
- [ ] **Lyrics** — hiển thị lời bài hát (LRC file hoặc API)
- [ ] **Import/Export playlist** — dạng M3U
- [ ] **Cloud backup** — đồng bộ playlist lên Google Drive
- [ ] **iOS support** — test và fix các vấn đề permissions trên iOS
- [ ] **Tablet layout** — giao diện 2 cột cho màn hình lớn
- [ ] **Car mode** — giao diện đơn giản, nút to cho xe hơi
