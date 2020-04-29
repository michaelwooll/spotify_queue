import 'package:flutter/material.dart';
import 'package:spotify_queue/widgets/songWidgets.dart';
import 'package:spotify_queue/models/room.dart';
import 'package:spotify_queue/models/song.dart';


class ScrollableQueueList extends StatefulWidget {
  final List<Song> songs;
  final Room room;
  final Song currentSong;
  final String authToken;

  ScrollableQueueList({this.room,this.songs,this.currentSong, this.authToken});
  @override
  _ScrollableQueueListState createState() => _ScrollableQueueListState();
}

class _ScrollableQueueListState extends State<ScrollableQueueList> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if(widget.songs.isNotEmpty){
      widget.songs.asMap().forEach((index,song){
        children.add(SongCard(song: song, callback: ()=>widget.room.vote(index,widget.authToken), authToken: widget.authToken), 
        );
      });
    }
    else{
      children.add(Center(child:Text("Queue is empty!", style: TextStyle(color: Colors.white))));
    }
    return Expanded(
      child: ListView(children: children),
    );
  }
}