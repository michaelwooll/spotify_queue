
class Song{
  String _uri;
  int _votes;
  List<Map<String,dynamic>> _albumCovers = []; //List of maps where Key->Widgth, Height, Image URL and  Value-> Associated value
  String _albumName;
  String _songName;
  List<String> _artists = [];
  List<String> _votedBy = [];
  Song(this._uri, this._songName, this._albumCovers, this._albumName, this._artists){
    _votes = 0;
  }

  Song.fromJSON(Map<String,dynamic> json){
      if(json != null){
        // TODO error checki
        _uri = json["uri"];
        _votes = json["votes"];
        _songName = json["songName"];
        for(var vote in json["votedBy"]){
          _votedBy.add(vote);
        }
        for(var cover in json["albumCovers"]){
          _albumCovers.add(cover);
        }
        for(var a in json["artists"]){
          _artists.add(a);
        }
        _albumName = json["albumName"];
      }
  }
  bool isVoted(String authToken) => _votedBy.contains(authToken);
  String getURI() => _uri;
  String getSongName() => _songName;
  String getFirstImgTest() => _albumCovers[0]["imgURL"];
  String getFirstArtistTest() => _artists[0];
  int getVotes() => _votes;


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
  String toStringLong(){
    return "{uri: " + _uri + ", votes: " + _votes.toString() + ", albumCovers: " + _albumCovers.toString() + ", artists" + _artists.toString() + ", albumName:$_albumName" "}";
  }

  Map<String,dynamic> toJson(){
    return({
      'uri' : _uri,
      'songName': _songName,
      'votes': _votes,
      'albumCovers' : _albumCovers,
      'artists' : _artists,
      "albumName": _albumName,
      "votedBy" : _votedBy
    });
  }

  void vote(String authToken, {int amount = 1}) {
     _votes += amount;
     _votedBy.add(authToken);
  }
}

