import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:collectify/VentanaMensajesChat.dart';
import 'package:collectify/Message.dart';

int myID = 0;
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
            iconTheme: const IconThemeData(
              color: Colors.white,
              size: 40,
            ),
            backgroundColor: Colors.black,
            title: const Text(
              "Chats",
              style: TextStyle(fontFamily: 'Aeonik', fontSize: 50, color: Colors.white),
            ),
          ),
          body: TextAndChat(),
          backgroundColor: Colors.black,
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

    //Check if the user has any communication
    if(split.length == 0){
      messages = [];
      _messages.add(messages);
      return;
    }

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

    if(split[1] == ""){
      messages = [];
      _messages.add(messages);
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

          ListView lv = ListView(
            controller: listViewController,
            children: [for (final element in children.toList()) element]);
          return lv;
        }
        if (!snapshot.hasData) {
          children = const <Widget>[
            Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
            )
          ];

          ListView lv = ListView(
            controller: listViewController,
            children: [for (final element in children.toList()) element]);
          return lv;
        } else {
          children.add(
            const SizedBox(
              height: 20,
            ));

          //Check if the user has any communication
          if(snapshot.data!.length == 0){
            children.add(
              const Text(
                "No tienes ningún chat",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Aeonik',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            );
          }

          //Order the messages by date
          snapshot.data!.sort((a, b) => b.sendDate.compareTo(a.sendDate));
          for (final element in snapshot.data!.toList()) {
            int otherID = element.senderID == myID
                ? element.receiverID
                : element.senderID;
            Column c = Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(5),
                    backgroundColor: const Color.fromRGBO(52,52,52, 30/100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    try {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ventanaMensajesChat = VentanaMensajesChat(myID, otherID, chatSocket!)),
                      );
                    } on SocketException catch (_) {
                      buildSocket();
                    }
                  },
                  //Horizontal list
                  child: Column(children: [
                    Row(
                      //Align the children to the left
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Small image resize to fit the button, add margin and make it circular
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            "https://picsum.photos/250?image=9",
                            width: 80,
                            height: 80,
                          ),
                        ),
                        //Separate the image from the text
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                element.senderID == myID ? element.receiverName : element.senderName,
                                style: const TextStyle(
                                    fontFamily: 'Aeonik',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                ),
                                textAlign: TextAlign.left,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                              Text(
                                element.message,
                                textAlign: TextAlign.left,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: const TextStyle(
                                    fontFamily: 'Aeonik',
                                    fontSize: 15,
                                    color: Color.fromRGBO(255, 255, 255, 40/100)
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          //If the date is from today, only show the time in this format hh:mm, if not, show the date in this format dd/mm/yyyy
                          element.sendDate.day == DateTime.now().day && element.sendDate.month == DateTime.now().month && element.sendDate.year == DateTime.now().year
                              ? element.sendDate.hour.toString().padLeft(2, '0') + ":" + element.sendDate.minute.toString().padLeft(2, '0')
                              : element.sendDate.day.toString().padLeft(2, '0') + "/" + element.sendDate.month.toString().padLeft(2, '0') + "/" + element.sendDate.year.toString(),
                          textAlign: TextAlign.right,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                              fontFamily: 'Aeonik',
                              fontSize: 15,
                              color: Color.fromRGBO(255, 255, 255, 40/100)
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            );
            children.add(c);
          }
          ListView lv = ListView(
              controller: listViewController,
              children: [for (final element in children.toList()) element]);
          return lv;
        }
      },
    );
  }
}