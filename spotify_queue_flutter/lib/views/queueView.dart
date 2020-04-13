import 'package:flutter/material.dart';
import 'package:spotify_queue/widgets/songWidgets.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_queue/models/room.dart';
import 'package:spotify_queue/models/song.dart';
import 'package:spotify_queue/models/album.dart';

import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_queue/spotifyAPI.dart';

String hardCodedSearchValue = "Powfu";




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
     // queueController();
    });
  }

  Future<void> queueController() async{
    int timeLeft;
    while(true){
      await Future.delayed(Duration(milliseconds: 100));
      PlayerState state = await SpotifySdk.getPlayerState();
      if(state.track != null){
        timeLeft = state.track.duration - state.playbackPosition;
 
        if(timeLeft <= 3000){
          if(room != null){
            Song song = await room.pop();
            setState(() {
                currentSong = song;
            });
            if(song != null){
              SpotifySdk.queue(spotifyUri: song.getURI());
              await Future.delayed(Duration(seconds: 5));
            }
          }
        }
      }
    }
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
        children.add(TextField(
          controller: searchCon,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Search',
          )
          ));
        if(room.queueIsEmpty()){
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
          room.getSongs().asMap().forEach((index,song){
              children.add(
                GestureDetector(
                  child: SongCard(song: song), 
                  onTap: (){
                    room.vote(index);
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
       // children.add(playerStateWidget());
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
}