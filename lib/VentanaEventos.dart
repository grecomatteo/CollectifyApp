import 'package:flutter/material.dart';

import 'package:collectify/ConexionBD.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collectify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: VentanaEventos(),
    );
  }
}

class VentanaEventos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Collectify'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Eventos'),
            Expanded(child: EventList()),
          ],
        )));
  }
}

class EventList extends StatefulWidget {
  const EventList({super.key});

  @override
  State<StatefulWidget> createState() => EventListState();
}

class EventListState extends State<EventList> {
  List<Evento> eventos = [];
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Conexion().getListaEventos(),
        builder: (BuildContext context, AsyncSnapshot<List<Evento>> snapshot) {
          if (snapshot.hasData) {
            eventos = snapshot.data!;
            return GridView.count(
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: const EdgeInsets.all(10),
                crossAxisCount: 1,
                children: eventos
                    .map((evento) => EventoWidget(evento: evento))
                    .toList());
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

class EventoWidget extends StatelessWidget {
  final Evento evento;

  const EventoWidget({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(200, 150),
          backgroundColor: const Color.fromARGB(250, 240, 217, 248),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          //Aqui irá una ventana de más información sobre el evento
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(evento.idEvento.toString()),
              Text(evento.nombre as String),
              Text(evento.descripcion as String),
              Text(evento.fechaEvento.toString()),
            ],
          ),
        ));
  }
}
