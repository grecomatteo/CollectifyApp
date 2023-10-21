import 'dart:async';

import 'package:collectify/ConexionBD.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:collectify/VentanaMensajesChat.dart';
import 'package:collectify/Message.dart';

int myID = 0;
MySqlConnection? conn;

bool lookingForChats = true;

Future<List<Message>> connectToDatabase() async {
  try {
    conn = await MySqlConnection.connect(ConnectionSettings(
      host: "collectify-server-mysql.mysql.database.azure.com",
      port: 3306,
      user: "pin2023",
      password: "AsLpqR_23",
      db: "collectifyDB",
    ));

    List<ResultRow> maps = [];
    await conn
        ?.query(
            '''
            SELECT
                cm.id AS message_id,
                cm.senderID,
                sender.nick AS senderName,
                cm.receiverID,
                receiver.nick AS receiverName,
                cm.message,
                cm.sendDate
            FROM
                chat_messages AS cm
            INNER JOIN usuario AS sender ON cm.senderID = sender.userID
            INNER JOIN usuario AS receiver ON cm.receiverID = receiver.userID
            WHERE
                cm.senderID = $myID OR cm.receiverID = $myID
            ORDER BY
                cm.sendDate DESC
            LIMIT 1;
            ''')
        .then((results) {
      for (var row in results) {
        maps.add(row);
      }
    });

    List<Message> messages = List.generate(maps.length, (i) {
      Message m = Message(
        maps[i]['senderID'],
        maps[i]['senderName'],
        maps[i]['receiverID'],
        maps[i]['receiverName'],
        maps[i]['message'].toString(),
        maps[i]['sendDate'],
      );
      debugPrint(m.toString());
      return m;
    });

    return messages;
  } catch (e) {
    debugPrint("${e} Error");
  }
  return [];
}

class VentanaChat extends StatelessWidget {
  const VentanaChat({required this.id, Key? key}) : super(key: key);

  final int id;

  @override
  Widget build(BuildContext context) {
    myID = id;
    return WillPopScope(
        onWillPop: () async {
          lookingForChats = false;
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
  final Stream<List<Message>> _messages = (() {
    late final StreamController<List<Message>> controller;
    controller = StreamController<List<Message>>(
      onListen: () async {
        while (true) {
          if (!lookingForChats) return;
          List<Message> messages = await connectToDatabase();
          controller.add(messages);
          await Future.delayed(const Duration(seconds: 1));
        }
      },
    );
    return controller.stream;
  })();

  @override
  Widget build(BuildContext context) {
    lookingForChats = true;
    return StreamBuilder<List<Message>>(
      stream: _messages,
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
                          builder: (context) => VentanaMensajesChat(
                              element.senderID == myID
                                  ? element.receiverID
                                  : element.senderID,
                              myID)),
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

/*
class Chat extends StatefulWidget {
  final Message message;

  const Chat(this.message, {Key? key}) : super(key: key);

  @override
  State<Chat> createState() => ChatState(message);
}

class ChatState extends State<Chat> {
  final Message message;

  ChatState(this.message);

  String? name;
  String? lastMessage;

  @override
  Widget build(BuildContext context) {

    int otherID = message.senderID == myID ? message.receiverID : message.senderID;
    Conexion().getUsuarioByID(otherID).then((value) =>
      Conexion().getUsuarioByID(message.senderID).then((value1) => {
        name = value?.nick,
        lastMessage = "${value1?.nick}: ${message.message}"
      })
    );
    return Column(
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
              MaterialPageRoute(builder: (context) => VentanaMensajesChat(message.senderID == myID ? message.receiverID : message.senderID, myID)),
            );
          },
          //Horizontal list
          child: Column(
              children: [
                const SizedBox(height: 2,),
                Row(
                  //Align the children to the left
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //Small image resize to fit the button, add margin and make it circular
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network("https://picsum.photos/250?image=9", width: 50, height: 50,),
                    ),
                    //Separate the image from the text
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name!, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left, softWrap: false, overflow: TextOverflow.fade,),
                          Text(lastMessage!, textAlign: TextAlign.left, softWrap: false, overflow: TextOverflow.fade,),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2,),
              ]
          ),
        ),
        const SizedBox(height: 10,),
      ],
    );
  }
}*/
