
import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'package:flutter/services.dart';
import 'package:mysql1/mysql1.dart';

import 'VentanaListaProductos.dart';


MySqlConnection? conn;
String nombre = "";
String description = "";

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
    if (result != null) return true;
  }
  );
  return false;
  //return true;
}


class VentanaAnadirProducto extends StatelessWidget {
  const VentanaAnadirProducto({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anadir nuevo producto'),
      ),
      body: AddProductForm(),
    );
  }
}

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final priceFormatter = FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'));
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
            controller: priceController,
            decoration: InputDecoration(labelText: 'Precio'),
            inputFormatters: [priceFormatter], // Applica il formatter per il prezzo
            keyboardType: TextInputType.numberWithOptions(decimal: true)
          ),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Descripción'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final productName = nameController.text;
              final productPrice = priceController.text;
              final productDescription = descriptionController.text;

              Producto prod = Producto();
              prod.nombre = productName;
              prod.precio = double.parse(productPrice);
              prod.descripcion = productDescription;
              prod.imagePath = "lib/assets/productos/$productName.png";
              if(await Conexion().anadirProducto(prod) !=null){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListaProductos()));
              }
              else{
                var errorText = "Falta details";
              }
              Navigator.pop(context);
            },
            child: Text('Anadir Producto'),
          ),
        ],
      ),
    );
  }
}
