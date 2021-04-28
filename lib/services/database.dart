import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_messenger/helper%20function/sharepref_helper.dart';


class DatabaseMethods{
  Future addUserInfoToDB(String userId,Map<String,dynamic> userInfoMap) async{
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set(userInfoMap);
  }

  Future<Stream<QuerySnapshot>>getUserByUserName(String username)async{
     return FirebaseFirestore.instance.collection('users')
         .where("username",isEqualTo: username)
         .snapshots();
  }
  Future addMessage(String chatRoomId,String messageId,Map messageInfoMap) async{
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chat")
        .doc(messageId)
        .set(messageInfoMap);
  }
  updateLastMessageSent(String chatRoomId, Map lastMessageInfoMap){
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }
  createChatRoom(String chatRoomId,Map chatRoomInfoMap) async{
    final snapShot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if(snapShot.exists){
      return true;
    }
    else{
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }
  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId)async{
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chat")
        .orderBy("ts",descending: true)
        .snapshots();
  }
  Future<Stream<QuerySnapshot>> getChatRooms()async{
    String myUserName =await SharedPreferenceHelper().getUserName();
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("lastMessageSendTs",descending:  true)
        .where("users",arrayContains: myUserName)
        .snapshots();
  }
  Future<QuerySnapshot>getUserInfo(String username)async{

     return await FirebaseFirestore.instance
        .collection("users")
        .where("username",isEqualTo: username)
        .get();
  }
}