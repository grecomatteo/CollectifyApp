import 'dart:async';
import 'dart:io';
import 'package:collectify/ConexionBD.dart';
import 'package:collectify/VentanaChat.dart';
import 'package:flutter/material.dart';
import 'package:collectify/Message.dart';
import 'package:collectify/notification.dart' as notif;
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as noti;
import 'package:mysql1/mysql1.dart';

String toSendMessage = "";

int myID = 0;
int otherID = 0;
int msgNum = 0;
String? otherName = "";

Socket? chatSocket;

noti.FlutterLocalNotificationsPlugin notPlugin = noti.FlutterLocalNotificationsPlugin();

Future<List<Message>> getMessages() async{
  List<ResultRow> maps = [];
  await conn?.query('''
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
          (cm.senderID = $myID AND cm.receiverID = $otherID) OR
          (cm.senderID = $otherID AND cm.receiverID = $myID)
      ORDER BY
          cm.sendDate;

      ''').then((results) {
    for (var row in results) {
      maps.add(row);
      debugPrint(row.toString());
    }
  });

  List<Message> messageList = List.generate(maps.length, (i) {
    return Message(
      maps[i]['senderID'],
      maps[i]['senderName'].toString(),
      maps[i]['receiverID'],
      maps[i]['receiverName'].toString(),
      maps[i]['message'].toString(),
      maps[i]['sendDate'],
    );
  });
  msgNum = messageList.length;
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

  List<Message> messages = [];
  StreamController<List<Message>> _messages = StreamController<List<Message>>.broadcast();

  void handleGetAllMessages(String message){

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

  void handleGetNewMessage(String message){
    //message format: "NewMessage:[senderID, senderName, receiverID, receiverName, message, sendDate]"
    var split = message.split(":");
    //What we get is a list of strings, each string is a list of integers
    //We need to convert each string to a list of integers
    List<List<int>> msg = [];
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

  void handleMessages(String message) {
    if (message.startsWith("Messages:")) {
      handleGetAllMessages(message);
    } else if (message.startsWith("NewMessage:")) {
      handleGetNewMessage(message);
    }
  }

  @override
  Widget build(BuildContext context) {

    Socket.connect('10.0.2.2', 55555).then((value) {
      value.write("GetMessages:$myID:$otherID");
      chatSocket = value;
      value.listen((event) {
        String message = String.fromCharCodes(event);
        handleMessages(message);
      });
    });

    myID = iD;
    otherID = oID;

    Conexion().getUsuarioByID(otherID).then((value) =>
    otherName = value?.nick
    );
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("$otherName's Chat"),
        ),
        body: StreamBuilder<List<Message>>(
          stream: _messages.stream,
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

  @override
  void initState()
  {
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
    var prev = msgNum;
    List<Message> received;
    received = await getMessages();
    if(msgNum > prev){
      var msg = received.last;
      notif.Notification.showBigTextNotification(title: msg.senderName, body: msg.message, fln: notPlugin);
    }
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