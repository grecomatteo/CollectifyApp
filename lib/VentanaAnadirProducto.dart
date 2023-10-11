import 'package:flutter/material.dart';

class AnadirProducto extends StatelessWidget {
  const AnadirProducto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Añadir Producto"),
      ),
      body: const Center(
        child: Text("Añadir Producto"),
      ),
    );
  }
}
