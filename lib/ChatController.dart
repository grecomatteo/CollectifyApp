import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:collectify/Message.dart';

class ChatController {

  static Socket? chatSocket;

  static int myID = -1;

  static List<Message> messages = [];
  static StreamController<List<Message>> messageStream = StreamController<List<Message>>.broadcast();
  static List<Message> lastMessages = [];
  static StreamController<List<Message>> lastMessageStream = StreamController<List<Message>>.broadcast();

  void createConnection(int id) {

    if(chatSocket != null){
      chatSocket?.close();
      chatSocket = null;
    }
    print("Creating connection with id: $id and chatSocket: $chatSocket");

    try {
      Socket.connect('bytedev.es', 55555).then((socket) {
        chatSocket = socket;
        myID = id;
        print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
        socket.write("ConnectedUser:$myID");
        socket.listen((event) {
          handleConnection(event);
        },
            onError: (error) {
              print(error);
              chatSocket?.close();
              chatSocket = null;
            },
            onDone: () {
              print('Connection has been closed.');
              chatSocket?.close();
              chatSocket = null;
            }
        );
      });
    }
    catch(e){
      print(e);
    }
  }

  void handleConnection(List<int> event)  {
    String message = utf8.decode(event);
    if(message.startsWith("ConnectedUser:"))
    {
      chatSocket?.write("GetUsersWithCommunication:$myID");
    }
    else if(message.startsWith("UsersWithCommunication:"))
    {
      handleUsersWithCommunication(message);
    }
    else if (message.startsWith("LastMessage:"))
    {
      handleLastMessage(message);
    }
    else if(message.startsWith("Messages:")){
      handleGetAllMessages(message);
    }
    else if (message.startsWith("NewMessage:")){
      handleNewMessage(message);
      handleGetNewMessage(message);
    }
  }

  void handleUsersWithCommunication(String message)  {
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
    chatSocket?.write("GetLastMessage:$myID:${split.join(":")}");
  }

  void handleLastMessage(String message)  {
    var split = message.split(":");
    List<Message> gottenMessages = [];

    if(split[1] == ""){
      lastMessages = [];
      lastMessageStream.add(lastMessages);
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

    lastMessages = gottenMessages;

    lastMessageStream.add(lastMessages);
  }

  void handleNewMessage(String message)  {
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
    //Change last message list to add the new message and remove the old one
    for(int i = 0; i < lastMessages.length; i++){
      if(lastMessages[i].senderID == m.senderID && lastMessages[i].receiverID == m.receiverID){
        lastMessages.removeAt(i);
        break;
      }
      else if(lastMessages[i].senderID == m.receiverID && lastMessages[i].receiverID == m.senderID){
        lastMessages.removeAt(i);
        break;
      }
    }
    messageStream.add(messages);
    lastMessageStream.add(lastMessages);
  }

  void handleGetAllMessages(String message)  {
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

  void handleGetNewMessage(String message)  {
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

  void getMessages(int myID, int otherID) {
    ChatController.chatSocket?.write("GetMessages:$myID:$otherID");
  }

  void getUsersWithCommunication(int myID) {
    ChatController.chatSocket?.write("GetUsersWithCommunication:$myID");
  }

  void sendMessage(int myID, int otherID, Message toSendMessage) {
    createConnection(myID);
    ChatController.chatSocket?.write("NewMessage:$otherID:${toSendMessage.compressObject()}");
  }

  void closeConnection()
  {
    chatSocket?.close();
    chatSocket = null;
  }
}