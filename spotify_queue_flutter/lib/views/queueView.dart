import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_queue/models/room.dart';
import 'package:spotify_queue/models/song.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/models/player_state.dart';



class QueuePage extends StatelessWidget{
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Queue',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QueueView(),
    );
   } // build
}

class QueueView extends StatefulWidget {
  QueueView({Key key, this.roomID}):super(key:key);
  final String roomID;
  @override
  _QueueViewState createState() => _QueueViewState();
}

class _QueueViewState extends State<QueueView> {
  Room room;
  bool initialized = false;
  Song currentSong;

  @override
  void initState() {
    super.initState();
    // Grab room data from DB
    debugPrint(widget.roomID);
    getRoomById(widget.roomID).then((roomObject){
      setState(() {
        room = roomObject; 
      });
    });
    queueController();
  }

  Future<void> queueController() async{
    bool notQueued = true;
    int timeLeft;
    while(true){
      await Future.delayed(Duration(milliseconds: 100));
      PlayerState state = await SpotifySdk.getPlayerState();
      if(state.track != null){
        timeLeft = state.track.duration - state.playbackPosition;
        if(timeLeft > 3000){
          notQueued = true;
        }
        debugPrint("timeleft: " + timeLeft.toString());
        if(timeLeft <= 3000 && notQueued){
          debugPrint("queueing next song");
          if(room != null){
            Song q = await room.pop();
            if(q != null){
              SpotifySdk.queue(spotifyUri: q.getURI());
              notQueued = false;
              setState(() {
                
              });
            }
          }
        }
      }
    }
  }

   void addSong() async{
    await room.addSong("spotify:track:4fPBB44eDH71YohayI4eKV");
    await room.addSong("spotify:track:6lnnaGN20kl0jEYJSxCgU9");
    await room.addSong("spotify:track:0dy6iXYIF0piirySAzCBwF");
    if(!initialized){
      Song song = await room.pop();
      SpotifySdk.play(spotifyUri: song.getURI());
      setState(() {
        initialized = true;
      });
    }
    else{
      setState((){}); // Force a setState because room as been changed
    }
  }

  void play() async{
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

  
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if(room == null){
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
    }
    else{
      debugPrint("Success!");
        if(room.queueIsEmpty()){
          children.add(Text("No songs currently in queue"));
          children.add(PlayerStateWidget());
           children.add(
            RaisedButton(
              onPressed: addSong,
              child:Text("Add 3 songs")
            )
          );
        }
        else{
          children.add(Text("Current queue"));
          for(var s in room.getSongs()){
            children.add(Text(s.toString()));
          }
          children.add(
            FloatingActionButton(
                  onPressed: play,
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
              onPressed: addSong,
              child:Text("Add 3 songs")
            )
          );
          children.add(PlayerStateWidget());
        }
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
}


 Widget PlayerStateWidget() {
    return StreamBuilder<PlayerState>(
      stream: SpotifySdk.subscribePlayerState(),
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