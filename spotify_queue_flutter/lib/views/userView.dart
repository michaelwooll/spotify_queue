import 'package:flutter/material.dart';
import 'package:spotify_queue/models/user.dart';
import 'package:spotify_queue/spotifyAPI.dart';
import 'package:spotify_queue/models/room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

  Map<int, Color> color =
  {
    50:Color.fromRGBO(30,215,96, .1),
    100:Color.fromRGBO(30,215,96, .2),
    200:Color.fromRGBO(30,215,96, .3),
    300:Color.fromRGBO(30,215,96, .4),
    400:Color.fromRGBO(30,215,96, .5),
    500:Color.fromRGBO(30,215,96, .6),
    600:Color.fromRGBO(30,215,96, .7),
    700:Color.fromRGBO(30,215,96, .8),
    800:Color.fromRGBO(30,215,96, .9),
    900:Color.fromRGBO(30,215,96, 1),
  };
/*
class UserView extends StatefulWidget {
  final String authToken;
  final Stream<DocumentSnapshot> roomStream;

  UserView({Key key, this.authToken, this.roomStream}):super(key : key);

  @override
  _UserViewState createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  String user;

  Future<String> getUsers() async {
  //  Map<String, dynamic> results = await getUser(widget.authToken);
   // return results["id"] as String;
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
            child: FutureBuilder<String>(
              future: getUsers(),
              builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    return UserCard(authToken: widget.authToken, username: snapshot.data);
                  }
                  return CircularProgressIndicator();
              },
            ),
          ),
        )
    );
  }
}

class UserCard extends StatelessWidget {
  final String username;
  //final UserInfo user;
  final Function callback;
  final String authToken;
  const UserCard({Key key,  this.callback, this.authToken, this.username}): super(key:key);

  @override
  Widget build(BuildContext context){
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
                //leading: Image.network(song.getFirstImgTest()),
                title: Text(
                    "$username",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.white)
                ),
                subtitle: Text( "Host of Room",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.white)),
                trailing : Container(
                    child:Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[

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


*/

class  UserView extends StatelessWidget {
  final String roomID;
  UserView({this.roomID});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection("room").document(roomID).snapshots(),
      builder: (context, snapshot){
        List<Widget> children =[];
        if(!snapshot.hasData){
           // Add padding
          children.add(
            const Padding(
              padding: EdgeInsets.only(top: 100),
            )
          );
          children.add(
            Center(
              child: SizedBox(
              child: CircularProgressIndicator(),
              width: 100,
              height: 100,
              )
            )
          );
          children.add(
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: Text('Loading users...'),
              )
            )
          );
        }
        else if(snapshot.hasError){
          children.add(Text("Error"));
        }else{
          for(var item in snapshot.data["users"]){
            children.add(UserCard(user: UserInfo.fromJSON(item), adminToken: snapshot.data["adminToken"]));
          }

        }
        return ListView(children: children);  
      }
    ); // end streaul builder
  }// end build
}


class UserCard extends StatelessWidget {
  final UserInfo user;
  final String adminToken;
  const UserCard({Key key,  this.user,this.adminToken}): super(key:key);

  @override
  Widget build(BuildContext context){
    Icon adminIcon;
    ListTile tile;
    if(adminToken == user.getToken()){
      tile = ListTile(
                //leading: Image.network(song.getFirstImgTest()),
                title: Text(
                    user.getUserName(),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.white)
                ),
                trailing : Container(
                    child: Icon(Icons.account_circle),
                    color: Colors.white
                )
            );
    }else{
        tile = ListTile(
                //leading: Image.network(song.getFirstImgTest()),
                title: Text(
                    user.getUserName(),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.white)
                ),
            );
    }

    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            tile
          ],
        ),
      ),
    );
  }
}