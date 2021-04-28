import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instant_messenger/helper%20function/sharepref_helper.dart';
import 'package:instant_messenger/services/database.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername,name;
  ChatScreen(this.chatWithUsername,this.name);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  String chatRoomId,messageId ="";
  String myName,myProfilePic,myUserName,myEmail;
  Stream messageStream;
  TextEditingController messagetextEditingController =TextEditingController();
  getMyInfoFromSharedPreferences()async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();

    chatRoomId =  getChatRoomIdByUsernames(widget.chatWithUsername,myUserName);

  }
 getChatRoomIdByUsernames(String a,String b) {
    if(a.substring(0,1).codeUnitAt(0)> b.substring(0,1).codeUnitAt(0)){
     return "$b\_$a";
    }
    else{
      return "$a\_$b";
    }
 }

 addMessage(bool sendClicked){
    if (messagetextEditingController.text!=""){
      String message =messagetextEditingController.text;
      var lastMessageTs = DateTime.now();
      Map<String,dynamic> messageInfoMap ={
        "message":message,
        "sendBy": myUserName,
        "ts":lastMessageTs,
        "imgUrl": myProfilePic
      };
      if(messageId == ""){
        messageId =randomAlphaNumeric(12);
      }
      DatabaseMethods().addMessage(chatRoomId, messageId, messageInfoMap)
      .then((value) {
        Map<String,dynamic> lastMessageInfoMap ={
          "lastMessage":message,
          "lastMessageSendTs":lastMessageTs,
          "lastMessageSendBy":myUserName
        };
        DatabaseMethods().updateLastMessageSent(chatRoomId, lastMessageInfoMap);
        if(sendClicked){
          messagetextEditingController.text="";

          messageId="";

        }
      });
    }
 }
 Widget chatMessageTile(String message,bool sendByMe){
    return Row(
      mainAxisAlignment : sendByMe ?MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16,vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomRight: sendByMe ? Radius.circular(0): Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft: sendByMe ? Radius.circular(24):Radius.circular(0),
            ),
            color: Colors.blue,
          ),
          padding: EdgeInsets.all(16),
            child: Text(message,style: TextStyle(color: Colors.white),)),
      ],
    );
 }
 Widget chatMessages(){
    return StreamBuilder(
      stream: messageStream,
      builder: (context,snapshot){
        return snapshot.hasData ? ListView.builder(
          padding: EdgeInsets.only(bottom: 70,top: 60),
          itemCount: snapshot.data.docs.length,
            reverse: true,
            itemBuilder: (context,index){
            DocumentSnapshot ds= snapshot.data.docs[index];
            return chatMessageTile(ds["message"],myUserName== ds["sendBy"]);
        }
        ): Center(child: CircularProgressIndicator());

      },
    );
 }
 getAndSetMessages() async{
   messageStream=  await DatabaseMethods().getChatRoomMessages(chatRoomId);
   setState(() {});
 }
 doThisOnLaunch() async{
     await getMyInfoFromSharedPreferences();
    getAndSetMessages();
 }
  @override

   void initState(){
    doThisOnLaunch();
    super.initState();
  }
  Widget build(BuildContext context) {
    return Scaffold(
   appBar: AppBar(
     title: Text(widget.name),
   ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.grey[200],
                padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: TextField(
                      controller:messagetextEditingController,
                      onChanged: (value){
                        addMessage(false);
                      },
                      decoration: InputDecoration(border: InputBorder.none,
                      hintText: "type a message",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.withOpacity(0.6),
                      )),
                    )),
                    GestureDetector(
                      onTap: (){
                        addMessage(true);
                      },
                        child: Icon(Icons.send)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
