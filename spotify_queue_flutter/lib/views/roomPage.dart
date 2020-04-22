import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_queue/models/room.dart';
import 'package:spotify_queue/widgets/queueViewNonAdmin.dart';
import 'package:spotify_queue/widgets/queueViewAdmin.dart';



class RoomView extends StatefulWidget {
  RoomView({this.queueView, this.room, this.authToken});
  final Widget queueView;
  final Room room;
  final String authToken;
  @override
  _RoomViewState createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
  int pageIndex = 0;
  
  Widget getWidgetOption(int index){
    if(index == 0){
      return widget.queueView;
    }
    if((index-1) >= _widgetOptions.length){
      return null;
    }
    else {
      return _widgetOptions.elementAt(index-1);
    }
  }

  List<Widget> _widgetOptions = <Widget>[
    Text("Search"),
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
      body: Center(
        child: getWidgetOption(pageIndex)
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted),
              title: Text("Queue")
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              title: Text("Search")
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text("User List")
          )
        ]

      ),
    );
  }
}