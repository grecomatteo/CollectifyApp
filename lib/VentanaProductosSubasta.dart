import 'package:flutter/material.dart';

void main() {
  runApp(VentanaSubasta());
}

class VentanaSubasta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collectify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: VentanaSubastaScreen(),
    );
  }
}

class VentanaSubastaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Lista de objetos en subasta'),
      ),
      body: SubastasForm(),
    );
  }
}

class SubastasForm extends StatefulWidget {
  @override
  _SubastasFormState createState() => _SubastasFormState();
}

class _SubastasFormState extends State<SubastasForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
    child: Column()
    );
  }
}