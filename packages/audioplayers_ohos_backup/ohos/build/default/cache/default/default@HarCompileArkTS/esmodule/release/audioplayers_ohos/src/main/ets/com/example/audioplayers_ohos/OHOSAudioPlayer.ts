interface BusinessError {
    code: number;
    message: string;
}
interface AVPlayer {
    url: string;
    state: string;
    duration: number;
    currentTime: number;
    volume: number;
    prepare(): Promise<void>;
    play(): Promise<void>;
    pause(): Promise<void>;
    stop(): Promise<void>;
    release(): Promise<void>;
    seek(position: number): Promise<void>;
    on(event: string, callback: (...args: any[]) => void): void;
}
interface MediaModule {
    createAVPlayer(): Promise<AVPlayer>;
}
declare const media: MediaModule;
type AudioEventCallback = (event: string, value: any) => void;
export class OHOSAudioPlayer {
    private player: AVPlayer | null = null;
    private eventCallback: AudioEventCallback | null = null;
    constructor(w1: AudioEventCallback) {
        this.eventCallback = w1;
        this.createPlayer();
    }
    private async createPlayer() {
        try {
            this.player = await media.createAVPlayer();
            console.log('AVPlayer created successfully.');
            this.addPlayerListeners();
        }
        catch (u1) {
            let v1 = u1 as BusinessError;
            console.error(`Failed to create AVPlayer: ${v1.code}, ${v1.message}`);
            this.eventCallback?.('onError', { code: v1.code, message: v1.message });
        }
    }
    private addPlayerListeners() {
        if (!this.player)
            return;
        this.player.on('stateChange', (s1: string, t1: string) => {
            console.log(`Player state changed to ${s1}`);
            this.eventCallback?.('onStateChanged', { state: s1 });
            if (s1 === 'completed') {
                this.eventCallback?.('onComplete', {});
            }
        });
        this.player.on('error', (r1: BusinessError) => {
            console.error(`Player error: ${r1.code}, ${r1.message}`);
            this.eventCallback?.('onError', { code: r1.code, message: r1.message });
        });
        this.player.on('timeUpdate', (q1: number) => {
            this.eventCallback?.('onPositionChanged', { position: q1 });
        });
        this.player.on('durationUpdate', (p1: number) => {
            this.eventCallback?.('onDurationChanged', { duration: p1 });
        });
    }
    async setSourceUrl(m1: string) {
        if (!this.player) {
            console.error('Player not initialized.');
            return;
        }
        try {
            this.player.url = m1;
            await this.player.prepare();
        }
        catch (n1) {
            let o1 = n1 as BusinessError;
            console.error(`Failed to set source: ${o1.code}, ${o1.message}`);
            this.eventCallback?.('onError', { code: o1.code, message: o1.message });
        }
    }
    async play() {
        if (!this.player) {
            console.error('Player not initialized.');
            return;
        }
        try {
            await this.player.play();
            console.log('Playing audio.');
        }
        catch (k1) {
            let l1 = k1 as BusinessError;
            console.error(`Failed to play audio: ${l1.code}, ${l1.message}`);
            this.eventCallback?.('onError', { code: l1.code, message: l1.message });
        }
    }
    async pause() {
        if (this.player && this.player.state === 'playing') {
            try {
                await this.player.pause();
                console.log('Audio paused.');
            }
            catch (i1) {
                let j1 = i1 as BusinessError;
                console.error(`Failed to pause audio: ${j1.code}, ${j1.message}`);
                this.eventCallback?.('onError', { code: j1.code, message: j1.message });
            }
        }
    }
    async resume() {
        if (this.player && (this.player.state === 'paused' || this.player.state === 'prepared')) {
            try {
                await this.player.play();
                console.log('Audio resumed.');
            }
            catch (g1) {
                let h1 = g1 as BusinessError;
                console.error(`Failed to resume audio: ${h1.code}, ${h1.message}`);
                this.eventCallback?.('onError', { code: h1.code, message: h1.message });
            }
        }
    }
    async stop() {
        if (this.player) {
            try {
                await this.player.stop();
                console.log('Audio stopped.');
            }
            catch (e1) {
                let f1 = e1 as BusinessError;
                console.error(`Failed to stop audio: ${f1.code}, ${f1.message}`);
                this.eventCallback?.('onError', { code: f1.code, message: f1.message });
            }
        }
    }
    async release() {
        if (this.player) {
            try {
                await this.player.release();
                this.player = null;
                console.log('Player released.');
            }
            catch (c1) {
                let d1 = c1 as BusinessError;
                console.error(`Failed to release player: ${d1.code}, ${d1.message}`);
                this.eventCallback?.('onError', { code: d1.code, message: d1.message });
            }
        }
    }
    async seek(z: number) {
        if (this.player) {
            try {
                await this.player.seek(z);
            }
            catch (a1) {
                let b1 = a1 as BusinessError;
                console.error(`Failed to seek: ${b1.code}, ${b1.message}`);
                this.eventCallback?.('onError', { code: b1.code, message: b1.message });
            }
        }
    }
    async setVolume(w: number) {
        if (this.player) {
            try {
                this.player.volume = w;
            }
            catch (x) {
                let y = x as BusinessError;
                console.error(`Failed to set volume: ${y.code}, ${y.message}`);
                this.eventCallback?.('onError', { code: y.code, message: y.message });
            }
        }
    }
    async setPlaybackRate(t: number) {
        if (this.player) {
            try {
                console.warn(`setPlaybackRate is not supported on OHOS yet. Requested rate: ${t}`);
            }
            catch (u) {
                let v = u as BusinessError;
                console.error(`Failed to set playback rate: ${v.code}, ${v.message}`);
                this.eventCallback?.('onError', { code: v.code, message: v.message });
            }
        }
    }
    getDuration(): number {
        return this.player?.duration ?? 0;
    }
    getCurrentPosition(): number {
        return this.player?.currentTime ?? 0;
    }
}
