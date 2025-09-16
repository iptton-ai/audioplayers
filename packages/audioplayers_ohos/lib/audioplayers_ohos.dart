import 'dart:async';

import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/services.dart';

/// The OHOS implementation of [AudioplayersPlatformInterface].
class AudioplayersOhos extends AudioplayersPlatformInterface {
  final Map<String, StreamController<AudioEvent>> _eventStreamControllers = {};
  static const MethodChannel _methodChannel =
      MethodChannel('xyz.luan/audioplayers');

  /// Registers this class as the default instance of [AudioplayersPlatformInterface].
  static void registerWith() {
    AudioplayersPlatformInterface.instance = AudioplayersOhos();
    GlobalAudioplayersPlatformInterface.instance = GlobalAudioplayersOhos();
  }

  @override
  Future<void> create(String playerId) async {
    // 调用原生代码创建播放器
    await _methodChannel.invokeMethod('create', {'playerId': playerId});
    // 创建事件流
    _createEventStream(playerId);
  }

  @override
  Future<void> dispose(String playerId) async {
    // 调用原生代码销毁播放器
    await _methodChannel.invokeMethod('dispose', {'playerId': playerId});
    // 清理事件流
    _disposeEventStream(playerId);
  }

  @override
  Stream<AudioEvent> getEventStream(String playerId) {
    return _eventStreamControllers[playerId]?.stream ?? const Stream.empty();
  }

  void _createEventStream(String playerId) {
    if (!_eventStreamControllers.containsKey(playerId)) {
      _eventStreamControllers[playerId] =
          StreamController<AudioEvent>.broadcast();

      // 监听原生事件
      final eventChannel =
          EventChannel('xyz.luan/audioplayers/events/$playerId');
      eventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          print('🎵 Dart: Received event: $event');
          final map = event as Map<dynamic, dynamic>;
          final eventType = map['event'] as String?;
          print('🎵 Dart: Event type: $eventType');

          AudioEvent? audioEvent;
          switch (eventType) {
            case 'audio.onPrepared':
              // 播放器准备完成
              final isPrepared = map['value'] as bool? ?? true;
              audioEvent = AudioEvent(
                  eventType: AudioEventType.prepared, isPrepared: isPrepared);
              break;
            case 'audio.onComplete':
              audioEvent = const AudioEvent(eventType: AudioEventType.complete);
              break;
            case 'audio.onDuration':
              final millis = map['value'] as int?;
              audioEvent = AudioEvent(
                eventType: AudioEventType.duration,
                duration: millis != null
                    ? Duration(milliseconds: millis)
                    : Duration.zero,
              );
              break;

            case 'audio.onError':
              final message = map['message'] as String? ?? 'Unknown error';
              final code = map['code'] as String? ?? 'UNKNOWN';
              audioEvent = AudioEvent(
                eventType: AudioEventType.log,
                logMessage: 'Error: $code - $message',
              );
              break;
          }

          if (audioEvent != null) {
            print('🎵 Dart: Adding audio event: $audioEvent');
            _eventStreamControllers[playerId]?.add(audioEvent);
          } else {
            print('🎵 Dart: No audio event created for: $eventType');
          }
        },
        onError: (error) {
          // 处理错误
        },
      );
    }
  }

  void _disposeEventStream(String playerId) {
    _eventStreamControllers[playerId]?.close();
    _eventStreamControllers.remove(playerId);
  }

  // 所有其他方法都返回未实现，因为原生代码会处理
  @override
  Future<int?> getCurrentPosition(String playerId) async {
    throw UnimplementedError('getCurrentPosition handled by native code');
  }

  @override
  Future<int?> getDuration(String playerId) async {
    throw UnimplementedError('getDuration handled by native code');
  }

  @override
  Future<void> pause(String playerId) async {
    await _methodChannel.invokeMethod('pause', {'playerId': playerId});
  }

  @override
  Future<void> release(String playerId) async {
    await _methodChannel.invokeMethod('release', {'playerId': playerId});
  }

  @override
  Future<void> resume(String playerId) async {
    await _methodChannel.invokeMethod('resume', {'playerId': playerId});
  }

  @override
  Future<void> seek(String playerId, Duration position) async {
    throw UnimplementedError('seek handled by native code');
  }

  @override
  Future<void> setBalance(String playerId, double balance) async {
    throw UnimplementedError('setBalance handled by native code');
  }

  @override
  Future<void> setPlaybackRate(String playerId, double playbackRate) async {
    throw UnimplementedError('setPlaybackRate handled by native code');
  }

  @override
  Future<void> setPlayerMode(String playerId, PlayerMode playerMode) async {
    throw UnimplementedError('setPlayerMode handled by native code');
  }

  @override
  Future<void> setReleaseMode(String playerId, ReleaseMode releaseMode) async {
    throw UnimplementedError('setReleaseMode handled by native code');
  }

  @override
  Future<void> setSourceBytes(String playerId, Uint8List bytes,
      {String? mimeType}) async {
    throw UnimplementedError('setSourceBytes handled by native code');
  }

  @override
  Future<void> setSourceUrl(String playerId, String url,
      {bool? isLocal, String? mimeType}) async {
    await _methodChannel.invokeMethod('setSourceUrl', {
      'playerId': playerId,
      'url': url,
      'isLocal': isLocal,
      'mimeType': mimeType,
    });
  }

  @override
  Future<void> setVolume(String playerId, double volume) async {
    throw UnimplementedError('setVolume handled by native code');
  }

  @override
  Future<void> stop(String playerId) async {
    throw UnimplementedError('stop handled by native code');
  }

  @override
  Future<void> emitLog(String playerId, String message) async {
    throw UnimplementedError('emitLog handled by native code');
  }

  @override
  Future<void> emitError(String playerId, String code, String message) async {
    throw UnimplementedError('emitError handled by native code');
  }

  @override
  Future<void> setAudioContext(
      String playerId, AudioContext audioContext) async {
    throw UnimplementedError('setAudioContext handled by native code');
  }
}

/// The OHOS implementation of [GlobalAudioplayersPlatformInterface].
class GlobalAudioplayersOhos extends GlobalAudioplayersPlatformInterface {
  static const MethodChannel _globalMethodChannel =
      MethodChannel('xyz.luan/audioplayers.global');

  @override
  Future<void> init() async {
    await _globalMethodChannel.invokeMethod('init');
  }

  @override
  Future<void> setGlobalAudioContext(AudioContext ctx) async {
    await _globalMethodChannel.invokeMethod('setAudioContext', ctx.toJson());
  }

  @override
  Future<void> emitGlobalLog(String message) async {
    throw UnimplementedError('emitGlobalLog handled by native code');
  }

  @override
  Future<void> emitGlobalError(String code, String message) async {
    throw UnimplementedError('emitGlobalError handled by native code');
  }

  @override
  Stream<GlobalAudioEvent> getGlobalEventStream() {
    throw UnimplementedError('getGlobalEventStream handled by native code');
  }
}
