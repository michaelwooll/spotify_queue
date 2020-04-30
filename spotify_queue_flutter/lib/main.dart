import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_queue/models/room.dart';
import 'package:spotify_queue/views/roomPage.dart';
import 'package:spotify_queue/widgets/queueViewAdmin.dart';
import 'package:spotify_queue/widgets/queueViewNonAdmin.dart';
import 'package:spotify_queue/widgets/drawer.dart';


void main() => runApp(MyApp());
String authenticationToken;
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
        primarySwatch: MaterialColor(0xFF1ED760,color),
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
  bool joinRoomError = false;
  bool joinRoomInput = false;
  TextEditingController textController = new TextEditingController();

  _MyHomePageState(){
    //connect();
  }



  void timedCounter(Duration interval, Room r, BuildContext context, int maxIter) async {
    setState(() {
      creatingRoom = true;
    });
    int i = 0;
    while (i < maxIter) {
      await Future.delayed(interval);
      if(r.getDocID() != null){
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context){
            return RoomView(
              queueView: QueueViewBuilder(roomID: r.getDocID(), authToken: authenticationToken),
              room: r,
              authToken: authenticationToken,
              );
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


  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    MyDrawer drawer;
    if(authenticated){
      drawer = MyDrawer(inRoom: false);
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
          RaisedButton(onPressed: (){
                  createRoom(context);
          },
          child: Text("Create Room"),
           color: color[800],
           shape: RoundedRectangleBorder(
             borderRadius: new BorderRadius.circular(20.0)
           ),
          )
        );
        if(joinRoomInput){
        children.add(
          Container(
            child:
            TextField(
              style: TextStyle(color: color[900]),
              controller: textController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color:color[900])),
                labelStyle: TextStyle(color: color[900]),
                  border: OutlineInputBorder(),
                  labelText: 'Enter room key',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: (){
                      joinRoom(textController.text,authenticationToken).then((room){
                        if(room != null){
                          Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context){
                                      return RoomView(
                                        queueView:QueueViewBuilderNonAdmin(roomID: room.getDocID(), authToken: authenticationToken),
                                        authToken:authenticationToken,
                                        room: room,
                                        );
                                    })
                                  );
                    }
                  else{
                    setState(() {
                      joinRoomError = true;
                  });
                }
              });
              },
                  ),
                )
              ),
              width: 300,
          )
          );
        }
        else{
        children.add(
          RaisedButton(onPressed: (){
            setState(() {
              joinRoomInput = true;
            });
          },
          child: Text("Join Room"),
          shape: RoundedRectangleBorder(
             borderRadius: new BorderRadius.circular(20.0)
           ),
          color: color[800]
          )
        );
        }
      }

    }else{
      children.add(
        MaterialButton(
          onPressed: connect,
          child:
            Text("Log in via spotify!"),
                       shape: RoundedRectangleBorder(
             borderRadius: new BorderRadius.circular(20.0)
           ),
          color: color[700],)
      );
    }

    if(joinRoomError){
      children.add(Center(child:Text("Error when joining room, check key and try again.", style: TextStyle(color: Colors.red))));
    }
    return Scaffold(
      appBar: AppBar( 
        title: Text("Pass the Aux"),
      ),
      drawer: drawer,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: FractionalOffset(0.2, 0.7),
            colors: [Color(0xFF414345),Color(0xFF000000)],
          )
        ),
        child:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children
          ),
        ),
      )
    );
  }
}
