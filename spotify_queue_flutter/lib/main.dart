import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_queue/models/room.dart';
import 'package:spotify_queue/views/queueView.dart';



var clientid = "ef24a50a6c864dbd8d1d364412386158";

void main() => runApp(MyApp());
String authenticationToken;
class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool authenticated = false;
  String authenticationToken = "";
  Room room;
  bool creatingRoom = false;
  bool error = false;
  bool created = false;

  _MyHomePageState(){
    connect();
  }



  void timedCounter(Duration interval, Room r, BuildContext context, int maxIter) async {
      debugPrint("Called");
    setState(() {
      creatingRoom = true;
    });
    int i = 0;
    while (i < maxIter) {
      debugPrint("Here");
      await Future.delayed(interval);
      if(r.getDocID() != null){
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context){
            return QueueView(roomID: r.getDocID(), authToken: authenticationToken);
          })
        );
        return;
      }
      i++;
    }
    setState(() {
      error = true;
    });
  }

  Future<void> connect() async{
      try{
        var token = await SpotifySdk.getAuthenticationToken(clientId: "ef24a50a6c864dbd8d1d364412386158", redirectUrl:"http://mysite.com/callback/");

        // This is needed to control spotify app (play, skip, pause, etc)
        await SpotifySdk.connectToSpotifyRemote(
            clientId: "ef24a50a6c864dbd8d1d364412386158", redirectUrl:"http://mysite.com/callback/");
        // This token is needed to search in the API
        setState(() {
          authenticationToken = token;
          authenticated = true;
        });

      }catch(e){
        debugPrint(e.toString());
        setState(() {
          authenticationToken = "";
          authenticated = true;
        });
      }
  }

  void createRoom(BuildContext context){
    Room r = new Room(authenticationToken);
    timedCounter(Duration(milliseconds: 500), r, context, 10);
  }



/*
  void vote(String uri) async{
    Queue q = await room.getQueue();
    await q.testVote(uri);

  }*/

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if(authenticated){
      if(creatingRoom){
       children = <Widget>[const Padding(
              padding: EdgeInsets.only(top: 100),
            ),
            Center(
              child: SizedBox(
              child: CircularProgressIndicator(),
              width: 100,
              height: 100,
            )
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: Text('Creating room...'),
              )
            )
       ];
      }
      else{
        children.add(
          RaisedButton(onPressed: () => createRoom(context),
          child: Text("Create Room"),)
        );
      }

    }else{
      children.add(
        RaisedButton(onPressed: connect,child: Text("Log in via spotify!"))
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children
        ),
      ),
    );
  }
}
