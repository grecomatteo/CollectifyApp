import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:collectify/VentanaMensajesChat.dart';
import 'package:collectify/Message.dart';

int myID = 0;
MySqlConnection? conn;
Socket? chatSocket;

class VentanaChat extends StatelessWidget {
  const VentanaChat({required this.id, Key? key}) : super(key: key);

  final int id;

  @override
  Widget build(BuildContext context) {
    myID = id;
    return WillPopScope(
        onWillPop: () async {
          chatSocket?.write("DisconnectedUser:$myID");
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text("Chat"),
          ),
          body: TextAndChat(),
        ));
  }
}

class TextAndChat extends StatefulWidget {
  const TextAndChat({Key? key}) : super(key: key);

  @override
  State<TextAndChat> createState() => TextAndChatState();
}

class TextAndChatState extends State<TextAndChat> {

  List<Message> messages = [];
  StreamController<List<Message>> _messages = StreamController<List<Message>>.broadcast();

  void handleUsersWithCommunication(Socket socket, String message){
    var split = message.split(":");
    split.removeAt(0);
    //Remove empty strings
    split.removeWhere((element) => element == "");
    //Remove duplicates
    split = split.toSet().toList();
    //Get all messages between the main user and the other users, all the users are passed in the message
    socket.write("GetLastMessage:$myID:${split.join(":")}");
  }

  void handleDisconnectedUser(Socket socket, String message){
    var split = message.split(":");
    int userID = int.parse(split[1]);
    messages = [];
    _messages.add(messages);
    chatSocket?.close();
  }

  void handleLastMessage(Socket socket, String message){
    var split = message.split(":");

    var messageListStr = split[1].split(";");
    //What we get is a list of strings, each string is a list of integers
    //We need to convert each string to a list of integers
    List<List<List<int>>> messageList = [];
    for(int i = 0; i < messageListStr.length; i++){
      //Remove the first and last character, which are "[" and "]"
      messageListStr[i] = messageListStr[i].substring(1, messageListStr[i].length - 1);
      //Get the array of strings, they are in this format: [values], [values], [values]
      var split2 = messageListStr[i].split("], [");
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
      messageList.add(messageVarList);
    }

    List<Message> gottenMessages = [];
    for(int i = 0; i < messageList.length; i++){
      Message m = Message.decompressObject(messageList[i]);
      gottenMessages.add(m);
    }
    messages = gottenMessages;

    _messages.add(messages);
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
    _messages.add(messages);
  }

  void handleNewMessages(Socket socket) {
    socket.listen((List<int> event) {
      String message = utf8.decode(event);
      if(message.startsWith("ConnectedUser:"))
      {
        socket.write("GetUsersWithCommunication:$myID");
      }
      else if(message.startsWith("UsersWithCommunication:"))
      {
        handleUsersWithCommunication(socket, message);
      }
      else if(message.startsWith("DisconnectedUser:"))
      {
        handleDisconnectedUser(socket, message);
      }
      else if (message.startsWith("LastMessage:"))
      {
        handleLastMessage(socket, message);
      }
      else if (message.startsWith("NewMessage:")){
        handleNewMessage(socket, message);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    Socket.connect('10.0.2.2', 55555).then((socket) {
      print('Connected to: '
          '${socket.remoteAddress.address}:${socket.remotePort}');
      chatSocket = socket;
      socket.write("ConnectedUser:$myID");
      handleNewMessages(socket);

    });


    return StreamBuilder<List<Message>>(
      stream: _messages.stream,
      builder: (context, snapshot) {
        List<Widget> children = [];
        if (snapshot.hasError) {
          children = [Text('${snapshot.error}')];

          ListView LV = ListView(
              controller: listViewController,
              children: [for (final element in children.toList()) element]);
          return LV;
        }
        if (!snapshot.hasData) {
          children = const <Widget>[CircularProgressIndicator()];

          ListView LV = ListView(
              controller: listViewController,
              children: [for (final element in children.toList()) element]);
          return LV;
        } else {
          for (final element in snapshot.data!.toList()) {
            int otherID = element.senderID == myID
                ? element.receiverID
                : element.senderID;
            Column c = Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    chatSocket?.write("DisconnectedUser:$myID");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VentanaMensajesChat(myID, otherID)),
                    );
                  },
                  //Horizontal list
                  child: Column(children: [
                    const SizedBox(
                      height: 2,
                    ),
                    Row(
                      //Align the children to the left
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //Small image resize to fit the button, add margin and make it circular
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            "https://picsum.photos/250?image=9",
                            width: 50,
                            height: 50,
                          ),
                        ),
                        //Separate the image from the text
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                element.senderID == myID ? element.receiverName : element.senderName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                              Text(
                                element.message,
                                textAlign: TextAlign.left,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                  ]),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            );
            children.add(c);
          }
          ListView LV = ListView(
              controller: listViewController,
              children: [for (final element in children.toList()) element]);
          return LV;
        }
      },
    );
  }
}