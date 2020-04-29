import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_queue/main.dart';
import 'package:spotify_queue/models/room.dart';
import 'package:spotify_queue/widgets/drawer.dart';
import 'package:spotify_queue/widgets/queueViewNonAdmin.dart';
import 'package:spotify_queue/widgets/queueViewAdmin.dart';
import 'package:spotify_queue/views/searchView.dart';



class RoomView extends StatefulWidget {
  RoomView({this.queueView, this.room, this.authToken});
  final Widget queueView;
  final Room room;
  String authToken;
  @override
  _RoomViewState createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
  int pageIndex = 0;
  
  Widget getWidgetOption(int index){
    if(index == 0){
      return widget.queueView;
    }
    if(index == 1) {
      return SearchView(authToken: widget.authToken);
    }
    if((index-1) >= _widgetOptions.length){
      return null;
    }
    else {
      return _widgetOptions.elementAt(index-1);
    }
  }

   _navPushSearchView() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return SearchView(authToken: widget.authToken);
    }));
  }

  //Search is going to be added here, room and auth token will be passed also.
  List<Widget> _widgetOptions = <Widget> [
    Text(""),
    Text("Users")
  ];

  void _onItemTapped(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
            title: Text("Your room key: " + widget.room.getRoomKey())
      ),
      drawer: MyDrawer(inRoom: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: FractionalOffset(0.2, 0.7),
            colors: [Color(0xFF414345),Color(0xFF000000)],
          )
        ),
        child:Center(
          child: getWidgetOption(pageIndex)
        ),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        currentIndex: pageIndex,
        
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
              
              icon: Icon(Icons.format_list_bulleted, color: Colors.white),
              activeIcon: Icon(Icons.format_list_bulleted),
              title: Text("Queue", style: TextStyle(color: Colors.white),)
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.search,color: Colors.white),
              activeIcon: Icon(Icons.search),
              title: Text("Search",style: TextStyle(color: Colors.white)),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.white),
              activeIcon: Icon(Icons.person) ,
              title: Text("User List",style: TextStyle(color: Colors.white))
          )
        ]

      ),
    );
  }
}