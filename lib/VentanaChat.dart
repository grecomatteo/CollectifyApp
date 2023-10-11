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
      body: const Center(
        child: Text("Chat"),
      ),
    );
  }
}