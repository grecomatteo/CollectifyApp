

import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'package:flutter/services.dart';
import 'package:mysql1/mysql1.dart';
import 'package:image_picker/image_picker.dart';
import 'VentanaListaProductos.dart';



MySqlConnection? conn;
String nombre = "";
String description = "";
//Placeholder, se debe cambiar
Usuario logged = new Usuario();

Future<bool> validateFields() async {
  conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: "collectify-server-mysql.mysql.database.azure.com",
        port: 3306,
        user: "pin2023",
        password: "AsLpqR_23",
        db: "collectifyDB",
      ));
  await conn?.query('select * from producto where (nombre = $nombre AND descripcion = $description)').then((result) {
    return true;
  }
  );
  return false;
  //return true;
}


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
  final TextEditingController direcionController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();

  bool _imageTaken = false; // Per tenere traccia se l'immagine è stata scattata
  XFile? pickedFile;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Nombre producto'),
          ),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Descripción'),
          ),
          TextFormField(
              controller: fechaController,
              decoration: InputDecoration(labelText: 'Fecha y hora de finalización (YYYY-MM-DD HH:MM)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true)
          ),
          ElevatedButton(
            onPressed: () async {
              final productName = nameController.text;
              final productDescription = descriptionController.text;
              final fecha = fechaController.text;
              final String precioInicial;
              final String productPrice;
              DateTime fechaFinal =DateTime.parse(fecha);



              int productID = 0;

            },
            child: Text('Anadir Producto'),
          ),
        ],
      ),
    );
  }



}
