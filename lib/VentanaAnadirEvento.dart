import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'package:flutter/services.dart';
import 'VentanaListaProductos.dart';

String nombre = "";
String description = "";
//Placeholder, se debe cambiar
Usuario logged = new Usuario();

class VentanaAnadirEvento extends StatelessWidget {
  const VentanaAnadirEvento({super.key, required this.user});

  final Usuario user;

  @override
  Widget build(BuildContext context) {
    logged = user;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Anadir nuevo evento'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: AddEventoForm(),
    );
  }
}

class AddEventoForm extends StatefulWidget {
  const AddEventoForm({super.key});

  @override
  _AddEventoFormState createState() => _AddEventoFormState();
}

class _AddEventoFormState extends State<AddEventoForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(),
                  hintText: 'Nombre del evento',
                  hintStyle: const TextStyle(color: Colors.grey)),
              style: const TextStyle(
                height: 0.05,
                fontFamily: 'Aeonik',
                color: Colors.white,
              )),
          SizedBox(height: 10),
          TextFormField(
            style: const TextStyle(
              height: 0.05,
              fontFamily: 'Aeonik',
              color: Colors.white,
            ),
            controller: direccionController,
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(),
                hintText: 'Dirección del evento',
                hintStyle: const TextStyle(color: Colors.grey)),
          ),
          SizedBox(height: 10),
          TextFormField(
            style: const TextStyle(
              height: 0.05,
              fontFamily: 'Aeonik',
              color: Colors.white,
            ),
            controller: descriptionController,
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(),
                hintText: 'Descripción',
                hintStyle: const TextStyle(color: Colors.grey)),
          ),
          SizedBox(height: 10),
          TextFormField(
            style: const TextStyle(
              height: 0.05,
              fontFamily: 'Aeonik',
              color: Colors.white,
            ),
            readOnly: true,
            controller: fechaController,
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(),
                hintText: 'Fecha del evento',
                hintStyle: const TextStyle(color: Colors.grey)),
            onTap: () async {
              DateTime? date = await seleccionarFechas(context);
              fechaController.text = date.toString().substring(0, 16);
            },
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final nombre = nameController.text;
              final descripcion = descriptionController.text;
              final direccion = direccionController.text;
              final fechaEvento = fechaController.text;
              DateTime fechaFinal = DateTime.parse(fechaEvento);
              Evento evento = new Evento();
              evento.nombre = nombre;
              evento.descripcion = descripcion;
              evento.direccion = direccion;
              evento.fechaEvento = fechaFinal;

              await Conexion().anadirEvento(evento, user).then((results) {
                debugPrint(results.toString());
                if (results != -1) {
                  Navigator.of(context).pop();
                }
              });
            },
            child: Text('Anadir Evento'),
          ),
        ],
      ),
    );
  }
}

Future<DateTime> seleccionarFechas(BuildContext context) async {
  DateTime? date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2030),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFE6F1F),
            onPrimary: Colors.white,
            surface: Color(0xFFFE6F1F),
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: Color(0xFF343434),
        ),
        child: child!,
      );
    },
  );
  print(date);
  //añadir hora
  if (date != null) {
    print("aaaaaa");
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFE6F1F),
              onPrimary: Colors.white,
              surface: Color(0xFF343434),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Color(0xFFFE6F1F),
          ),
          child: child!,
        );
      },
    );
    print("bbbbbb");
    print(time);
    if (time != null) {
      print("cccccc"); print("Entrando en el if");
      date = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      print(date);
    }
  }

  return date!;
}
