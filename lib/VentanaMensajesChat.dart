import 'dart:async';
import 'dart:io';
import 'package:collectify/ConexionBD.dart';
import 'package:flutter/material.dart';
import 'package:collectify/Message.dart';
import 'package:collectify/notification.dart' as notif;
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as noti;
import 'package:collectify/ChatController.dart';

String toSendMessage = "";

int myID = 0;
String? myName = "";
int otherID = 0;
String? otherName = "";
int msgNum = 0;

noti.FlutterLocalNotificationsPlugin notPlugin = noti.FlutterLocalNotificationsPlugin();

//List view controller
final listViewController = ScrollController();
class VentanaMensajesChat extends StatefulWidget {
  VentanaMensajesChat(this.iD, this.oID);

  final int iD;
  final int oID;

  _VentanaMensajesChatState? ventana;

  @override
  State<VentanaMensajesChat> createState() => ventana = _VentanaMensajesChatState(iD, oID);
}

class _VentanaMensajesChatState extends State<VentanaMensajesChat> {
  _VentanaMensajesChatState(this.iD, this.oID);

  final int iD;
  final int oID;


  void getNames() async {
    await Conexion().getUsuarioByID(myID)?.then((value) =>
    myName = value?.nick);
    await Conexion().getUsuarioByID(otherID)?.then((value) =>
    otherName = value?.nick);
    ChatController.messageStream.add(ChatController.messages);
  }

  @override
  Widget build(BuildContext context) {
    myID = iD;
    otherID = oID;
    getNames();


    ChatController().getMessages(myID, otherID);

    return WillPopScope(
      onWillPop: () async {
        ChatController().getUsersWithCommunication(myID);
        return true;
      },
      child: StreamBuilder<List<Message>>(
        stream: ChatController.messageStream.stream,
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

              if (i == 0) {
                childrn.add(
                  Container(
                    margin: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Text(
                      "${messages[i].sendDate.day}/${messages[i].sendDate.month}/${messages[i].sendDate.year}",
                      style: const TextStyle(fontFamily: 'Aeonik', fontSize: 20, color: Color.fromRGBO(255, 255, 255, 40/100)),
                    ),
                  ),
                );
              }

              childrn.add(MessageDisplay(
                message: messages[i],
                myID: myID,
                otherID: otherID,
              ));

              if (i == messages.length - 1) continue;
              if (messages[i].sendDate.day !=
                  messages[i + 1].sendDate.day || messages[i].sendDate.month != messages[i + 1].sendDate.month || messages[i].sendDate.year != messages[i + 1].sendDate.year) {
                childrn.add(
                  Container(
                    margin: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: messages[i+1].sendDate.day == DateTime.now().day && messages[i+1].sendDate.month == DateTime.now().month && messages[i+1].sendDate.year == DateTime.now().year
                        ? const Text(
                      "Today",
                      style: TextStyle(fontFamily: 'Aeonik', fontSize: 20, color: Color.fromRGBO(255, 255, 255, 40/100)),
                    )
                        : Text(
                      //{day name} {day number} {month name} {year}
                      "${messages[i+1].sendDate.day}/${messages[i+1].sendDate.month}/${messages[i+1].sendDate.year}",
                      style: const TextStyle(fontFamily: 'Aeonik', fontSize: 20, color: Color.fromRGBO(255, 255, 255, 40/100)),
                    ),
                  ),
                );
              }
            }
            children = childrn;
          }

          return Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(
                color: Colors.white,
                size: 40,
              ),
              backgroundColor: Colors.black,
              title: Row(
                children: [
                  const SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      "https://picsum.photos/250?image=9",
                      width: 40,
                      height: 40,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text("$otherName",
                    style: const TextStyle(fontFamily: 'Aeonik', fontSize: 50, color: Colors.white),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.black,
            body: ListView(
              controller: listViewController,
              reverse: true,
              children: [
                for (final element in children.reversed.toList())
                  element
              ]
            ),
            bottomNavigationBar: NavigationBarChat(),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    notif.Notification.initialize(notPlugin);
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
      //color: message.senderID != myID ? const Color.fromRGBO(52,52,52, 70/100) : const Color.fromRGBO(179,	255,	119, 1),
      margin: message.senderID != myID ? const EdgeInsets.fromLTRB(10, 10, 150, 10) : const EdgeInsets.fromLTRB(150, 10, 10, 10),
      //quiero hacerlo redondeado
      decoration:  BoxDecoration(
        color: message.senderID != myID ? const Color.fromRGBO(52,52,52, 70/100) : const Color.fromRGBO(179,	255,	119, 1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: message.senderID != myID ? Radius.circular(0) : Radius.circular(20),
          bottomRight: message.senderID != myID ? Radius.circular(20) : Radius.circular(0),
      ),
      ),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: message.senderID == myID ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                textAlign: TextAlign.start,
                message.senderID != myID ? message.senderName : "You",
                style: message.senderID != myID
                    ? const TextStyle(fontFamily: 'Aeonik', fontSize: 15, color: Color.fromRGBO(179,	255,	119, 1), fontWeight: FontWeight.bold)
                    : const TextStyle(fontFamily: 'Aeonik', fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              Text(
                textAlign: TextAlign.start,
                message.message,
                style: message.senderID != myID
                    ? const TextStyle(fontFamily: 'Aeonik', fontSize: 20, color: Colors.white)
                    : const TextStyle(fontFamily: 'Aeonik', fontSize: 20, color: Color.fromARGB(200, 52, 52, 52)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                textAlign: TextAlign.end,
                "${message.sendDate.hour.toString().padLeft(2, '0')}:${message.sendDate.minute.toString().padLeft(2, '0')}",
                style: message.senderID != myID
                    ? const TextStyle(fontFamily: 'Aeonik', fontSize: 15, color: Color.fromRGBO(179,	255,	119, 1))
                    : const TextStyle(fontFamily: 'Aeonik', fontSize: 15, color: Colors.black),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class NavigationBarChat extends StatefulWidget {
  const NavigationBarChat({Key? key}) : super(key: key);

  @override
  State<NavigationBarChat> createState() => _NavigationBarChatState();
}

class _NavigationBarChatState extends State<NavigationBarChat> {
  void sendMessage(int myID, int otherID) {
    Message m = Message(
      myID,
      myName!,
      otherID,
      otherName!,
      toSendMessage,
      DateTime.now().toUtc(),
    );
    ChatController().sendMessage(myID, otherID, m);
  }

  final textField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      //Make height of NavigationBar the same as the height of the keyboard
      height: MediaQuery.of(context).viewInsets.bottom + 70,
      alignment: Alignment.bottomCenter,
      color: Colors.black,
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(52,52,52, 30/100),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "Type a message",
                          labelStyle: TextStyle(fontFamily: 'Aeonik', color: Colors.white),

                          hintStyle: TextStyle(fontFamily: 'Aeonik', color: Color.fromRGBO(255,255,255,40/100)),
                          border: InputBorder.none,
                        ),
                        onChanged: (text) {
                          toSendMessage = text;
                        },
                        style: const TextStyle(fontFamily: 'Aeonik', color: Color.fromRGBO(255,255,255,75/100)),
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
                      color: Colors.white,
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