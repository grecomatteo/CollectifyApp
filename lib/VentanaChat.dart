import 'package:flutter/material.dart';
import 'package:collectify/VentanaAnadirProducto.dart';

class VentanaChat extends StatelessWidget{
  const VentanaChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Chat"),
      ),
      body: const ChatList(),
    );
  }
}

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'UserID',
          ),
        ),
      ],
    );
  }
}

class Chat extends StatelessWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: (){},
        child: const Center(
          child: Column(
            children: [
              Text("Usuario"),
              Text("Ultimo mensaje"),
            ],
          ),

        )
    );
  }

}