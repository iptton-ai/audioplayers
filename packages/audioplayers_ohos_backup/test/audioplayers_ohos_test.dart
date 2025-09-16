import 'package:flutter_test/flutter_test.dart';
import 'package:audioplayers_ohos/audioplayers_ohos.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioplayersOhos', () {
    late AudioplayersOhos audioplayersOhos;
    late List<MethodCall> methodCalls;

    setUp(() {
      audioplayersOhos = AudioplayersOhos();
      methodCalls = <MethodCall>[];

      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.example.audioplayers_ohos'),
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);

          // Return mock responses for specific methods
          switch (methodCall.method) {
            case 'getDuration':
              return 30000; // 30 seconds
            case 'getCurrentPosition':
              return 5000; // 5 seconds
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.example.audioplayers_ohos'),
        null,
      );
    });

    test('should be registered as the platform implementation', () {
      AudioplayersOhos.registerWith();
      expect(AudioplayersPlatformInterface.instance, isA<AudioplayersOhos>());
    });

    test('should create player without error', () async {
      await audioplayersOhos.create('test_player');
      // Creating a player doesn't call any native methods in this implementation
      expect(methodCalls, isEmpty);
    });

    test('should dispose player correctly', () async {
      await audioplayersOhos.dispose('test_player');

      expect(methodCalls, hasLength(1));
      expect(methodCalls[0].method, 'release');
      expect(methodCalls[0].arguments['playerId'], 'test_player');
    });

    test('should call resume for playing audio', () async {
      await audioplayersOhos.resume('test_player');

      expect(methodCalls, hasLength(1));
      expect(methodCalls[0].method, 'resume');
      expect(methodCalls[0].arguments['playerId'], 'test_player');
    });

    test('should pause audio', () async {
      await audioplayersOhos.pause('test_player');

      expect(methodCalls, hasLength(1));
      expect(methodCalls[0].method, 'pause');
      expect(methodCalls[0].arguments['playerId'], 'test_player');
    });

    test('should resume audio', () async {
      await audioplayersOhos.resume('test_player');

      expect(methodCalls, hasLength(1));
      expect(methodCalls[0].method, 'resume');
      expect(methodCalls[0].arguments['playerId'], 'test_player');
    });

    test('should stop audio', () async {
      await audioplayersOhos.stop('test_player');

      expect(methodCalls, hasLength(1));
      expect(methodCalls[0].method, 'stop');
      expect(methodCalls[0].arguments['playerId'], 'test_player');
    });

    test('should set source URL', () async {
      const testUrl = 'https://example.com/audio.mp3';
      await audioplayersOhos.setSourceUrl('test_player', testUrl);

      expect(methodCalls, hasLength(1));
      expect(methodCalls[0].method, 'setSourceUrl');
      expect(methodCalls[0].arguments['playerId'], 'test_player');
      expect(methodCalls[0].arguments['url'], testUrl);
    });

    test('should set volume', () async {
      await audioplayersOhos.setVolume('test_player', 0.5);

      expect(methodCalls, hasLength(1));
      expect(methodCalls[0].method, 'setVolume');
      expect(methodCalls[0].arguments['playerId'], 'test_player');
      expect(methodCalls[0].arguments['volume'], 0.5);
    });

    test('should get duration', () async {
      final duration = await audioplayersOhos.getDuration('test_player');

      expect(methodCalls, hasLength(1));
      expect(methodCalls[0].method, 'getDuration');
      expect(methodCalls[0].arguments['playerId'], 'test_player');
      expect(duration, 30000);
    });

    test('should get current position', () async {
      final position = await audioplayersOhos.getCurrentPosition('test_player');

      expect(methodCalls, hasLength(1));
      expect(methodCalls[0].method, 'getCurrentPosition');
      expect(methodCalls[0].arguments['playerId'], 'test_player');
      expect(position, 5000);
    });
  });
}
