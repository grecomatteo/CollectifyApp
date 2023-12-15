import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:collectify/Message.dart';

class ChatController {

  static Socket? chatSocket;

  static int myID = -1;

  static List<Message> messages = [];
  static StreamController<List<Message>> messageStream = StreamController<List<Message>>.broadcast();

  void createConnection(int id) {
    if(myID == -1){
      return;
    }

    if(chatSocket != null){
      return;
    }

    myID = id;

    Socket.connect('bytedev.es', 55555).then((socket) {
      chatSocket = socket;
      print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
      socket.write("ConnectedUser:$myID");
      socket.listen((event) {
        handleConnection(event);
      },
          onError: (error) {
            print(error);
            createConnection(myID);
          });
    });
  }

  void handleConnection(List<int> event) {
    String message = utf8.decode(event);
    if(message.startsWith("ConnectedUser:"))
    {
      chatSocket?.write("GetUsersWithCommunication:$myID");
    }
    else if(message.startsWith("UsersWithCommunication:"))
    {
      handleUsersWithCommunication(chatSocket!, message);
    }
    else if(message.startsWith("DisconnectedUser:"))
    {
      handleDisconnectedUser(chatSocket!, message);
    }
    else if (message.startsWith("LastMessage:"))
    {
      handleLastMessage(chatSocket!, message);
    }
    else if(message.startsWith("Messages:")){
      handleGetAllMessages(message);
    }
    else if (message.startsWith("NewMessage:")){
      handleNewMessage(chatSocket!, message);
      handleGetNewMessage(message);
    }
  }

  void handleUsersWithCommunication(Socket socket, String message){
    var split = message.split(":");
    split.removeAt(0);
    //Remove empty strings
    split.removeWhere((element) => element == "");
    //Remove duplicates
    split = split.toSet().toList();

    //Check if the user has any communication
    if(split.length == 0){
      messages = [];
      messageStream.add(messages);
      return;
    }

    //Get all messages between the main user and the other users, all the users are passed in the message
    socket.write("GetLastMessage:$myID:${split.join(":")}");
  }

  void handleDisconnectedUser(Socket socket, String message){
    var split = message.split(":");
    int userID = int.parse(split[1]);
    messages = [];
    messageStream.add(messages);
    chatSocket?.close();
  }

  void handleLastMessage(Socket socket, String message){
    var split = message.split(":");
    List<Message> gottenMessages = [];

    if(split[1] == ""){
      messages = [];
      messageStream.add(messages);
      return;
    }

    //Remove the first and last character, which are "[" and "]"
    //Split the string by ";"
    var messagesCompressed = split[1].split(";");

    List<List<List<int>>> messageList = [];

    for(int i = 0; i < messagesCompressed.length; i++){
      //Remove the first and last character, which are "[" and "]"
      messagesCompressed[i] = messagesCompressed[i].substring(1, messagesCompressed[i].length - 1);

      //String to List<List<int>>, remove the "[" from the first string and the "]" from the last string
      List<List<int>> messageCompressed = messagesCompressed[i].split("], [").map((e) => e.replaceAll("[", "").replaceAll("]", "").split(",").map((e) => int.parse(e)).toList()).toList();
      Message m = Message.decompressObject(messageCompressed);
      print(m.message);
      gottenMessages.add(m);
    }

    messages = gottenMessages;

    messageStream.add(messages);
  }

  void handleNewMessage(Socket socket, String message){
    var split = message.split(":");
    //Remove the first and last character, which are "[" and "]"
    split[1] = split[1].substring(1, split[1].length - 1);
    //Get the array of strings, they are in this format: [values], [values], [values]
    var split2 = split[1].split("], [");
    //Remove the "[" from the first string and the "]" from the last string
    split2[0] = split2[0].substring(1);
    split2[split2.length - 1] = split2[split2.length - 1].substring(0, split2[split2.length - 1].length - 1);

    List<List<int>> messageVarList = [];
    for(int j = 0; j < split2.length; j++){
      //Split the string by ","
      var split3 = split2[j].split(",");
      List<int> varList = [];
      for(int k = 0; k < split3.length; k++){
        varList.add(int.parse(split3[k]));
      }
      messageVarList.add(varList);
    }
    Message m = Message.decompressObject(messageVarList);
    //Remove m.receiverID or m.senderID's message
    for(int i = 0; i < messages.length; i++){
      if(messages[i].senderID == m.senderID && messages[i].receiverID == m.receiverID){
        messages.removeAt(i);
        break;
      }
      else if(messages[i].senderID == m.receiverID && messages[i].receiverID == m.senderID){
        messages.removeAt(i);
        break;
      }
    }
    messages.add(m);
    messageStream.add(messages);
  }

  void handleMessages(Socket socket, String message){
    //Get all the messages between the main user and the other user
    var split = message.split(":");
    //Remove the first and last character, which are "[" and "]"
    split[1] = split[1].substring(1, split[1].length - 1);
    //Get the array of strings, they are in this format: [values], [values], [values]
    var split2 = split[1].split("], [");
    //Remove the "[" from the first string and the "]" from the last string
    split2[0] = split2[0].substring(1);
    split2[split2.length - 1] = split2[split2.length - 1].substring(0, split2[split2.length - 1].length - 1);

    List<List<int>> messageVarList = [];
    for(int j = 0; j < split2.length; j++){
      //Split the string by ","
      var split3 = split2[j].split(",");
      List<int> varList = [];
      for(int k = 0; k < split3.length; k++){
        varList.add(int.parse(split3[k]));
      }
      messageVarList.add(varList);
    }
    Message m = Message.decompressObject(messageVarList);
    messages.add(m);
    messageStream.add(messages);
  }

  void handleGetAllMessages(String message) {
    var split = message.split(":");

    if(split[1] == ""){
      messages = [];
      messageStream.add(messages);
      return;
    }

    var messageListStr = split[1].split(";");
    //What we get is a list of strings, each string is a list of integers
    //We need to convert each string to a list of integers
    List<List<List<int>>> messageList = [];
    for (int i = 0; i < messageListStr.length; i++) {
      //Remove the first and last character, which are "[" and "]"
      messageListStr[i] =
          messageListStr[i].substring(1, messageListStr[i].length - 1);
      //Get the array of strings, they are in this format: [values], [values], [values]
      var split2 = messageListStr[i].split("], [");
      //Remove the "[" from the first string and the "]" from the last string
      split2[0] = split2[0].substring(1);
      split2[split2.length - 1] = split2[split2.length - 1].substring(
          0, split2[split2.length - 1].length - 1);

      List<List<int>> messageVarList = [];
      for (int j = 0; j < split2.length; j++) {
        //Split the string by ","
        var split3 = split2[j].split(",");
        List<int> varList = [];
        for (int k = 0; k < split3.length; k++) {
          varList.add(int.parse(split3[k]));
        }
        messageVarList.add(varList);
      }
      messageList.add(messageVarList);
    }

    List<Message> gottenMessages = [];
    for (int i = 0; i < messageList.length; i++) {
      Message m = Message.decompressObject(messageList[i]);
      gottenMessages.add(m);
    }
    messages = gottenMessages;

    messageStream.add(messages);
  }

  void handleGetNewMessage(String message) {
    var split = message.split(":");
    //Remove the first and last character, which are "[" and "]"
    split[1] = split[1].substring(1, split[1].length - 1);
    //Get the array of strings, they are in this format: [values], [values], [values]
    var split2 = split[1].split("], [");
    //Remove the "[" from the first string and the "]" from the last string
    split2[0] = split2[0].substring(1);
    split2[split2.length - 1] = split2[split2.length - 1].substring(0, split2[split2.length - 1].length - 1);

    List<List<int>> messageVarList = [];
    for(int j = 0; j < split2.length; j++){
      //Split the string by ","
      var split3 = split2[j].split(",");
      List<int> varList = [];
      for(int k = 0; k < split3.length; k++){
        varList.add(int.parse(split3[k]));
      }
      messageVarList.add(varList);
    }
    Message m = Message.decompressObject(messageVarList);

    messages.add(m);
    messageStream.add(messages);
  }
}