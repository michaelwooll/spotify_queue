import 'package:flutter/material.dart';
import 'package:spotify_queue/widgets/songWidgets.dart';
import 'package:spotify_queue/models/room.dart';
import 'package:spotify_queue/models/song.dart';


class ScrollableQueueList extends StatefulWidget {
  final List<Song> songs;
  final Room room;
  final Song currentSong;
  ScrollableQueueList({this.room,this.songs,this.currentSong});
  @override
  _ScrollableQueueListState createState() => _ScrollableQueueListState();
}

class _ScrollableQueueListState extends State<ScrollableQueueList> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if(widget.songs.isNotEmpty){
      widget.songs.asMap().forEach((index,song){
        children.add(SongCard(song: song, callback: ()=>widget.room.vote(index)), 
        );
      });
    }
    else{
      children.add(Text("Queue is empty!"));
    }
    return Expanded(
      child: ListView(children: children),
    );
  }
}

/*
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
            children.add(PlayerController());
          }

*/