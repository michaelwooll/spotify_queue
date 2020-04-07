
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotify_queue/models/database.dart';
import 'package:spotify_queue/models/queue.dart';
import 'package:spotify_queue/models/song.dart';




class Room extends DatabaseObject{
  String _adminToken;
  Queue _queue = new Queue();
  List<String> _users;

  Room(this._adminToken):super("room"){
    _users = [];
    saveToDatabase().then((docID){
      setDocID(docID);
    });
  }

  Room.fromDocumentSnapshot(DocumentSnapshot ds):super("room"){
    _adminToken = ds.data["adminToken"];
    _queue.fromJSON(ds.data["queue"]);
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

  @override
  Map<String, dynamic> toJson() => {
    'adminToken' : _adminToken,
    'queue' : _queue.toJson(),
    'users' :_users
  };

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
    await saveToDatabase();
    return s;
  }
  Future<void> vote(int i) async{
    _queue.vote(i);
    saveToDatabase();
  }
}



Future<Room> getRoomById(String docID) async{
  DocumentSnapshot doc = await Firestore.instance.collection("room").document(docID).snapshots().first;
  return Room.fromDocumentSnapshot(doc);
}