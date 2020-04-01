import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_queue/models/room.dart';
import 'package:spotify_queue/models/song.dart';
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
  bool queueIdSet = false;
 // bool songIsPaused = true;

  void queueIDTimer(Duration interval, Room r, int maxIter) async {
    int i = 0;
    while (i < maxIter) {
      debugPrint("Checking queue id");
      await Future.delayed(interval);
      if(r.getQueueID() != null){
        setState(() {
          queueIdSet = true;
        });
        return;
      }
      i++;
    }
    debugPrint("failed");
  }
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
    //queueController();
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
    bool done = false;
    if(room == null && !queueIdSet){
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
       done = true;
    }
    else if(!queueIdSet){
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
      queueIDTimer(Duration(milliseconds: 500), room, 10);
      done = true;
      
    }
    else{
      debugPrint("Success!");
      room.getQueue().then((queue){
        if(queue.songs.isEmpty){
          children.add(Text("No songs currently in queue"));
        }
        else{
          children.add(Text("Current queue"));
          for(var s in queue.songs){
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
        }
        done = true;
      });
    }
    while(!done);
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