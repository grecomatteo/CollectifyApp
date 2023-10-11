import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

class Message {
  final int senderID;
  final int receiverID;
  final String message;
  final DateTime sendDate;

  Message(this.senderID, this.receiverID, this.message, this.sendDate);

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'receiverID': receiverID,
      'message': message,
      'sendDate': sendDate,
    };
  }

  @override
  String toString() {
    return 'Message{senderID: $senderID, receiverID: $receiverID, message: $message, sendDate: $sendDate}';
  }
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

  Future<Database> createDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      join(databasePath, 'chat_database.db'),
      onOpen: (db) async {
        await db.execute('DROP TABLE IF EXISTS chat_messages');
        await db.execute('CREATE TABLE chat_messages(id INT PRIMARY KEY, senderID INT, receiverID INT, message TEXT, sendDate DATE )');

        // Insert initial messages into the database
        await db.insert('chat_messages', {'senderID': 0, 'receiverID': 1, 'message': 'Hello', 'sendDate': '2023-10-10'});
        await db.insert('chat_messages', {'senderID': 2, 'receiverID': 1, 'message': 'Quiero 20€', 'sendDate': '2023-09-10'});
        await db.insert('chat_messages', {'senderID': 0, 'receiverID': 1, 'message': 'How are you?', 'sendDate': '2023-10-11'});
        await db.insert('chat_messages', {'senderID': 1, 'receiverID': 0, 'message': 'Fine!', 'sendDate': '2023-10-12'});
      }
    );

    return database;
  }


  Future<void> UpdateMessages(int id) async {
    final Database database = await createDatabase();

    // Query the table for all the messages from the user with id
    final List<Map<String, dynamic>> maps = await database.query('chat_messages', where: 'receiverID = ?', whereArgs: [id]);

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
      senderIDs.add(chatList[i].senderID);
    }
    //Remove duplicates
    senderIDs = senderIDs.toSet().toList();

    //Get the last message from each sender
    List<Message> lastMessages = [];
    for(int i = 0; i < senderIDs.length; i++) {
      List<Message> messagesFromSender = [];
      for(int j = 0; j < chatList.length; j++) {
        if(chatList[j].senderID == senderIDs[i]) {
          messagesFromSender.add(chatList[j]);
        }
      }
      lastMessages.add(messagesFromSender.last);
    }

    return GridView.count(
      crossAxisCount: 1,
      childAspectRatio: 2,
      children: List.generate(lastMessages.length, (index) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Chat(name: lastMessages[index].senderID.toString(), lastMessage: lastMessages[index].message.toString()),
        );
      }),
    );
  }
}

class Chat extends StatelessWidget {
  final String name;
  final String lastMessage;

  const Chat({Key? key, required this.name, required this.lastMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {},
      child: Center(
        child: Column(
          children: [
            Text(name),
            Text(lastMessage),
          ],
        ),
      ),
    );
  }
}
