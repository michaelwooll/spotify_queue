import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotify_queue/models/database.dart';
import 'package:spotify_queue/models/song.dart';


class Queue{
  List<Song> songs = [];

  Queue(){
    songs = [];
  }
  
  void addSong(Song s){
    songs.add(s);
    songs.sort((b,a) => a.compareTo(b));

  }

  Song pop(){
    if(songs.length > 0){
      Song first = songs.first;
      songs.removeAt(0);
      return first;
    }
    return null;
  }

  void vote(int songIndex){
    songs[songIndex].vote();
    songs.sort((b,a) => a.compareTo(b));
  }

  void fromJSON(Map<String,dynamic> json){
    songs = [];
    if(json["songs"] != null){
      for(var song in json["songs"]){
        songs.add(Song.fromJSON(song));
      } 
    }
  }

  @override
  String toString() {
    String asString = "";
    for(var song in songs){
      asString += song.toString() + "\n";
    }
    return asString;
  }

  List<Map<String,dynamic>> songsToJsonList(){
    List<Map<String,dynamic>> list = [];
    for(var s in songs){
      list.add(s.toJson());
    }
    return list;
  }
  
  Map<String, dynamic> toJson() {
    return(
      {
        "songs":songsToJsonList()
      }
    );
  }
}