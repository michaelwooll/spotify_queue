import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
      await Future.delayed(Duration(milliseconds: 100));
      PlayerState state = await SpotifySdk.getPlayerState();
      if(state.track != null){
        timeLeft = state.track.duration - state.playbackPosition;

        if(timeLeft <= 3000){
          if(r != null){
            Song song = await r.pop();
            if(song != null){
              SpotifySdk.queue(spotifyUri: song.getURI());
              await Future.delayed(Duration(seconds: 5));
            }
          }
        }
      }
    }
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

         // Show the current queue
          if(!r.queueIsEmpty()){
            r.getSongs().asMap().forEach((index,song){
                children.add(
                  GestureDetector(
                    child: SongCard(song: song), 
                    onTap: (){
                      r.vote(index);
                    }
                    ,)
                  );
            });
          } // end queue is not empty            
            else{
              children.add(Text("Queue is currently empty"));
            }
          // Show current song
          if(r.getCurrentSong() != null){
            children.add(
              Column(
                children: <Widget>[
                  Text("Now Playing:"),
                  SongCard(song: r.getCurrentSong())
                ]));
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
class QueueView extends StatefulWidget {
  QueueView({Key key, this.roomID,this.authToken}):super(key:key);
  final String roomID;
  final String authToken;

  @override
  _QueueViewState createState() => _QueueViewState();
}

class _QueueViewState extends State<QueueView> {
  Room room;
  Song currentSong;
  TextEditingController searchCon = new TextEditingController();

  @override
  void initState() {
    super.initState();
    // Grab room data from DB
    debugPrint(widget.roomID);
    getRoomById(widget.roomID).then((roomObject){
      setState(() {
        room = roomObject; 
      });
      queueController();
    });
  }



  void testSearch(String input) async {
    Map<String,List<String>> results = await search(input,widget.authToken);
    List<Song> songs = await searchTracks(results["tracks"],widget.authToken);
    for(var i = 0; i < 3 && i  < songs.length; i++){
      room.addSong(songs[i]);
    }
    if(currentSong == null){
      Song song = await room.pop();
      SpotifySdk.play(spotifyUri: song.getURI());
      setState(() {
        currentSong = song;
      });
    }
    else{
      setState((){}); // Force a setState because room as been changed
    }
  } 

  void resume() async{
    try {
      await SpotifySdk.resume();
    } catch(e){
      debugPrint(e.toString());
    }
  }

  void pause() async{
    try {
      await SpotifySdk.pause();
    } catch(e){
      debugPrint(e.toString());
    }
  }

void test(String input) async {
  Map<String,List<dynamic>> results = await fullSearch(input,widget.authToken);
  debugPrint(results["albums"].toString());
  for(var i = 0; i < 3 && i != results["songs"].length; i++){
    room.addSong(results["songs"][i]);
    debugPrint("here");
  }
  if(currentSong == null){
      Song song = await room.pop();
      SpotifySdk.play(spotifyUri: song.getURI());
      setState(() {
        currentSong = song;
      });
    }
    else{
      setState((){}); // Force a setState because room as been changed
    }
}

  
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    return new StreamBuilder(
      stream: Firestore.instance.collection("room").document(widget.roomID).snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
           children = <Widget>[const Padding(
              padding: EdgeInsets.only(top: 100),
            ),
            Center(
              child: SizedBox(
              child: CircularProgressIndicator(),
              width: 100,
              height: 100,
            )
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: Text('Creating room...'),
              )
            )
       ];
        }else{
          Room r = new Room.fromDocumentSnapshot(snapshot.data);
          children.add(TextField(
          controller: searchCon,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Search',
          )
          ));
        if(r.queueIsEmpty()){
          children.add(Text("No songs currently in queue"));
          if(currentSong != null){
          children.add(
              Column(
                children: <Widget>[
                  Text("Now Playing:"),
                  SongCard(song: currentSong)
                ]));
          }
          // children.add(playerStateWidget());
            children.add(
            RaisedButton(
              onPressed: () => test(searchCon.text),
              child:Text("Test")
            )
          );
        }
        else{
          r.getSongs().asMap().forEach((index,song){
              children.add(
                GestureDetector(
                  child: SongCard(song: song), 
                  onTap: (){
                    r.vote(index);
                    setState(() {
                      
                    });
                  }
                  ,)
                );
          });
          if(currentSong != null){
            //children.add(Text("Current song: " + currentSong.toString()));
            children.add(
              Column(
                children: <Widget>[
                  Text("Now Playing:"),
                  SongCard(song: currentSong)
                ]));
          }
          children.add(
            FloatingActionButton(
                  onPressed: resume,
                  tooltip: 'Play',
                  child: Icon(Icons.play_arrow),
              )
          );
          children.add(
            FloatingActionButton(
                  onPressed: pause,
                  tooltip: 'Pause',
                  child: Icon(Icons.pause),
              )
          );
           children.add(
            RaisedButton(
              onPressed: () => testSearch(searchCon.text),
              child:Text("Add 3 searched songs")
            )
          );
        }// end else

        }
        return Scaffold(
          appBar: AppBar(
            title: Text("Your room"),
          ),
          body: Center(
            child: Column(
              children: children,
            ),
          )
        );
      }
    );
  } // end build
}
/*


*/


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