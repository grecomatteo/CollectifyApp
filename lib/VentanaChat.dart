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
      body: const TextAndChat(),
    );
  }
}

class TextAndChat extends StatelessWidget {
  const TextAndChat({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'UserID',
          ),
        ),
        Expanded(child:
        ChatList())
      ],
    );
  }
}

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisCount: 1,
        childAspectRatio: 5,
        children: List.generate(20, (index) {
          return Container(
            padding: const EdgeInsets.all(10),
            child: const Chat(),
          );
        }));
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