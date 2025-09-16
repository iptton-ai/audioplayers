type AudioEventCallback = (event: string, value: any) => void;
export declare class OHOSAudioPlayer {
    private player;
    private eventCallback;
    constructor(w1: AudioEventCallback);
    private createPlayer;
    private addPlayerListeners;
    setSourceUrl(m1: string): Promise<void>;
    play(): Promise<void>;
    pause(): Promise<void>;
    resume(): Promise<void>;
    stop(): Promise<void>;
    release(): Promise<void>;
    seek(z: number): Promise<void>;
    setVolume(w: number): Promise<void>;
    setPlaybackRate(t: number): Promise<void>;
    getDuration(): number;
    getCurrentPosition(): number;
}
export {};
