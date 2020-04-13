import 'package:spotify_queue/SpotifyAPI.dart';

class Album{
  String _uri;
  List<Map<String,String>> _artists; // List of maps where Key-> Name and URI and Value-> Associated balue
  List<Map<String,dynamic>> _albumCovers; //List of maps where Key->Widgth, Height, Image URL and  Value-> Associated value
  String _albumName;
  List<SongInfo> _songs; // Initially set to an empty list. Call setTrackList when needed to grab trackList

  Album(this._uri, this._artists, this._albumCovers,this._albumName){
    _songs = [];
  }

  String getURI() => _uri;
  List<Map<String,String>> getArtits() => _artists;
  List<Map<String,dynamic>> getAlbumCovers() => _albumCovers;
  String getName() => _albumName;
  List<SongInfo> getSongs() => _songs;

  void setTrackList(String authToken) async{
    if(_songs.isEmpty){
      _songs = await getAlbumTracks(_uri,authToken);
    }
  }

}

class SongInfo {
  String _uri;
  String _name;

  SongInfo(this._uri, this._name);

  String getURI() => _uri;
  String getName() => _name;

  
}