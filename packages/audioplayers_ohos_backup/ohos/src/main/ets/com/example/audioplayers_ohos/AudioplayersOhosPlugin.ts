
// import { FlutterAbility, FlutterEngine, MethodChannel, MethodCall, MethodResult } from '@ohos/flutter_ohos';

// Temporary type definitions for Flutter OHOS
interface MethodCall {
  method: string;
  argument: Record<string, any>;
}

interface MethodResult {
  success(result: any): void;
  error(errorCode: string, errorMessage: string, errorDetails: any): void;
  notImplemented(): void;
}

interface MethodCallHandler {
  onMethodCall(call: MethodCall, result: MethodResult): void;
}

interface DartExecutor {
  // Placeholder for DartExecutor interface
}

interface FlutterEngine {
  dartExecutor: DartExecutor;
}

interface MethodChannel {
  setMethodCallHandler(handler: MethodCallHandler): void;
  invokeMethod(method: string, args: any): void;
}

declare class MethodChannelImpl implements MethodChannel {
  constructor(dartExecutor: DartExecutor, channelName: string);
  setMethodCallHandler(handler: MethodCallHandler): void;
  invokeMethod(method: string, args: any): void;
}

declare const MethodChannel: typeof MethodChannelImpl;
import { OHOSAudioPlayer } from './OHOSAudioPlayer';

export class AudioplayersOhosPlugin {
  private players: Map<string, OHOSAudioPlayer> = new Map();
  private channel: MethodChannel | null = null;

  public registerWith(flutterEngine: FlutterEngine) {
    const channelName = 'com.example.audioplayers_ohos';
    this.channel = new MethodChannel(flutterEngine.dartExecutor, channelName);

    this.channel.setMethodCallHandler({
      onMethodCall: async (call: MethodCall, result: MethodResult) => {
        const playerId = call.argument['playerId'];
        if (!playerId) {
          result.error('400', 'playerId is required', null);
          return;
        }

        let player = this.players.get(playerId);
        if (!player) {
          player = new OHOSAudioPlayer((event, value) => {
            this.channel?.invokeMethod('onEvent', { ...value, playerId, event });
          });
          this.players.set(playerId, player);
        }

        switch (call.method) {
          case 'play':
            await player.play();
            result.success(null);
            break;
          case 'pause':
            await player.pause();
            result.success(null);
            break;
          case 'resume':
            await player.resume();
            result.success(null);
            break;
          case 'stop':
            await player.stop();
            result.success(null);
            break;
          case 'release':
            await player.release();
            this.players.delete(playerId);
            result.success(null);
            break;
          case 'seek':
            const position = call.argument['position'];
            await player.seek(position);
            result.success(null);
            break;
          case 'setSourceUrl':
            const url = call.argument['url'];
            await player.setSourceUrl(url);
            result.success(null);
            break;
          case 'setVolume':
            const volume = call.argument['volume'];
            await player.setVolume(volume);
            result.success(null);
            break;
          case 'setPlaybackRate':
            const rate = call.argument['rate'];
            await player.setPlaybackRate(rate);
            result.success(null);
            break;
          case 'getDuration':
            const duration = player.getDuration();
            result.success(duration);
            break;
          case 'getCurrentPosition':
            const currentPosition = player.getCurrentPosition();
            result.success(currentPosition);
            break;
          default:
            result.notImplemented();
        }
      },
    });
  }
}
