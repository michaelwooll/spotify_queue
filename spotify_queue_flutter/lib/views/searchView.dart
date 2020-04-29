import 'package:flutter/material.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flappy_search_bar/scaled_tile.dart';
import 'package:spotify_queue/models/song.dart';
import 'package:spotify_queue/spotifyAPI.dart';
import 'package:spotify_queue/views/roomPage.dart';
import 'package:spotify_queue/widgets/songWidgets.dart';

class SearchView extends StatefulWidget {
  final String authToken;
  SearchView({Key key, this.authToken, /*this.room*/}):super(key : key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

  class _SearchViewState extends State<SearchView> {

  //Map<String, List<dynamic>> searchResults = new Map<String,List<dynamic>>();

  Future<List<Song>> search(String input) async {
    Map<String, List<dynamic>> results = await fullSearch(input, widget.authToken);
    return results["songs"] as List<Song>;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xFF414345),
            Color(0xFF000000)
          ], begin: Alignment.topLeft, end: FractionalOffset(0.2, 0.7))
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SearchBar<Song>(
            searchBarStyle: SearchBarStyle(
              backgroundColor: Colors.white,
              padding: EdgeInsets.all(5),
              borderRadius: BorderRadius.circular(25),

            ),
            hintText: "Search for songs...",
            cancellationWidget: Text("Cancel", style: TextStyle(color: Colors.white),),
            onSearch: search,
            onItemFound: (Song song, int index) {
              return SearchCard(
                song: song,
              );
            },
          ),
        ),
      )
    );
  }


}

class SearchCard extends StatelessWidget {
  final Song song; // Event object that will hold all the event data
  final Function callback;
  final String authToken;
  const SearchCard({Key key, this.song, this.callback, this.authToken}): super(key:key);

  @override
  Widget build(BuildContext context){
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
                leading: Image.network(song.getFirstImgTest()),
                title: Text(
                    song.getSongName(),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.white)
                ),
                subtitle: Text( song.getFirstArtistTest(),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.white)),
                trailing : Container(
                    child:Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        //Add button widget goes here
                        //or clickable opacity
                      ],)
                )
              // RawMaterialButton(child: Icon(Icons.arrow_upward),onPressed: callback)),
              //trailing: Row(children: <Widget>[RawMaterialButton(child: Icon(Icons.arrow_upward),onPressed: callback),Text("Votes: " + song.getVotes().toString())],),
            ),

          ],
        ),
      ),
    );
  }
}

