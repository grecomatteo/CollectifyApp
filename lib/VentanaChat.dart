import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:path/path.dart';
import 'package:collectify/VentanaMensajesChat.dart';
import 'package:collectify/Message.dart';


int myID = 0;
MySqlConnection? conn;

class VentanaChat extends StatelessWidget {
  const VentanaChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Chat"),
      ),
      body: const TextAndChat(),
    );
  }
}

class TextAndChat extends StatefulWidget {
  const TextAndChat({Key? key}) : super(key: key);

  @override
  _TextAndChatState createState() => _TextAndChatState();
}

class _TextAndChatState extends State<TextAndChat> {

  int chatTileCount = 0; // Initial number of chat tiles
  List<Message> chatList = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'UserID',
          ),
          onSubmitted: (String str) {
            setState(() {
              UpdateMessages(int.parse(str));
            });
          },
        ),
        Expanded(child: ChatList(chatList: chatList)),
      ],
    );
  }

  Future<void> connectToDatabase() async {
    try{

      conn = await MySqlConnection.connect(
          ConnectionSettings(
            host: "collectify-server-mysql.mysql.database.azure.com",
            port: 3306,
            user: "pin2023",
            password: "AsLpqR_23",
            db: "collectifyDB",
          ));
    }catch(e){
      debugPrint(e.toString() + "Error");
    }
  }


  Future<void> UpdateMessages(int id) async {
    myID = id;
    List<ResultRow> maps = [];
    await conn?.query('select * from chat_messages').then((results) {
      for (var row in results) {
        maps.add(row);
      }
    });

    List<Message> messages = List.generate(maps.length, (i) {
      return Message(
        maps[i]['senderID'],
        maps[i]['receiverID'],
        maps[i]['message'],
        DateTime.parse(maps[i]['sendDate']),
      );
    });

    // Get the number of messages
    int messageCount = messages.length;

    // Create a list of messages (text)
    List<Message> messageTexts = [];
    for(int i = 0; i < messageCount; i++) {
      messageTexts.add(messages[i]);
    }

    setState(() {
      chatTileCount = messageCount;
      chatList = messageTexts;
    });
  }
}

class ChatList extends StatelessWidget {
  final List<Message> chatList;

  const ChatList({Key? key, required this.chatList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(chatList.isEmpty) return const Text("No messages");
    //Get all senderIDs
    List<int> senderIDs = [];
    for(int i = 0; i < chatList.length; i++) {
      if(chatList[i].senderID != myID) {
        senderIDs.add(chatList[i].senderID);
      }
    }
    //Remove duplicates
    senderIDs = senderIDs.toSet().toList();

    //Create a dictionary with the senderID as key and the message list as value
    List<(int, List<Message>)> messagesFromSender = [];
    for(int i = 0; i < senderIDs.length; i++) {
      List<Message> messages = [];
      for(int j = 0; j < chatList.length; j++) {
        if(chatList[j].senderID == senderIDs[i] || chatList[j].receiverID == senderIDs[i]) {
          messages.add(chatList[j]);
        }
      }
      messagesFromSender.add((senderIDs[i], messages));
    }

    return ListView.builder(
      shrinkWrap: false,
      //add space between cards
      padding: const EdgeInsets.all(10),
      //itemCount: chatTileCount,
      itemCount:  messagesFromSender.length,
        itemBuilder: (context, index) =>
            Chat(messagesFromSender[index].$1, messagesFromSender[index].$2)
    );
  }
}

class Chat extends StatelessWidget {
  final int senderID;
  final List<Message> messages;

  const Chat(this.senderID, this.messages, {super.key});

  @override
  Widget build(BuildContext context) {
    String name = "User $senderID";
    String lastMessage = "${messages[messages.length - 1].senderID}: ${messages[messages.length - 1].message}";
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
              MaterialPageRoute(builder: (context) => VentanaMensajesChat(messages, myID)),
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
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left, softWrap: false, overflow: TextOverflow.fade,),
                          Text(lastMessage, textAlign: TextAlign.left, softWrap: false, overflow: TextOverflow.fade,),
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
}
