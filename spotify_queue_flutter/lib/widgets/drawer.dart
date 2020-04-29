import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_queue/main.dart';

class MyDrawer extends StatelessWidget {
  final bool inRoom;
  MyDrawer({this.inRoom});
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
       DrawerHeader(child: Text('Header'),
       ),
      ListTile(
        title: Text('Logout!'),
        onTap: () {
          SpotifySdk.logout().then((value){
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context){
                  return MyApp();
              })
            );
          });
        }
      )
    ];

    if(inRoom){
      children.add(ListTile(title: Text("Leave current room"),
        onTap: () {
          // Leave
        }
      ));
    }
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: children,
      )
    );
  }
}

