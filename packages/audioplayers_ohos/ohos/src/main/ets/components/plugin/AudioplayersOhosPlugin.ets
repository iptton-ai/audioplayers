import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
  EventChannel,
  EventSink,
  StreamHandler,
  BinaryMessenger,
} from '@ohos/flutter_ohos';
import { OHOSAudioPlayer } from './OHOSAudioPlayer';

class AudioEventData {
  playerId?: string;
  event?: string;
  state?: string;
  code?: number;
  message?: string;
  position?: number;
  duration?: number;
}

class GlobalEventStreamHandler implements StreamHandler {
  private eventSink: EventSink | null = null;

  onListen(args: Object, eventSink: EventSink): void {
    this.eventSink = eventSink;
  }

  onCancel(args: Object): void {
    this.eventSink = null;
  }

  sendEvent(event: Record<string, Object>): void {
    this.eventSink?.success(event);
  }
}

class PlayerEventStreamHandler implements StreamHandler {
  private eventSink: EventSink | null = null;

  onListen(args: Object, eventSink: EventSink): void {
    this.eventSink = eventSink;
  }

  onCancel(args: Object): void {
    this.eventSink = null;
  }

  sendEvent(event: Record<string, Object>): void {
    this.eventSink?.success(event);
  }
}

class GlobalMethodCallHandler implements MethodCallHandler {
  private plugin: AudioplayersOhosPlugin;

  constructor(plugin: AudioplayersOhosPlugin) {
    this.plugin = plugin;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    const args = call.args as Record<string, Object>;
    console.error(`🎵 OHOS Plugin: Global method called: ${call.method}, args: ${JSON.stringify(args)}`);

    switch (call.method) {
      case "init":
        this.plugin.handleGlobalInit(result);
        break;
      case "setAudioContext":
        this.plugin.handleSetAudioContext(args, result);
        break;
      default:
        console.warn(`OHOS Plugin: Unhandled global method: ${call.method}`);
        result.notImplemented();
    }
  }
}

/** AudioplayersOhosPlugin **/
export default class AudioplayersOhosPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private globalChannel: MethodChannel | null = null;
  private globalEventChannel: EventChannel | null = null;
  private globalEventHandler: GlobalEventStreamHandler = new GlobalEventStreamHandler();
  private players: Map<string, OHOSAudioPlayer> = new Map();
  private playerEventHandlers: Map<string, PlayerEventStreamHandler> = new Map();
  private binaryMessenger: BinaryMessenger | null = null;
  private globalMethodHandler: GlobalMethodCallHandler;

  constructor() {
    this.globalMethodHandler = new GlobalMethodCallHandler(this);
  }

  getUniqueClassName(): string {
    return "AudioplayersOhosPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.binaryMessenger = binding.getBinaryMessenger();
    this.channel = new MethodChannel(this.binaryMessenger, "xyz.luan/audioplayers");
    this.channel.setMethodCallHandler(this);

    this.globalChannel = new MethodChannel(this.binaryMessenger, "xyz.luan/audioplayers.global");
    this.globalChannel.setMethodCallHandler(this.globalMethodHandler);

    this.globalEventChannel = new EventChannel(this.binaryMessenger, "xyz.luan/audioplayers.global/events");
    this.globalEventChannel.setStreamHandler(this.globalEventHandler);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
    }
    if (this.globalChannel != null) {
      this.globalChannel.setMethodCallHandler(null);
    }
    if (this.globalEventChannel != null) {
      // this.globalEventChannel.setStreamHandler(null);
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    const args = call.args as Record<string, Object>;

    console.error(`🎵 OHOS Plugin: Player method called: ${call.method}, args: ${JSON.stringify(args)}`);

    // 处理播放器方法 - 使用 call.argument() 方法获取参数
    const playerId = call.argument('playerId') as string;
    switch (call.method) {
      case "create":
        this.handleCreate(playerId, result);
        break;
      case "dispose":
        this.handleDispose(playerId, result);
        break;
      default:
        // 对于其他方法，需要确保播放器存在
        const player = this.players.get(playerId);
        if (!player) {
          result.error('404', `Player ${playerId} not found`, null);
          return;
        }
        this.handlePlayerMethod(call, player, result);
    }
  }

  private handleCreate(playerId: string, result: MethodResult): void {
    if (this.players.has(playerId)) {
      result.success(null);
      return;
    }

    // 创建播放器事件通道
    const eventChannel = new EventChannel(this.binaryMessenger!, `xyz.luan/audioplayers/events/${playerId}`);
    const eventHandler = new PlayerEventStreamHandler();
    eventChannel.setStreamHandler(eventHandler);
    this.playerEventHandlers.set(playerId, eventHandler);

    const player = new OHOSAudioPlayer((event: string, value: AudioEventData) => {
      const eventData = new Map<string, Object>();
      eventData.set('event', event);

      // 根据事件类型设置不同的值
      switch (event) {
        case 'audio.onPrepared':
          // 对于 onPrepared 事件，value 应该是 boolean
          eventData.set('value', true);
          break;
        case 'audio.onComplete':
          // 对于 onComplete 事件，value 应该是 boolean
          eventData.set('value', true);
          break;
        case 'audio.onDuration':
          // 对于 onDuration 事件，value 应该是 duration 的毫秒数
          if (value.duration !== undefined) eventData.set('value', value.duration);
          break;
        default:
          // 对于其他事件，使用原来的逻辑
          if (value.state) eventData.set('value', value.state);
          if (value.code !== undefined) eventData.set('code', value.code);
          if (value.message) eventData.set('message', value.message);
          if (value.position !== undefined) eventData.set('value', value.position);
          break;
      }

      // 发送事件到事件通道
      const eventObj: Record<string, Object> = {};
      eventData.forEach((value, key) => {
        eventObj[key] = value;
      });
      console.log(`🎵 Sending event: ${JSON.stringify(eventObj)}`);
      eventHandler.sendEvent(eventObj);
    });

    this.players.set(playerId, player);
    console.error(`🎵 OHOS Plugin: Created player ${playerId}`);
    result.success(null);
  }

  private handleDispose(playerId: string, result: MethodResult): void {
    const player = this.players.get(playerId);
    if (player) {
      player.release().then(() => {
        this.players.delete(playerId);
        this.playerEventHandlers.delete(playerId);
        console.error(`🎵 OHOS Plugin: Disposed player ${playerId}`);
        result.success(null);
      }).catch((err: Error) => {
        result.error('500', 'Failed to dispose player', err.message);
      });
    } else {
      result.success(null);
    }
  }

  handleGlobalInit(result: MethodResult): void {
    console.error(`🎵 OHOS Plugin: Global init called`);
    // 清理所有现有播放器
    this.players.forEach((player: OHOSAudioPlayer, playerId: string) => {
      player.release().catch((err: Error) => {
        console.error(`Failed to release player ${playerId}: ${err.message}`);
      });
    });
    this.players.clear();
    result.success(null);
  }

  handleSetAudioContext(args: Record<string, Object>, result: MethodResult): void {
    console.error(`🎵 OHOS Plugin: setAudioContext called with args: ${JSON.stringify(args)}`);
    // OHOS 暂不支持全局音频上下文设置
    result.success(null);
  }

  private handlePlayerMethod(call: MethodCall, player: OHOSAudioPlayer, result: MethodResult): void {
    const args = call.args as Record<string, Object>;
    console.error(`🎵 OHOS Plugin: handlePlayerMethod - method: ${call.method}, args: ${JSON.stringify(args)}`);

    switch (call.method) {
      case "setSourceUrl":
        const url = call.argument('url') as string;
        const isLocal = call.argument('isLocal') as boolean;
        const mimeType = call.argument('mimeType') as string;
        console.error(`🎵 OHOS Plugin: setSourceUrl - url: ${url}, isLocal: ${isLocal}, mimeType: ${mimeType}`);
        player.setSourceUrl(url, isLocal).then(() => result.success(null)).catch((err: Error) => {
          result.error('500', 'Failed to set source URL', err.message);
        });
        break;
      case "play":
        player.play().then(() => result.success(null)).catch((err: Error) => {
          result.error('500', 'Failed to play', err.message);
        });
        break;
      case "pause":
        player.pause().then(() => result.success(null)).catch((err: Error) => {
          result.error('500', 'Failed to pause', err.message);
        });
        break;
      case "resume":
        player.resume().then(() => result.success(null)).catch((err: Error) => {
          result.error('500', 'Failed to resume', err.message);
        });
        break;
      case "stop":
        player.stop().then(() => result.success(null)).catch((err: Error) => {
          result.error('500', 'Failed to stop', err.message);
        });
        break;
      case "release":
        player.release().then(() => {
          result.success(null);
        }).catch((err: Error) => {
          result.error('500', 'Failed to release', err.message);
        });
        break;
      case "seek":
        const position = args['position'] as number;
        player.seek(position).then(() => result.success(null)).catch((err: Error) => {
          result.error('500', 'Failed to seek', err.message);
        });
        break;
      case "setVolume":
        const volume = args['volume'] as number;
        player.setVolume(volume).then(() => result.success(null)).catch((err: Error) => {
          result.error('500', 'Failed to set volume', err.message);
        });
        break;
      case "setPlaybackRate":
        const playbackRate = args['playbackRate'] as number;
        player.setPlaybackRate(playbackRate).then(() => result.success(null)).catch((err: Error) => {
          result.error('500', 'Failed to set playback rate', err.message);
        });
        break;
      case "getDuration":
        const duration = player.getDuration();
        result.success(duration);
        break;
      case "getCurrentPosition":
        const currentPosition = player.getCurrentPosition();
        result.success(currentPosition);
        break;
      case "setBalance":
        // OHOS 暂不支持音频平衡设置
        result.success(null);
        break;
      case "setPlayerMode":
        // OHOS 暂不支持播放器模式设置
        result.success(null);
        break;
      case "setReleaseMode":
        // OHOS 暂不支持释放模式设置
        result.success(null);
        break;
      case "setAudioContext":
        // OHOS 暂不支持音频上下文设置
        result.success(null);
        break;
      case "setSourceBytes":
        // OHOS 暂不支持字节数组音源
        result.error('501', 'setSourceBytes not implemented on OHOS', null);
        break;
      default:
        console.warn(`OHOS Plugin: Unhandled method: ${call.method}`);
        result.notImplemented();
    }
  }
}