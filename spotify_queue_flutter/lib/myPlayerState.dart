import 'package:flutter/cupertino.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_queue/widgets/queueViewAdmin.dart';
Stream<PlayerState> subscribeMyPlayerState() async*{
  while(true){
    await Future.delayed(Duration(milliseconds: 300));
    if(!loggedOut){
      try{
         PlayerState state = await SpotifySdk.getPlayerState();
        if(state != null){
          yield state;
        }
      }
      catch(e){
        debugPrint("Error getting player state!");
        debugPrint(e.toString());
      }
     
    }
    else{
      yield null;
    }

  }
}