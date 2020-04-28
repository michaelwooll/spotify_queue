import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_queue/models/song.dart';
import 'package:spotify_sdk/models/artist.dart';

class SongCard extends StatelessWidget {
  final Song song; // Event object that will hold all the event data
  final Function callback;
  final String authToken;
  const SongCard({Key key, this.song, this.callback, this.authToken}): super(key:key); 

  @override
  Widget build(BuildContext context){
    RawMaterialButton upVoteButton = RawMaterialButton(onPressed: song.isVoted(authToken) ? null: callback, child: Icon(Icons.arrow_upward, color: Colors.white));
    return Center(
      child: Card(
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
       color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Image.network(song.getFirstImgTest()),
              title: Text(
                song.getSongName(),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.white)
                ),
                subtitle: Text( song.getFirstArtistTest(),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.white)),
                trailing : Container(
                  child:Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                    upVoteButton,
                    Text(song.getVotes().toString(), style:TextStyle(color: Colors.white))
                  ],) 
                )
                 // RawMaterialButton(child: Icon(Icons.arrow_upward),onPressed: callback)),
                //trailing: Row(children: <Widget>[RawMaterialButton(child: Icon(Icons.arrow_upward),onPressed: callback),Text("Votes: " + song.getVotes().toString())],),
            ),
            
          ], 
        ), 
      ), 
    ); 
  } 
}