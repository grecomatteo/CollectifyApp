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
VentanaMensajesChat? ventanaMensajesChat;

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
            title: const Text("Chats", style: TextStyle(color: Colors.white, fontSize: 50, fontFamily: "Aeonik"),),
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
    List<Message> gottenMessages = [];

    //Recieved message:
    /*
    LastMessage:[[120, 156, 171, 152, 99, 204, 196, 192, 96, 204, 96, 12, 0, 11, 94, 1, 176], [120, 156, 171, 152, 163, 173, 235, 167, 203, 196, 192, 146, 203, 120, 0, 0, 21, 115, 3, 28], [120, 156, 171, 152, 99, 204, 194, 192, 96, 196, 96, 4, 0, 11, 102, 1, 176], [120, 156, 171, 152, 227, 237, 115, 242, 236, 25, 102, 6, 54, 70, 38, 46, 0, 38, 238, 4, 36], [120, 156, 171, 152, 195, 237, 169, 171, 23, 120, 194, 87, 87, 207, 207, 199, 63, 212, 128, 153, 65, 61, 145, 229, 15, 0, 77, 6, 6, 126], [120, 156, 171, 152, 99, 108, 100, 96, 116, 205, 212, 228, 138, 233, 166, 0, 131, 45, 91, 140, 76, 182, 24, 153, 94, 219, 188, 197, 192, 212, 208, 128, 149, 193, 197, 144, 85, 25, 0, 233, 160, 11, 228]];[[120, 156, 171, 152, 99, 204, 198, 192, 96, 194, 96, 2, 0, 11, 122, 1, 182], [120, 156, 171, 152, 243, 249, 172, 143, 190, 239, 89, 70, 6, 14, 33, 166, 20, 0, 48, 35, 4, 235], [120, 156, 171, 152, 99, 204, 194, 192, 96, 196, 96, 4, 0, 11, 102, 1, 176], [120, 156, 171, 152, 227, 237, 115, 242, 236, 25, 102, 6, 54, 70, 38, 46,
    */

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
    _messages.add(messages);
  }

  void handleNewMessages(List<int> event) {
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
      ventanaMensajesChat?.ventana?.handleGetAllMessages(message);
    }
    else if (message.startsWith("NewMessage:")){
      handleNewMessage(chatSocket!, message);
      ventanaMensajesChat?.ventana?.handleGetNewMessage(message);
    }
  }

  void buildSocket(){
    Socket.connect('bytedev.es', 55555).then((socket) {
      chatSocket = socket;
      print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
      socket.write("ConnectedUser:$myID");
      socket.listen((data) {
        handleNewMessages(data);
      },
          onError: (error) {
            print(error);
            socket.destroy();
            buildSocket();
          },
          onDone: () {
            print("Done");
            socket.destroy();
            buildSocket();
          });
    });
  }


  @override
  Widget build(BuildContext context) {
    buildSocket();


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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ventanaMensajesChat = VentanaMensajesChat(myID, otherID, chatSocket!)),
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