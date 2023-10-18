import 'dart:async';
import 'package:collectify/ConexionBD.dart';
import 'package:collectify/VentanaChat.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:collectify/Message.dart';
import 'package:mysql1/mysql1.dart';

String toSendMessage = "";

int myID = 0;
int otherID = 0;
String? otherName = "";
List<Message> messageLocalList = [];

bool lookingForMessages = true;

Future<List<Message>> getMessages() async{
  List<ResultRow> maps = [];
  await conn?.query('select * from chat_messages where (senderID=$myID AND receiverID=$otherID) OR (receiverID=$myID AND senderID=$otherID) ORDER BY sendDate').then((results) {
    for (var row in results) {
      maps.add(row);
      debugPrint(row.toString());
    }
  });

  List<Message> messageList = List.generate(maps.length, (i) {
    return Message(
      maps[i]['senderID'],
      maps[i]['receiverID'],
      maps[i]['message'].toString(),
      maps[i]['sendDate'],
    );
  });

  messageLocalList = messageList;
  return messageList;
}

//List view controller
final listViewController = ScrollController();
class VentanaMensajesChat extends StatefulWidget {
  const VentanaMensajesChat(this.oID, this.iD, {super.key});

  final int iD;
  final int oID;

  @override
  State<VentanaMensajesChat> createState() => _VentanaMensajesChatState(oID, iD);
}

class _VentanaMensajesChatState extends State<VentanaMensajesChat> {
  _VentanaMensajesChatState(this.oID, this.iD);

  final int iD;
  final int oID;

  final Stream<List<Message>> _messages = (() {
    late final StreamController<List<Message>> controller;
    controller = StreamController<List<Message>>(
      onListen: () async {
        while (true) {
          if(!lookingForMessages) return;
          List<Message> messages =  await getMessages();
          controller.add(messages);
          await Future.delayed(const Duration(seconds: 1));
        }
      },
    );
    return controller.stream;
  })();

  @override
  Widget build(BuildContext context) {
    lookingForMessages = true;
    myID = iD;
    otherID = oID;

    Conexion().getUsuarioByID(otherID).then((value) => setState(() {
      otherName = value?.nick;
    }));
    return WillPopScope(
      onWillPop: () async {
        lookingForMessages = false;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("$otherName's Chat"),
        ),
        body: StreamBuilder<List<Message>>(
          stream: _messages,
          builder: (BuildContext context, AsyncSnapshot<List<Message>> snapshot) {
            List<Widget> children;
            if (snapshot.hasError) {
              children = [Text('${snapshot.error}')];
            }
            if (!snapshot.hasData) {
              children = const <Widget>[CircularProgressIndicator()];
            } else {
              List<Message> messages = snapshot.data as List<Message>;
              List<Widget> childrn = [];
              for (int i = 0; i < messages.length; i++) {
                childrn.add(MessageDisplay(
                  message: messages[i],
                  myID: myID,
                  otherID: otherID,
                ));

                if(i == messages.length - 1) continue;
                if(messages[i].sendDate.day != messages[i+1].sendDate.day){
                  childrn.add(
                    Container(
                      margin: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Text(
                        "${messages[i+1].sendDate.day}/${messages[i+1].sendDate.month}/${messages[i+1].sendDate.year}",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  );
                }
              }
              children = childrn;
            }
            ListView LV = ListView(
              controller: listViewController,
                reverse: true,
                children: [
                  for (final element in children.reversed.toList())
                    element
                ]
            );
            return LV;
          },
        ),
        resizeToAvoidBottomInset: false,
        //When the keyboard is open put the NavigationBar on top of the keyboard
        bottomNavigationBar: const NavigationBar(),
      )
    );
  }
}

class MessageDisplay extends StatelessWidget {
  const MessageDisplay({Key? key, required this.message, required this.myID, required this.otherID})
      : super(key: key);

  final Message message;
  final int myID;
  final int otherID;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: message.senderID == myID ? Colors.green : Colors.blueGrey,
      margin: const EdgeInsets.all(10),
      alignment: message.senderID == myID
          ? Alignment.centerRight
          : Alignment.centerLeft,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: message.senderID == myID ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            textAlign: TextAlign.start,
            message.message,
            style: const TextStyle(fontSize: 20),
          ),
          Text(
            textAlign: TextAlign.end,
            "${message.sendDate.hour}:${message.sendDate.minute}",
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class NavigationBar extends StatefulWidget {
  const NavigationBar({Key? key}) : super(key: key);

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  Future<void> sendMessage(int myID, int otherID) async{
    await conn?.query("insert into chat_messages(senderID, receiverID, message, sendDate) values($myID, $otherID, '$toSendMessage', now())");

    messageLocalList.add(Message(myID, otherID, toSendMessage, DateTime.now()));
    await getMessages();
  }

  final textField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      //Make height of NavigationBar the same as the height of the keyboard
      height: MediaQuery.of(context).viewInsets.bottom + 70,
      alignment: Alignment.bottomCenter,
      color: Colors.grey[200],
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "Type a message",
                          border: InputBorder.none,
                        ),
                        onChanged: (text) {
                          toSendMessage = text;
                        },
                        controller: textField,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: ()
                      {
                        if(toSendMessage.replaceAll(' ', '').isEmpty) return;
                        //send message, clear text field, scroll to the bottom, close keyboard and refresh the page
                        setState(() {
                          sendMessage(myID, otherID);
                        });
                        listViewController.animateTo(
                          0.0,
                          duration: const Duration(milliseconds: 0),
                          curve: Curves.easeOut,
                        );
                        //empty the text field
                        textField.clear();
                        toSendMessage = "";
                        FocusScope.of(context).unfocus();
                      },
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}