import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_queue/models/song.dart';
import 'package:spotify_sdk/models/artist.dart';

class SongCard extends StatelessWidget {
  final Song song; // Event object that will hold all the event data
  const SongCard({Key key, this.song}): super(key:key); 

  @override
  Widget build(BuildContext context){
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Image.network(song.getFirstImgTest()),
              title: Text(
                song.getSongName(),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.blueGrey)
                ),
                subtitle: Text( song.getFirstArtistTest(),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.black)),
                trailing: Text("Votes: " + song.getVotes().toString()),
            )
          ], 
        ), 
      ), 
    ); 
  } 
}