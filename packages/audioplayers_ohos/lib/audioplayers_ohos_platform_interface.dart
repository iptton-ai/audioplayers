import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'audioplayers_ohos_method_channel.dart';

abstract class AudioplayersOhosPlatform extends PlatformInterface {
  /// Constructs a AudioplayersOhosPlatform.
  AudioplayersOhosPlatform() : super(token: _token);

  static final Object _token = Object();

  static AudioplayersOhosPlatform _instance = MethodChannelAudioplayersOhos();

  /// The default instance of [AudioplayersOhosPlatform] to use.
  ///
  /// Defaults to [MethodChannelAudioplayersOhos].
  static AudioplayersOhosPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AudioplayersOhosPlatform] when
  /// they register themselves.
  static set instance(AudioplayersOhosPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
