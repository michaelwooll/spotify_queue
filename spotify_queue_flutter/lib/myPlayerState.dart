import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk/models/player_state.dart';

Stream<PlayerState> subscribeMyPlayerState() async*{
  while(true){
    await Future.delayed(Duration(milliseconds: 750));
    PlayerState state = await SpotifySdk.getPlayerState();
    if(state != null){
      yield state;
    }
  }
}