
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotify_queue/models/database.dart';
import 'package:spotify_queue/models/queue.dart';
import 'package:spotify_queue/models/song.dart';




class Room extends DatabaseObject{
  String _adminToken;
  String _queueID;
  List<String> _users;

  Room(this._adminToken):super("room"){
    Queue q = new Queue();
    _users = [];
    q.createQueue().then((queueID){
      _queueID = queueID;
      saveToDatabase().then((docID){
      setDocID(docID);
    });
    });
  }

  Room.fromDocumentSnapshot(DocumentSnapshot ds):super("room"){
    _adminToken = ds.data["adminToken"];
    _queueID = ds.data["queue"];
    for(var u in ds.data["users"]){
      _users.add(u);
    }
    setDocID(ds.documentID);
  }

  String getQueueID() => _queueID;

  @override
  Map<String, dynamic> toJson() => {
    'adminToken' : _adminToken,
    'queue' : _queueID,
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

  Future<Queue> getQueue() async {
    DocumentSnapshot doc = await Firestore.instance.collection("queue").document(_queueID).snapshots().first;
    return Queue.fromDocumentSnapshot(doc);
  }


  Future<void> addSong(String songURI) async{
    // First grab the queue.
    Queue q = await getQueue();
    q.addSong(Song(songURI));
    saveToDatabase();
  }

  Future<Song> pop() async {
    Queue q = await getQueue();
    return q.pop();
  }
  //Future<Song
}

Future<Room> getRoomById(String docID) async{
  DocumentSnapshot doc = await Firestore.instance.collection("room").document(docID).snapshots().first;
  return Room.fromDocumentSnapshot(doc);
}