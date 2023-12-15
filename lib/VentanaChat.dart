import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:collectify/VentanaMensajesChat.dart';
import 'package:collectify/Message.dart';
import 'package:collectify/ChatController.dart';

int myID = 0;
VentanaMensajesChat? ventanaMensajesChat;

class VentanaChat extends StatelessWidget {
  const VentanaChat({required this.id, Key? key}) : super(key: key);

  final int id;

  @override
  Widget build(BuildContext context) {
    myID = id;

    return WillPopScope(
        onWillPop: () async {
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
  @override
  Widget build(BuildContext context) {
    ChatController().getLastMessage(myID);

    return StreamBuilder<List<Message>>(
      stream: ChatController.messageStream.stream,
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
                            builder: (context) => ventanaMensajesChat = VentanaMensajesChat(myID, otherID)),
                      );
                    } on SocketException catch (_) {
                      //If the socket is closed, create a new one
                      ChatController().createConnection(myID);
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