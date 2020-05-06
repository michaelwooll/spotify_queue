  
import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_queue/myPlayerState.dart';

  Map<int, Color> color =
  {
    50:Color.fromRGBO(30,215,96, .1),
    100:Color.fromRGBO(30,215,96, .2),
    200:Color.fromRGBO(30,215,96, .3),
    300:Color.fromRGBO(30,215,96, .4),
    400:Color.fromRGBO(30,215,96, .5),
    500:Color.fromRGBO(30,215,96, .6),
    600:Color.fromRGBO(30,215,96, .7),
    700:Color.fromRGBO(30,215,96, .8),
    800:Color.fromRGBO(30,215,96, .9),
    900:Color.fromRGBO(30,215,96, 1),
  };

Widget playerController() {
  return StreamBuilder(
    stream: subscribeMyPlayerState(),
    builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot){
      if(snapshot.hasData){
        var playerState = snapshot.data;
        if(playerState.isPaused){
          return Container(
            child:Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MaterialButton(
                  color: color[900],
                  onPressed: () =>SpotifySdk.resume(),
                  child: Icon(Icons.play_arrow),
                  shape: CircleBorder(),
                  )
            ]),
            padding: EdgeInsets.all(8),
          );
        }
        else{
          return Container(
            child:Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MaterialButton(
                  color: color[900],
                  onPressed: () =>SpotifySdk.pause(),
                  child: Icon(Icons.pause),
                  shape: CircleBorder(),
                  )
            ]),
            padding: EdgeInsets.all(8),
          );
        }
      } // end has data
      // Show place holder so it doesnt pop out of nowhere
      return Container(
            child:Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MaterialButton(
                  color: Colors.grey,
                  onPressed: ()=>{},
                  child: Icon(Icons.play_arrow),
                  shape: CircleBorder(),
                  )
            ]),
            padding: EdgeInsets.all(8),
          );
    },
  );
}

