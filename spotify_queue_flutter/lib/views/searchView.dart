import 'package:flutter/material.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flappy_search_bar/scaled_tile.dart';
import 'package:spotify_queue/spotifyAPI.dart';
import 'package:spotify_queue/views/roomPage.dart';

class SearchView extends StatefulWidget {
  final String authToken;
  SearchView({Key key, this.authToken, /*this.room*/}):super(key : key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _textEditingController = new TextEditingController();
  String _searchText = "";
  Widget _titleBar = new Text("Search");

  //Spotify Api...

  Map<String, List<String>> searchResults = new Map<String,List<String>>();

  Icon _searchIcon = new Icon(Icons.search);

  _SearchViewState() {
    _textEditingController.addListener(() {
      if(_textEditingController.text.isEmpty) {
        setState(() {
          _searchText = "";
        });
      }
      else {
            fullSearch(_textEditingController.text, widget.authToken).then((onValue) {
              setState(() {
                searchResults = onValue;
              });
            });
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: Container(
        child: _buildList(),

      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: _titleBar,
      leading: new IconButton(icon: _searchIcon, onPressed: _searchPressed),
    );
  }

  Widget _buildList() {

    return ListView.builder(
      itemCount: searchResults["songs"] == null ? 0 : searchResults["songs"].length,
      itemBuilder: (BuildContext context, int index) {
        return new ListTile(
          title: Text(searchResults["songs"][index]),
          onTap: () => debugPrint(searchResults["songs"][index]),
        );
      },
    );
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._titleBar = new TextField(
          controller: _textEditingController,
          decoration: new InputDecoration(
            prefixIcon: new Icon(Icons.search),
            hintText: "Search: Artist, Album, Song"
          ),
        );
      }
      else {
        this._searchIcon = new Icon(Icons.search);
        this._titleBar = new Text("Search");
        _textEditingController.clear();
      }
    });
  }

  /*void search(String input) async {
    Map<String, List<String>> results = await fullSearch(input, authToken);

    setState(() {
      searchResults = results;
    });
  }*/
}

