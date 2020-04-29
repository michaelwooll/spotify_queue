import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotify_queue/widgets/scrollableQueueList.dart';
import 'package:spotify_queue/widgets/songWidgets.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_queue/models/room.dart';
import 'package:spotify_queue/models/song.dart';

import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_queue/spotifyAPI.dart';


class QueueViewBuilder extends StatefulWidget {
  QueueViewBuilder({Key key, this.roomID,this.authToken}):super(key:key);
  final String roomID;
  final String authToken;
  @override
  _QueueViewBuilderState createState() => _QueueViewBuilderState();
}

class _QueueViewBuilderState extends State<QueueViewBuilder> {
  TextEditingController searchCon = new TextEditingController();
  bool queueControllerInitialized = false;
  Room r;

  // Talks to spotify sdk to handle queue
  Future<void> queueController() async{
    queueControllerInitialized = true;
    int timeLeft;
      while(true){
        try{
          await Future.delayed(Duration(milliseconds: 100));
          PlayerState state = await SpotifySdk.getPlayerState();
          if(state.track != null){
            timeLeft = state.track.duration - state.playbackPosition;
            if(timeLeft <= 3000){ // 3 seconds until current song is over
              if(r != null){ // If room exists
                Song song = await r.pop(); // Pop song
                if(song != null){ // If there was a song to pop
                  SpotifySdk.queue(spotifyUri: song.getURI()); // queue up
                }
                await Future.delayed(Duration(seconds: 5)); // Wait 5 seconds before checking again
              }
            }
          }
      } // end try
      catch(e){
        //Lost connection or logged out
        // Should probably do something here...
        debugPrint("Logged out!");
        return;
      }  // end catch
    }// end while
  }

  void test(String input, Room room) async {
    Map<String,List<dynamic>> results = await fullSearch(input,widget.authToken);
    List<Song> songs = results["songs"];
    for(var i = 0; i < 3 && i != songs.length; i++){
      Song s = songs[i];
      await room.addSong(s);
    }
    if(room.getCurrentSong() == null){
        Song song = await room.pop();
        SpotifySdk.play(spotifyUri: song.getURI());
    }
}

  @override
  Widget build(BuildContext context) { 
    String roomKey = "";
    return StreamBuilder(
      stream: Firestore.instance.collection("room").document(widget.roomID).snapshots(),
      builder: (context, snapshot){
        List<Widget> children = [];
        if(!snapshot.hasData){
          // Add padding
          children.add(
            const Padding(
              padding: EdgeInsets.only(top: 100),
            )
          );
          children.add(
            Center(
              child: SizedBox(
              child: CircularProgressIndicator(),
              width: 100,
              height: 100,
              )
            )
          );
          children.add(
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: Text('Creating room...'),
              )
            )
          );
        }
        else if(snapshot.hasError){
          roomKey = "ERROR";
          children.add(Text("Error has occured"));
        }
        else if(snapshot.hasData && snapshot.data.data != null){
          r = new Room.fromDocumentSnapshot(snapshot.data);
          roomKey = r.getRoomKey();
          r.sortQueue();
          if(!queueControllerInitialized){
            queueController();
          }
          // Search bar
          
          children.add(TextField(
            controller: searchCon,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Search',
            )
          ));
           children.add(
            RaisedButton(
              onPressed: () => test(searchCon.text,r),
              child:Text("Test add songs")
            )
          );
          if(r.getCurrentSong() != null){
            children.add(
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child:Text("Now Playing:",  style: TextStyle(color: Colors.white))),
                  SongCard(song: r.getCurrentSong())
                ]));
          }
          children.add(Padding(
            padding: const EdgeInsets.all(10),
            child:
              Text("Your queue", style: TextStyle(color: Colors.white)
              )
            )
          );
          children.add(ScrollableQueueList(songs: r.getSongs(), room:r, authToken: widget.authToken));
          //children.add(Center(child:PlayerController()));
          if(r.getCurrentSong()!= null){
           // children.add(PlayerController());
          }
       
          } // end snapshot
        
        return Center(
            child: Column(
              children: children,
            ),
        );
      } // end build 
    );
  }
}


/*
/* Adapted from https://github.com/brim-borium/spotify_sdk/blob/develop/example/lib/main.dart */
Widget playerStateWidget() {
    return StreamBuilder<PlayerState>(
      stream: subscribeMyPlayerState(),
      initialData: PlayerState(null, false, 1, 1, null, null),
      builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
        if (snapshot.data != null && snapshot.data.track != null) {
          var playerState = snapshot.data;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                  "${playerState.track.name} by ${playerState.track.artist.name} from the album ${playerState.track.album.name} "),
              Text("Speed: ${playerState.playbackSpeed}"),
              Text(
                  "Progress: ${playerState.playbackPosition}ms/${playerState.track.duration}ms"),
              LinearProgressIndicator(
                value: (playerState.playbackPosition/playerState.track.duration),
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey)
              ),
              Text("IsPaused: ${playerState.isPaused}"),
              Text("Is Shuffling: ${playerState.playbackOptions.isShuffling}"),
              Text("RepeatMode: ${playerState.playbackOptions.repeatMode}"),
              Text("Image URI: ${playerState.track.imageUri.raw}"),
              Text(
                  "Is episode? ${playerState.track.isEpisode}. Is podcast?: ${playerState.track.isPodcast}"),
            ],
          );
        } else {
          return Center(
            child: Text("Not connected"),
          );
        }
      },
    );
  }

Stream<PlayerState> subscribeMyPlayerState() async*{
  while(true){
    await Future.delayed(Duration(milliseconds: 750));
    PlayerState state = await SpotifySdk.getPlayerState();
    if(state != null){
      yield state;
    }
  }
}*/