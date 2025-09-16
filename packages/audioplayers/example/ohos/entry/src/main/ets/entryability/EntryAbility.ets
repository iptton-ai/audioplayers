
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { AudioplayersOhosPlugin } from 'audioplayers_ohos/src/main/ets/com/example/audioplayers_ohos/AudioplayersOhosPlugin';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    const audioplayersPlugin = new AudioplayersOhosPlugin();
    audioplayersPlugin.registerWith(flutterEngine);
  }
}
