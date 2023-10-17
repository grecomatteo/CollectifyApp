import 'package:collectify/ConexionBD.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:collectify/VentanaMensajesChat.dart';
import 'package:collectify/Message.dart';


int myID = 0;
MySqlConnection? conn;

Future<List<Message>> connectToDatabase() async {
  try{
    conn = await MySqlConnection.connect(
        ConnectionSettings(
          host: "collectify-server-mysql.mysql.database.azure.com",
          port: 3306,
          user: "pin2023",
          password: "AsLpqR_23",
          db: "collectifyDB",
        ));

    List<ResultRow> maps = [];
    await conn?.query('select * from chat_messages where (senderID=$myID OR receiverID=$myID) ORDER BY sendDate DESC LIMIT 1').then((results) {
      for (var row in results) {
        maps.add(row);
      }
    });

    List<Message> messages = List.generate(maps.length, (i) {
      Message m = Message(
        maps[i]['senderID'],
        maps[i]['receiverID'],
        maps[i]['message'].toString(),
        maps[i]['sendDate'],
      );
      debugPrint(m.toString());
      return m;

    });


    return messages;
  }catch(e){
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Chat"),
      ),
      body: const TextAndChat(),
    );
  }
}

class TextAndChat extends StatelessWidget
{
  const TextAndChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ;
    return FutureBuilder<List<Message>>(
      future: connectToDatabase(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Message> messages = snapshot.data!;
          return ChatList(messages: messages);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

class ChatList extends StatelessWidget {
  final List<Message> messages;

  const ChatList({required this.messages, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(messages.isEmpty) return const Text("No messages");

    return ListView.builder(
      shrinkWrap: false,
      //add space between cards
      padding: const EdgeInsets.all(10),
      //itemCount: chatTileCount,
      itemCount:  messages.length,
      itemBuilder: (context, index) =>
          Chat(messages[index]),
    );
  }
}

class Chat extends StatefulWidget {
  final Message message;

  const Chat(this.message, {Key? key}) : super(key: key);

  @override
  State<Chat> createState() => ChatState(message);
}

class ChatState extends State<Chat> {
  final Message message;

  ChatState(this.message);

  String? name = "";
  String? lastMessage = "";

  @override
  Widget build(BuildContext context) {

    int otherID = message.senderID == myID ? message.receiverID : message.senderID;
    Conexion().getUsuarioByID(otherID).then((value) => setState(() {
      name = value?.nick;
      Conexion().getUsuarioByID(message.senderID).then((value1) =>
          lastMessage = "${value1?.nick}: ${message.message}");
    }));
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
}