import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class DatabaseObject{
  String _collection;
  String _docID;
  DatabaseObject(this._collection);

  /// Getter to return [_collection] variable.
  /// [collection] refers to the collection name inside the DB
  String getCollection() => this._collection;

  void setDocID(String id) => this._docID = id;

  String getDocID() => this._docID;

  /// Coverts calls into JSON object to allow for Firebase Storage
  /// This is overrided by every inherited class
  Map<String, dynamic> toJson (); 

  Future<String> saveToDatabase() async{
    if(_docID == null){ // document does not exist yet
      try{
            Map<String,dynamic> json = toJson();
            DocumentReference ref = await Firestore.instance.collection(_collection).add(json);
            return ref.documentID;
      }
      catch(e){
          debugPrint("Error in saveToDatabsae: " + e.toString());
          return "";
      }
    }
    else{ // Document already exists, just update it.
      try{
            Map<String,dynamic> json = toJson();
            await Firestore.instance.collection(_collection).document(_docID).updateData(json);
            return _docID;
      }
      catch(e){
          debugPrint("Error in saveToDatabsae: " + e.toString());
          return "";
      }
    }
   
  }

  Future<bool> updateReference() async{
    try{
      Map<String,dynamic> json = toJson();
      await Firestore.instance.collection(_collection).document(_docID).updateData(json);
    }catch(e){
      debugPrint("Error in updateReference: " + e.toString());
    }
  }
}