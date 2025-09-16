import 'dart:async';

import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/services.dart';

class AudioplayersOhos extends AudioplayersPlatformInterface {
  final Map<String, StreamController<AudioEvent>> _eventStreamControllers = {};
  final MethodChannel _channel =
      const MethodChannel('com.example.audioplayers_ohos');

  static void registerWith() {
    AudioplayersPlatformInterface.instance = AudioplayersOhos();
  }

  AudioplayersOhos() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    final Map<dynamic, dynamic> arguments =
        call.arguments as Map<dynamic, dynamic>;
    final String playerId = arguments['playerId'];
    final eventType = arguments['event'];

    final streamController = _eventStreamControllers[playerId];
    if (streamController == null) {
      return;
    }

    switch (eventType) {
      case 'onComplete':
        streamController
            .add(const AudioEvent(eventType: AudioEventType.complete));
        break;
      case 'onDurationChanged':
        final duration = arguments['duration'] as int;
        streamController.add(AudioEvent(
            eventType: AudioEventType.duration,
            duration: Duration(milliseconds: duration)));
        break;
      case 'onPositionChanged':
        // Position events are not supported in the current AudioEvent API
        // This would need to be handled differently or the API would need to be extended
        break;
      case 'onError':
        // Not implemented yet.
        break;
      case 'onStateChanged':
        // Not implemented yet.
        break;
    }
  }

  @override
  Stream<AudioEvent> getEventStream(String playerId) {
    _eventStreamControllers[playerId] ??=
        StreamController<AudioEvent>.broadcast();
    return _eventStreamControllers[playerId]!.stream;
  }

  @override
  Future<void> create(String playerId) async {
    // The player is created on demand in the native side.
  }

  @override
  Future<void> dispose(String playerId) async {
    await _channel.invokeMethod('release', {'playerId': playerId});
    _eventStreamControllers[playerId]?.close();
    _eventStreamControllers.remove(playerId);
  }

  @override
  Future<void> pause(String playerId) {
    return _channel.invokeMethod('pause', {'playerId': playerId});
  }

  @override
  Future<void> resume(String playerId) {
    return _channel.invokeMethod('resume', {'playerId': playerId});
  }

  @override
  Future<void> stop(String playerId) {
    return _channel.invokeMethod('stop', {'playerId': playerId});
  }

  @override
  Future<void> release(String playerId) {
    return _channel.invokeMethod('release', {'playerId': playerId});
  }

  @override
  Future<void> seek(String playerId, Duration position) {
    return _channel.invokeMethod('seek', {
      'playerId': playerId,
      'position': position.inMilliseconds,
    });
  }

  @override
  Future<void> setVolume(String playerId, double volume) {
    return _channel.invokeMethod('setVolume', {
      'playerId': playerId,
      'volume': volume,
    });
  }

  @override
  Future<void> setBalance(String playerId, double balance) {
    // Not supported on OHOS
    return Future.value();
  }

  @override
  Future<void> setPlaybackRate(String playerId, double playbackRate) {
    return _channel.invokeMethod('setPlaybackRate', {
      'playerId': playerId,
      'rate': playbackRate,
    });
  }

  @override
  Future<void> setReleaseMode(String playerId, ReleaseMode releaseMode) {
    // Not implemented yet.
    return Future.value();
  }

  @override
  Future<void> setSourceUrl(String playerId, String url,
      {bool? isLocal, String? mimeType}) {
    return _channel.invokeMethod('setSourceUrl', {
      'playerId': playerId,
      'url': url,
    });
  }

  @override
  Future<void> setSourceBytes(String playerId, Uint8List bytes,
      {String? mimeType}) {
    // Not supported on OHOS yet.
    return Future.value();
  }

  @override
  Future<void> setAudioContext(String playerId, AudioContext audioContext) {
    // Not implemented yet.
    return Future.value();
  }

  @override
  Future<void> setPlayerMode(String playerId, PlayerMode playerMode) {
    // Not implemented yet.
    return Future.value();
  }

  @override
  Future<int?> getDuration(String playerId) {
    return _channel.invokeMethod('getDuration', {'playerId': playerId});
  }

  @override
  Future<int?> getCurrentPosition(String playerId) {
    return _channel.invokeMethod('getCurrentPosition', {'playerId': playerId});
  }

  @override
  Future<void> emitLog(String playerId, String message) {
    // For testing purposes
    return Future.value();
  }

  @override
  Future<void> emitError(String playerId, String code, String message) {
    // For testing purposes
    return Future.value();
  }
}
