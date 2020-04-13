import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_queue/models/song.dart';
import 'package:spotify_queue/models/album.dart';


/// Takes in a [input] search string, an [authToken], and a [limit] which defaults to 20
/// Uses spotify API to return a map where
/// [Key] -> tracks, albums, artists
/// [Value] -> List of Spotify URIS related to Key name
Future<Map<String,List<String>>>search(String input,String authToken,{String limit: "20"}) async{
  // Init to empty
  Map<String,List<String>> ret = {
    "tracks" : [],
    "albums": [],
    "artists": []
  };

  try{

    // Spotify api requres whitespace to be represented as %20
    // Clean up input string
    String querystring = input.replaceAll(new RegExp(r'\s'), '%20');
    
    // Format authentication token for header
    String token = "Bearer " + authToken;

    // Base url of spotify api
    String url = "https://api.spotify.com/v1/search?q=$querystring&type=track&market=US&limit=$limit";
    
    // Get request API and wait for response
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: token});
   
    // Decode the result
    Map<String,dynamic> result = json.decode(response.body);

    // Grab the tracks returned
    List<dynamic> tracks = result["tracks"]["items"];

    // Every item is a packaged search result.
    // Iterate through them all and grab the song URI, artist URI, and album URI
    // Do not add repeats
    for(var item in tracks){
      // If song URI exists
      if(item["uri"] != null){
        String songURI = item["uri"];
        // Don't allow duplicates
        if(!ret["tracks"].contains(songURI)){
          // New track URI, add to list.
          ret["tracks"].add(songURI);
        }// end if !contains
      }// end if !null

      // If album exists
      if(item["album"] != null){
        String albumUri = item["album"]["uri"];
        // Don't allow duplicates
        if(!ret["albums"].contains(albumUri)){
          // New album URI, add to list
          ret["albums"].add(albumUri);
        }// end if !contains
      }// end if !null

      // If artist list exists
      if(item["artists"] != null){
        // Extract the lsit
        List<dynamic> artistList = item["artists"];
        // Iterate through every artist in the list
        for(var artist in artistList){
          String artistUri = artist["uri"];
          // If artist URI exists
          if(artistUri != null){
            // Don't allow duplicates
            if(!ret["artists"].contains(artistUri)){
              // New artist URI, add to list.
              ret["artists"].add(artistUri);
            } // end if !contains
          }// end if !null
        }// end for artist
      }//end for item
  } // end try
  }catch(e){
    debugPrint(e.toString());
  }
  /* // Debugging stuff
  debugPrint("Tracks: " +  ret["tracks"].toString());
  debugPrint("Albums: " +  ret["albums"].toString());
  debugPrint("Aritsts: " +  ret["artists"].toString());
  */
  return ret;
}


Future<List<Song>> searchTracks(List<String> trackUriList,String authToken) async{
    List<Song> ret = [];
    try{
      // Spotify api wants just the spotify ID from the URI
      // Ex: spotify:track:6rqhFgbbKwnb9MLmUQDhG6 -> 6rqhFgbbKwnb9MLmUQDhG6
      String trackIds = "";

      for(var t in trackUriList){

        // Replace spotify:track: with emptry string
        String formatted = t.replaceAll(new RegExp(r'spotify:track:'), "");

        // only add comma to list if it is NOT the last item
        if(t != trackUriList.last){
          formatted += ",";
        }
        // Add to comma seperated list
        trackIds += formatted;
      }

      // Base url
      String url = "https://api.spotify.com/v1/tracks/?ids=$trackIds";

      // Format authentication token for header
      String token = "Bearer " + authToken;

      
      // Get request API and wait for response
      var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: token});
      // Parse information and return list of Song objects
      // Decode the result
      Map<String,dynamic> result = json.decode(response.body);

      // Grab the tracks returned
      List<dynamic> trackList = result["tracks"];
      // iterate through and make Song objects
      for(var track in trackList){
        // Song(this._uri, this._albumCover, this._albumName, this._artists)
        String uri = "";
        List<Map<String,dynamic>> albumCovers = [];
        String albumName = "";
        List<String> artists = [];
        String songName = "";

        if(track["uri"] != null){
          uri = track["uri"];
        }
        if(track["name"] != null){
          songName = track["name"];
        }
        if(track["album"] != null){
          albumName = track["album"]["name"];
          // Grab artists
          List<dynamic> artistList = track["album"]["artists"];
          for(var artist in artistList){
            String artistName = artist["name"];
            if(artistName != null){
              artists.add(artistName);
            }
          } // end for artists
          // Grab album covers
          List<dynamic> albCovers = track["album"]["images"];
          for(var cover in albCovers){
            Map<String,dynamic> album = {
              "height": cover["height"],
              "width": cover["width"],
              "imgURL" : cover["url"]
            };
            albumCovers.add(album);
          }
        }// end if album != null
        ret.add(Song(uri,songName,albumCovers,albumName,artists));
      }

    } // end try
    catch(e){
      debugPrint(e.toString());
    }
    return ret;
}

Future<List<Album>> searchAlbums(List<String> albumURIList,String authToken) async {
  List<Album> ret = [];
  try{
      String albumIds = "";
      for(var a in albumURIList){

        // Replace spotify:track: with emptry string
        String formatted = a.replaceAll(new RegExp(r'spotify:album:'), "");

        // only add comma to list if it is NOT the last item
        if(a != albumURIList.last){
          formatted += ",";
        }
        // Add to comma seperated list
        albumIds += formatted;
      }

      // Base url
      String url = "https://api.spotify.com/v1/albums/?ids=$albumIds";

      // Format authentication token for header
      String token = "Bearer " + authToken;

      
      // Get request API and wait for response
      var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: token});
      // Parse information and return list of Song objects
      // Decode the result
      Map<String,dynamic> result = json.decode(response.body);
      List<dynamic> albums = result["albums"];
      for(var a in albums){
          //Album(this._uri, this._artists, this._albumCovers,this._albumName, this._songs);
          String uri;
          List<Map<String,String>> artists = [];
          String albumName;
          List<Map<String,dynamic>> albumCovers =[];
          //Song(this._uri, this._songName, this._albumCovers, this._albumName, this._artists);

        // Get URI
        uri = a["uri"];
        // Get name
        albumName = a["name"];
        // Get artists
        for(var artist in a["artists"]){
          artists.add({
            "name": artist["name"],
            "URI": artist["uri"]
          });
        }
        // Get album covers
        List<dynamic> albCovers = a["images"];
        for(var cover in albCovers){
          Map<String,dynamic> album = {
            "height": cover["height"],
            "width": cover["width"],
            "imgURL" : cover["url"]
          };
          albumCovers.add(album);
        }

        ret.add(Album(uri,artists,albumCovers,albumName));
      }
  }
  catch(e){
    debugPrint(e.toString());
  }

  return ret;
}

Future<List<SongInfo>> getAlbumTracks(String uri, String authToken) async{
  List<SongInfo> ret = [];
  try{
     String formatted = uri.replaceAll(new RegExp(r'spotify:album:'), "");
      // Base url
      String url = "https://api.spotify.com/v1/albums/$formatted/tracks";

      // Format authentication token for header
      String token = "Bearer " + authToken;
      
      // Get request API and wait for response
      var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: token});
      // Parse information and return list of Song objects
      // Decode the result
      Map<String,dynamic> result = json.decode(response.body);
      // Grab the tracks returned
      List<dynamic> trackList = result["items"];
      // iterate through and make Song objects
      for(var track in trackList){
        //SongInfo(this._uri, this._name);
        ret.add(SongInfo(track["uri"], track["name"]));
      }
  }// end try
  catch(e){
    debugPrint(e);
  }
  return ret;
}
// Returns a map where key-> "songs" , "albums" , or "artists" and the value assocaited with the key
// Is a list of objects List<Song>, List<Album>, List<Aritst>
// *TODO implement Artist
Future<Map<String,List<dynamic>>> fullSearch(String input, String authToken) async{
  Map<String,List<dynamic>> ret = {};
  Map<String,List<String>> uriMap = await search(input, authToken);
  List<Song> songs = await searchTracks(uriMap["tracks"],authToken);
  List<Album> albums = await searchAlbums(uriMap["albums"], authToken);
  //List<Artist> artists = await searchArtists(uriMap["artists"], authToken);
  List<dynamic> artists = []; // Place holder
  ret["songs"] = songs;
  ret["albums"] = albums;
  ret["artists"] = artists;
  return ret;
}