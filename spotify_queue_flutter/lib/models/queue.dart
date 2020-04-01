import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotify_queue/models/database.dart';
import 'package:spotify_queue/models/song.dart';


class Queue extends DatabaseObject {
  List<Song> songs = [];

  Queue():super("queue"){
    songs = [];
  }
  
  Future<String> createQueue() async{
    String docID = await saveToDatabase();
    setDocID(docID);
    return docID;
  }

  Queue.fromDocumentSnapshot(DocumentSnapshot ds):super("queue"){
    for(var s in ds.data["songs"]){
      songs.add(Song.fromJSON(s));
    }
    setDocID(ds.documentID);
  }

  void addSong(Song s){
    songs.add(s);
    songs.sort((b,a) => a.compareTo(b));
    saveToDatabase();
  }

  Future<Song> pop() async{
    if(songs.length > 0){
      Song first = songs.first;
      songs.removeAt(0);
      await saveToDatabase();
      return first;
    }
    return null;
  }

  void vote(int songIndex){
    songs[songIndex].vote();
    songs.sort((b,a) => a.compareTo(b));
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
  
  @override
  Map<String, dynamic> toJson() {
    return(
      {
        "songs":songsToJsonList()
      }
    );
  }
}