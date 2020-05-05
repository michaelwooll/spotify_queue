
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotify_queue/models/database.dart';
import 'package:spotify_queue/models/queue.dart';
import 'package:spotify_queue/models/song.dart';
import 'package:random_string/random_string.dart';
import 'package:spotify_queue/models/user.dart';

class Room extends DatabaseObject{
  String _adminToken;
  String _userName;
  Queue _queue = new Queue();
  List<String> _users = [];
  Song _currentSong;
  String _roomKey;

  Room(this._adminToken):super("room"){
    _users = [];
    _currentSong = null;
    setRoomKey().then((value){
      saveToDatabase().then((docID){
        setDocID(docID);
      });
    });
  }

  Room.fromDocumentSnapshot(DocumentSnapshot ds):super("room"){
    _adminToken = ds.data["adminToken"];
    _queue.fromJSON(ds.data["queue"]);
    _roomKey = ds.data["key"];
    if(ds.data["currentSong"] != null){
      _currentSong = Song.fromJSON(ds.data["currentSong"]);
    }else{
      _currentSong = null;
    }
    for(var u in ds.data["users"]){
      _users.add(u);
    }
    setDocID(ds.documentID);
  }

  bool queueIsEmpty(){
    return _queue.songs.isEmpty;
  }

  List<Song> getSongs(){
    return _queue.songs;
  }

  String getRoomKey() => _roomKey;

  String getAdminToken() => _adminToken;

  Future<void> setRoomKey() async{
    _roomKey = randomAlphaNumeric(6);
    QuerySnapshot result = await Firestore.instance.collection("room")
    .where("key", isEqualTo: _roomKey)
    .getDocuments();
    if(result.documents.isNotEmpty){ // Key already exists
      setRoomKey();
    }
  }

  void sortQueue(){
    _queue.sortSongs();
  }

  Song getCurrentSong() => _currentSong;



  @override
  Map<String,dynamic> toJson(){
    if(_currentSong == null){
      return(
      {
        'adminToken' : _adminToken,
        'queue' : _queue.toJson(),
        'users' :_users,
        'currentSong':null,
        'key' : _roomKey
      });
    }
    else{
      return(
      {
        'adminToken' : _adminToken,
        'queue' : _queue.toJson(),
        'users' :_users,
        'currentSong':_currentSong.toJson(),
        'key' : _roomKey
      });
    }
  }

  Future<bool> addUser(String userToken) async{
    try{
      _users.add(userToken);
      updateReference();
      return true;
    }catch(e){
      debugPrint("Error adding user: " + e.toString());
      return false;
    }
  }


  Future<void> addSong(Song song) async{
    _queue.addSong(song);
    saveToDatabase();
  }

  Future<Song> pop() async{
    Song s =_queue.pop();
    _currentSong = s;
   // debugPrint("Current s= "  + s.toString());
    await saveToDatabase();
    return s;
  }
  Future<void> vote(int i, String authToken) async{
    _queue.vote(i, authToken);
    saveToDatabase();
  }
}



Future<Room> getRoomById(String docID) async{
  DocumentSnapshot doc = await Firestore.instance.collection("room").document(docID).snapshots().first;
  return Room.fromDocumentSnapshot(doc);
}

Future<Room> joinRoom(String key, String userName) async{
  QuerySnapshot result = await Firestore.instance.collection("room")
  .where('key', isEqualTo: key)
  .getDocuments();
  if(result.documents.isEmpty){
    return null;
  }
  else{
    Room r = Room.fromDocumentSnapshot(result.documents.first);
    r.addUser(userName);
    return r;
  }

}