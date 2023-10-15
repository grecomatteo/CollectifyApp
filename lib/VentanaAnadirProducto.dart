import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'package:flutter/services.dart';


class VentanaAnadirProducto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aggiungi un nuovo prodotto'),
      ),
      body: AddProductForm(),
    );
  }
}

class AddProductForm extends StatefulWidget {
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
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final productName = nameController.text;
              final productPrice = priceController.text;
              final productDescription = descriptionController.text;

              Producto prod = Producto();
              prod.nombre = productName;
              prod.precio = double.parse(productPrice);
              prod.descripcion = productDescription;
              prod.imagePath = "lib/assets/productos/$productName.png";

              // Qui puoi utilizzare i dati del prodotto per eseguire l'invio al tuo server o database
              // E poi tornare alla pagina principale.
              Navigator.pop(context);
            },
            child: Text('Anadir Producto'),
          ),
        ],
      ),
    );
  }
}
