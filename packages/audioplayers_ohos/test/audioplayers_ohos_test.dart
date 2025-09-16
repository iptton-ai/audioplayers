import 'package:flutter_test/flutter_test.dart';
import 'package:audioplayers_ohos/audioplayers_ohos.dart';
import 'package:audioplayers_ohos/audioplayers_ohos_platform_interface.dart';
import 'package:audioplayers_ohos/audioplayers_ohos_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAudioplayersOhosPlatform
    with MockPlatformInterfaceMixin
    implements AudioplayersOhosPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AudioplayersOhosPlatform initialPlatform = AudioplayersOhosPlatform.instance;

  test('$MethodChannelAudioplayersOhos is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAudioplayersOhos>());
  });

  test('getPlatformVersion', () async {
    AudioplayersOhos audioplayersOhosPlugin = AudioplayersOhos();
    MockAudioplayersOhosPlatform fakePlatform = MockAudioplayersOhosPlatform();
    AudioplayersOhosPlatform.instance = fakePlatform;

    expect(await audioplayersOhosPlugin.getPlatformVersion(), '42');
  });
}
