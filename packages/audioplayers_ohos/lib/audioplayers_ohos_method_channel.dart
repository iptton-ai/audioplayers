import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audioplayers_ohos_platform_interface.dart';

/// An implementation of [AudioplayersOhosPlatform] that uses method channels.
class MethodChannelAudioplayersOhos extends AudioplayersOhosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('audioplayers_ohos');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
