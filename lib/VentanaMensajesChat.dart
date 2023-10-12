import 'package:collectify/VentanaChat.dart';
import 'package:flutter/material.dart';
import 'package:collectify/Message.dart';

class VentanaMensajesChat extends StatelessWidget {
  VentanaMensajesChat(this.chatList);

  final List<Message> chatList;

  @override
  Widget build(BuildContext context) {
    String name = chatList[0].senderID.toString();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("$name's Chat"),
      ),
      body: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          return MessageDisplay(message: chatList[index], myID: myID);
        },
      ),
      resizeToAvoidBottomInset: false,
      //When the keyboard is open put the NavigationBar on top of the keyboard
      bottomNavigationBar: NavigationBar(),
    );
  }
}

class MessageDisplay extends StatelessWidget {
  const MessageDisplay({Key? key, required this.message, required this.myID})
      : super(key: key);

  final Message message;
  final int myID;

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
  NavigationBar({Key? key}) : super(key: key);

  String message = "";

  Future<void> SendMessage() async{
    await conn?.query('select * from usuario').then((results) {
    for (var row in results) {
    debugPrint(row.toString());
    }
    });
  }

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
                          message = text;
                        },

                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {

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
