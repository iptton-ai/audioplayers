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
}
interface FlutterEngine {
    dartExecutor: DartExecutor;
}
interface MethodChannel {
    setMethodCallHandler(handler: MethodCallHandler): void;
    invokeMethod(method: string, args: any): void;
}
declare class MethodChannelImpl implements MethodChannel {
    constructor(r: DartExecutor, s: string);
    setMethodCallHandler(q: MethodCallHandler): void;
    invokeMethod(o: string, p: any): void;
}
declare const MethodChannel: typeof MethodChannelImpl;
import { OHOSAudioPlayer } from "@normalized:N&&&audioplayers_ohos/src/main/ets/com/example/audioplayers_ohos/OHOSAudioPlayer&1.0.0";
export class AudioplayersOhosPlugin {
    private players: Map<string, OHOSAudioPlayer> = new Map();
    private channel: MethodChannel | null = null;
    public registerWith(a: FlutterEngine) {
        const b = 'com.example.audioplayers_ohos';
        this.channel = new MethodChannel(a.dartExecutor, b);
        this.channel.setMethodCallHandler({
            onMethodCall: async (c: MethodCall, d: MethodResult) => {
                const e = c.argument['playerId'];
                if (!e) {
                    d.error('400', 'playerId is required', null);
                    return;
                }
                let f = this.players.get(e);
                if (!f) {
                    f = new OHOSAudioPlayer((m, n) => {
                        this.channel?.invokeMethod('onEvent', { ...n, playerId: e, event: m });
                    });
                    this.players.set(e, f);
                }
                switch (c.method) {
                    case 'play':
                        await f.play();
                        d.success(null);
                        break;
                    case 'pause':
                        await f.pause();
                        d.success(null);
                        break;
                    case 'resume':
                        await f.resume();
                        d.success(null);
                        break;
                    case 'stop':
                        await f.stop();
                        d.success(null);
                        break;
                    case 'release':
                        await f.release();
                        this.players.delete(e);
                        d.success(null);
                        break;
                    case 'seek':
                        const g = c.argument['position'];
                        await f.seek(g);
                        d.success(null);
                        break;
                    case 'setSourceUrl':
                        const h = c.argument['url'];
                        await f.setSourceUrl(h);
                        d.success(null);
                        break;
                    case 'setVolume':
                        const i = c.argument['volume'];
                        await f.setVolume(i);
                        d.success(null);
                        break;
                    case 'setPlaybackRate':
                        const j = c.argument['rate'];
                        await f.setPlaybackRate(j);
                        d.success(null);
                        break;
                    case 'getDuration':
                        const k = f.getDuration();
                        d.success(k);
                        break;
                    case 'getCurrentPosition':
                        const l = f.getCurrentPosition();
                        d.success(l);
                        break;
                    default:
                        d.notImplemented();
                }
            },
        });
    }
}
