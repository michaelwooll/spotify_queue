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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SearchBar<Song>(
            onSearch: search,
            onItemFound: (Song song, int index) {
              return SongCard(
                song: song,
              );
            },
          ),
        ),
      )
    );
  }


}

