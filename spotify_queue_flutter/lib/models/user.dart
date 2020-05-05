import 'package:spotify_queue/main.dart';
class UserInfo {
  String _userName;
  String _userToken;

  UserInfo(this._userToken,this._userName);

  UserInfo.fromJSON(Map<String,dynamic> json){
    _userName = json["userName"];
    _userToken = json["userToken"];
  }

  String getUserName () => _userName;
  String getToken () => _userToken;

  Map<String,dynamic> toJSON(){
    return {
      "userName": _userName,
      "userToken": _userToken
    };
  }
}