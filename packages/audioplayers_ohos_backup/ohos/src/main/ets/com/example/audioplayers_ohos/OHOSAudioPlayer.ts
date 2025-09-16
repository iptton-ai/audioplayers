
// import { BusinessError } from '@ohos.base';
// import media from '@ohos.multimedia.media';

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

  constructor(eventCallback: AudioEventCallback) {
    this.eventCallback = eventCallback;
    this.createPlayer();
  }

  private async createPlayer() {
    try {
      this.player = await media.createAVPlayer();
      console.log('AVPlayer created successfully.');
      this.addPlayerListeners();
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to create AVPlayer: ${err.code}, ${err.message}`);
      this.eventCallback?.('onError', { code: err.code, message: err.message });
    }
  }

  private addPlayerListeners() {
    if (!this.player) return;

    this.player.on('stateChange', (state: string, reason: string) => {
      console.log(`Player state changed to ${state}`);
      this.eventCallback?.('onStateChanged', { state });
      if (state === 'completed') {
        this.eventCallback?.('onComplete', {});
      }
    });

    this.player.on('error', (err: BusinessError) => {
      console.error(`Player error: ${err.code}, ${err.message}`);
      this.eventCallback?.('onError', { code: err.code, message: err.message });
    });

    this.player.on('timeUpdate', (time: number) => {
      this.eventCallback?.('onPositionChanged', { position: time });
    });

    this.player.on('durationUpdate', (duration: number) => {
      this.eventCallback?.('onDurationChanged', { duration });
    });
  }

  async setSourceUrl(url: string) {
    if (!this.player) {
      console.error('Player not initialized.');
      return;
    }
    try {
      this.player.url = url;
      await this.player.prepare();
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to set source: ${err.code}, ${err.message}`);
      this.eventCallback?.('onError', { code: err.code, message: err.message });
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
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to play audio: ${err.code}, ${err.message}`);
      this.eventCallback?.('onError', { code: err.code, message: err.message });
    }
  }

  async pause() {
    if (this.player && this.player.state === 'playing') {
      try {
        await this.player.pause();
        console.log('Audio paused.');
      } catch (error) {
        let err = error as BusinessError;
        console.error(`Failed to pause audio: ${err.code}, ${err.message}`);
        this.eventCallback?.('onError', { code: err.code, message: err.message });
      }
    }
  }

  async resume() {
    if (this.player && (this.player.state === 'paused' || this.player.state === 'prepared')) {
      try {
        await this.player.play();
        console.log('Audio resumed.');
      } catch (error) {
        let err = error as BusinessError;
        console.error(`Failed to resume audio: ${err.code}, ${err.message}`);
        this.eventCallback?.('onError', { code: err.code, message: err.message });
      }
    }
  }

  async stop() {
    if (this.player) {
      try {
        await this.player.stop();
        console.log('Audio stopped.');
      } catch (error) {
        let err = error as BusinessError;
        console.error(`Failed to stop audio: ${err.code}, ${err.message}`);
        this.eventCallback?.('onError', { code: err.code, message: err.message });
      }
    }
  }

  async release() {
    if (this.player) {
      try {
        await this.player.release();
        this.player = null;
        console.log('Player released.');
      } catch (error) {
        let err = error as BusinessError;
        console.error(`Failed to release player: ${err.code}, ${err.message}`);
        this.eventCallback?.('onError', { code: err.code, message: err.message });
      }
    }
  }

  async seek(position: number) {
    if (this.player) {
      try {
        await this.player.seek(position);
      } catch (error) {
        let err = error as BusinessError;
        console.error(`Failed to seek: ${err.code}, ${err.message}`);
        this.eventCallback?.('onError', { code: err.code, message: err.message });
      }
    }
  }

  async setVolume(volume: number) {
    if (this.player) {
      try {
        this.player.volume = volume;
      } catch (error) {
        let err = error as BusinessError;
        console.error(`Failed to set volume: ${err.code}, ${err.message}`);
        this.eventCallback?.('onError', { code: err.code, message: err.message });
      }
    }
  }

  async setPlaybackRate(rate: number) {
    if (this.player) {
      try {
        // Note: AVPlayer might not support playback rate directly.
        // This is a placeholder.
        console.warn(`setPlaybackRate is not supported on OHOS yet. Requested rate: ${rate}`);
      } catch (error) {
        let err = error as BusinessError;
        console.error(`Failed to set playback rate: ${err.code}, ${err.message}`);
        this.eventCallback?.('onError', { code: err.code, message: err.message });
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
