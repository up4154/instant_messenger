import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instant_messenger/helper%20function/sharepref_helper.dart';
import 'package:instant_messenger/services/auth.dart';
import 'package:instant_messenger/services/database.dart';
import 'package:instant_messenger/views/chat_screen.dart';
import 'package:instant_messenger/views/sign_in.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isSearching= false;
  String myName,myProfilePic,myUserName,myEmail;
  Stream usersStream,chatRoomsStream;

  TextEditingController searchUsernameEditingController = TextEditingController();

  String get chatRoomId => null;
  getMyInfoFromSharedPreferences()async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
  }
  getChatRoomIdByUsernames(String a,String b) {
    if(a.substring(0,1).codeUnitAt(0)> b.substring(0,1).codeUnitAt(0)){
      return "$b\_$a";
    }
    else{
      return "$a\_$b";
    }
  }
  onSearchBtnClick() async{
    isSearching =true;
    setState(() {});
    usersStream =  await DatabaseMethods().getUserByUserName(searchUsernameEditingController.text);

    setState(() {});
  }


  Widget chatRoomsList(){
    return StreamBuilder(
      stream: chatRoomsStream ,
        builder: (context,snapshot){
        return snapshot.hasData ? ListView.builder(
          itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            itemBuilder: (context,index){
            DocumentSnapshot ds =snapshot.data.docs[index];

            return ChatRoomListTile(ds["lastMessage"],ds.id,myUserName);
            }
        ) : Center(child: CircularProgressIndicator());
        },
    );

  }



  Widget searchListVisitUserTile({String profileUrl,name,username,email}){
    return GestureDetector(
      onTap: (){
        var chatRoomId =getChatRoomIdByUsernames(myUserName, username);
        Map<String,dynamic> chatRoomInfoMap={
          "users": [myUserName,username]
        };

        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(username,name)));
      },

      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: Image.network(
                profileUrl,
                height: 40.0,
                width: 40.0,
              ),
            ),
            SizedBox(width:20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(name),
              Text(email)
            ]),

          ],
        ),
      ),
    );
  }

  Widget searchUsersList(){
     return StreamBuilder(
       stream: usersStream,
       builder: (context,snapshot){
         return snapshot.hasData ? ListView.builder(
           itemCount: snapshot.data.docs.length,
             shrinkWrap: true,
             itemBuilder: (context,index){
             DocumentSnapshot ds =snapshot.data.docs[index];
             return searchListVisitUserTile(
               profileUrl: ds["imgUrl"],
               name: ds["name"],
               email:ds["email"],
               username: ds["username"],
             );
             },
         ) : Center(
           child: CircularProgressIndicator(),
         );
       },
     );
  }

 getChatRooms () async{
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
 }

 onScreenLoaded()async{
   await getMyInfoFromSharedPreferences();
   getChatRooms();
 }
  @override
  void initState(){
    onScreenLoaded();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messenger'),
      actions: [InkWell(
        onTap:()=> (
        AuthMethods().signOut().then((s){
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SignIn()
          ));
        })
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.exit_to_app)),
      )],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Row(
              children: [
               isSearching ? GestureDetector(
                 onTap: (){
                   isSearching = false;
                   searchUsernameEditingController.text="";
                   setState(() {

                   });
                 },
                 child: Padding(
                    padding:  EdgeInsets.only(right: 12.0),
                    child: Icon(Icons.arrow_back),
                  ),
               ): Container(),

                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16.0),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        style: BorderStyle.solid,

                      ),
                          borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: TextField(
                          controller: searchUsernameEditingController,
                          decoration: InputDecoration(border: InputBorder.none,
                          hintText: "search for people",),
                        )),
                        GestureDetector(
                          onTap: (){
                            if(searchUsernameEditingController.text != ""){
                                 onSearchBtnClick();
                            }
                          },
                            child: Icon(Icons.search)
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
           isSearching ? searchUsersList() : chatRoomsList()
          ],
        ),
      ),

    );

}
}
// ignore: must_be_immutable
class ChatRoomListTile extends StatefulWidget {
  String  lastMessage,chatRoomId,myUserName;
  ChatRoomListTile(this.lastMessage,this.chatRoomId,this.myUserName);
  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl,name,username;

  getThisUserInfo() async{
    username = widget.chatRoomId.replaceAll(widget.myUserName, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    print(
        "something bla bla ${querySnapshot.docs[0].id} ${querySnapshot.docs[0]["name"]}  ${querySnapshot.docs[0]["imgUrl"]}");
    name = "${querySnapshot.docs[0]["name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["imgUrl"]}";
    setState(() {});
  }


  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
              child: Image.network(profilePicUrl,height: 40,width: 40,)),
          SizedBox(height: 20,width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,style: TextStyle(fontSize: 16),),
              SizedBox(height: 3),
              Text(widget.lastMessage)
            ],
          )
        ],
      ),
    );
  }
}
