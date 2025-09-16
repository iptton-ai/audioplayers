interface DartExecutor {
}
interface FlutterEngine {
    dartExecutor: DartExecutor;
}
export declare class AudioplayersOhosPlugin {
    private players;
    private channel;
    registerWith(a: FlutterEngine): void;
}
export {};
