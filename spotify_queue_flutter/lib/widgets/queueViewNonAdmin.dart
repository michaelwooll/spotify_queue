import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotify_queue/widgets/scrollableQueueList.dart';
import 'package:spotify_queue/widgets/songWidgets.dart';
import 'package:spotify_queue/models/room.dart';
import 'package:spotify_queue/models/song.dart';
import 'package:spotify_queue/spotifyAPI.dart';


class QueueViewBuilderNonAdmin extends StatefulWidget {
  QueueViewBuilderNonAdmin({Key key, this.roomID,this.authToken}):super(key:key);
  final String roomID;
  final String authToken;
  @override
  _QueueViewBuilderNonAdminState createState() => _QueueViewBuilderNonAdminState();
}

class _QueueViewBuilderNonAdminState extends State<QueueViewBuilderNonAdmin> {
  TextEditingController searchCon = new TextEditingController();
  // Talks to spotify sdk to handle queue
  
  void test(String input, Room room) async {
    Map<String,List<dynamic>> results = await fullSearch(input,widget.authToken);
    List<Song> songs = results["songs"];
    for(var i = 0; i < 3 && i != songs.length; i++){
      Song s = songs[i];
      await room.addSong(s);
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
                child: Text('Joining room...'),
              )
            )
          );
        }
        else if(snapshot.hasError){
          roomKey = "ERROR";
          children.add(Text("Error has occured"));
        }
        else if(snapshot.hasData && snapshot.data.data != null){
          Room r = new Room.fromDocumentSnapshot(snapshot.data);
          roomKey = r.getRoomKey();
          r.sortQueue();
          // Search bar
          /*
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
        */
          // Show current song
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

          } // end snapshot
        
        return 
          Center(
            child: Column(
              children: children,
            ),
        );
      } // end build 
    );
  }
}
