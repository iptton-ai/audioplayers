# AudioPlayers OHOS

OHOS平台的audioplayers插件实现，支持在HarmonyOS设备上播放音频。

## ✨ 特性

- 🎵 支持网络音频流播放
- ⏯️ 播放、暂停、停止、恢复控制
- 🎯 音频定位和跳转
- 📊 播放进度和时长获取
- 🔄 播放状态监听
- 🚀 **一键构建**: 使用 `flutter build hap` 自动构建HAR文件

## 🚀 快速开始

### 1. 添加依赖

在你的 `pubspec.yaml` 中添加：

```yaml
dependencies:
  audioplayers: ^6.0.0
  audioplayers_ohos: ^1.0.0
```

### 2. 构建应用

```bash
# 构建OHOS HAP文件（自动包含HAR构建）
flutter build hap --debug
```

### 3. 使用示例

```dart
import 'package:audioplayers/audioplayers.dart';

class AudioExample extends StatefulWidget {
  @override
  _AudioExampleState createState() => _AudioExampleState();
}

class _AudioExampleState extends State<AudioExample> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  Future<void> playAudio() async {
    await _audioPlayer.play(UrlSource('https://example.com/audio.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: playAudio,
      child: Text('播放音频'),
    );
  }
}
```

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

