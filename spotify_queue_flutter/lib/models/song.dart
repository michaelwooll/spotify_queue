import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:spotify_queue/models/database.dart';



class Song{
  String _uri;
  int _votes;
  Song(this._uri){
    _votes = 0;
  }

  Song.fromJSON(Map<String,dynamic> json){
      // TODO error checki
      _uri = json["uri"];
      _votes = json["votes"];
  }

  String getURI() => _uri;

  int compareTo(Song s){
    if(this._votes > s._votes){
      return 1;
    }
    else if(this._votes < s._votes){
      return -1;
    }
    else{
      return 0;
    }
  }
  @override
  String toString() {

    return "{uri: " + _uri + ", votes: " + _votes.toString() + "}";
  }

  Map<String,dynamic> toJson(){
    return({
      'uri' : _uri,
      'votes': _votes
    });

  

  }

  void vote({int amount = 1}) => _votes += amount;
}

