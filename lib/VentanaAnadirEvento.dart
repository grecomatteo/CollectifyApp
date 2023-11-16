

import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'package:flutter/services.dart';
import 'package:mysql1/mysql1.dart';
import 'VentanaListaProductos.dart';



MySqlConnection? conn;
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
      appBar: AppBar(
        title: Text('Anadir nuevo evento'),
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
            decoration: InputDecoration(labelText: 'Nombre evento'),
          ),
          TextFormField(
            controller: direccionController,
            decoration: InputDecoration(labelText: 'Dirección'),
          ),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Descripción'),
          ),
          TextFormField(
              controller: fechaController,
              decoration: InputDecoration(labelText: 'Fecha evento (YYYY-MM-DD HH:MM)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true)
          ),
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


              await Conexion().anadirEvento(evento,user).then((results){
                debugPrint(results.toString());
                if(results != -1){
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
