import 'package:collectify/VentanaChat.dart';
import 'package:flutter/material.dart';
import 'package:collectify/Message.dart';
import 'package:mysql1/mysql1.dart';

String toSendMessage = "";
List<Message> messages = [];


Future<List<Message>> getMessages(int myID, int chatIndex) async{
  List<ResultRow> maps = [];
  await conn?.query('select * from chat_messages where (senderID=$myID AND receiverID=$chatIndex) OR (receiverID=$myID AND senderID=$chatIndex)').then((results) {
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

  messages = messageList;
  return messageList;
}

//List view controller
final listViewController = ScrollController();
class VentanaMensajesChat extends StatelessWidget {
  const VentanaMensajesChat(this.otherID, this.myID, {super.key});

  final int myID;
  final int otherID;

  @override
  Widget build(BuildContext context) {
    String name = otherID.toString();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("$name's Chat"),
      ),
      body: FutureBuilder (
        future: getMessages(myID, otherID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return MessageDisplay(message: messages[index], myID: myID, otherID: otherID);
            },
            controller: listViewController,
          );
        },
      ),
      resizeToAvoidBottomInset: false,
      //When the keyboard is open put the NavigationBar on top of the keyboard
      bottomNavigationBar: NavigationBar(myID, otherID),
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
      color: message.senderID == myID ? Colors.blue : Colors.red,
      margin: const EdgeInsets.all(10),
      alignment: message.senderID == myID
          ? Alignment.centerRight
          : Alignment.centerLeft,
      padding: const EdgeInsets.all(10),
      child: Text(message.message),
    );
  }
}

class NavigationBar extends StatelessWidget {
  NavigationBar(this.myID, this.otherID, {Key? key}) : super(key: key);

  final int myID;
  final int otherID;

  Future<void> sendMessage(int myID, int otherID) async{
    await conn?.query("insert into chat_messages(senderID, receiverID, message, sendDate) values($myID, $otherID, '$toSendMessage', now())");
    getMessages(myID, otherID);
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
                        sendMessage(myID, otherID);
                        //empty the text field
                        textField.clear();
                        toSendMessage = "";
                        //scroll to the bottom
                        listViewController.animateTo(
                          listViewController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
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