
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


class VentanaAnadirProducto extends StatelessWidget {
  const VentanaAnadirProducto({super.key, required this.user});

  final Usuario user;

  @override
  Widget build(BuildContext context) {
    logged = user;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: AddProductForm(),
      backgroundColor: Colors.black,
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
  final TextEditingController precioInicialController = TextEditingController();
  final TextEditingController fechaFinalController = TextEditingController();



  final priceFormatter = FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'));

  bool _imageTaken = false; // Per tenere traccia se l'immagine è stata scattata
  bool esSubasta = false;
  XFile? pickedFile;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Sube tu',
            style: const TextStyle(
                fontSize: 50,
                color: Colors.white,
                height: 0.5,
            )
          ),
          Text(
            'artículo',
            style: const TextStyle(
              fontSize: 50,
              color: Colors.lightGreen
            )
          ),
          Text(
            'Añade fotos',
            style: const TextStyle(
              color: Colors.white,
              height: 4
            )
          ),
          ElevatedButton(
            onPressed: () async {
              final imagePicker = ImagePicker();
              pickedFile = await imagePicker.pickImage(source: ImageSource.camera, maxHeight: 150, imageQuality: 90);
              if (pickedFile != null) {
                setState(() {
                  _imageTaken = true;
                });
              }
            },
            child: Text('Toma una foto'),
          ),
          Text(
            '¿Que quieres vender?',
              style: const TextStyle(
                  color: Colors.white,
                  height: 4
              )
          ),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(),
                hintText: 'Titulo',
                hintStyle: const TextStyle(
                  color: Colors.grey
                )
            ),
            style: const TextStyle(
              height: 0.05
            )
          ),
          Text(
            'Categoría',
            style: const TextStyle(
                color: Colors.white,
                height: 4
            )
          ),
          Text(
              'Cuenta un poco más',
              style: const TextStyle(
                  color: Colors.white,
                  height: 4
              )
          ),
          TextFormField(
            controller: descriptionController,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(),
                hintText: 'Descripción',
                hintStyle: const TextStyle(
                    color: Colors.grey
                )
            ),
          ),
          if(esSubasta)
            TextFormField(
                controller: precioInicialController,
                decoration: InputDecoration(labelText: 'Precio Inicial'),
                inputFormatters: [priceFormatter], // Applica il formatter per il prezzo
                keyboardType: TextInputType.numberWithOptions(decimal: true)
            )
          else
          TextFormField(
            controller: priceController,
            decoration: InputDecoration(labelText: 'Precio'),
            inputFormatters: [priceFormatter], // Applica il formatter per il prezzo
            keyboardType: TextInputType.numberWithOptions(decimal: true)
          ),
          if(esSubasta)
            TextFormField(
                controller: fechaFinalController,
                decoration: InputDecoration(labelText: 'Fecha y hora de finalización (YYYY-MM-DD HH:MM)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true)
            ),

          Row(
            children: [
              Checkbox(
                  value: esSubasta,
                  onChanged: (e){
                      setState(() {
                      esSubasta = e!;

                      }
                      );
                  }
              ),
              Text("Es subasta"),
            ],
          ),

          const SizedBox(height: 16),
          _imageTaken
              ? Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48.0,
          )
              : ElevatedButton(
            onPressed: () async {
              final imagePicker = ImagePicker();
              pickedFile = await imagePicker.pickImage(source: ImageSource.camera, maxHeight: 150, imageQuality: 90);
              if (pickedFile != null) {
                setState(() {
                  _imageTaken = true;
                });
              }
            },
            child: Text('Toma una foto'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final productName = nameController.text;
              final productDescription = descriptionController.text;
              final fecha = fechaFinalController.text;
              final String precioInicial;
              final String productPrice;
              DateTime fechaFinal =DateTime.parse(fecha);
              if(esSubasta){
                precioInicial= precioInicialController.text;
                productPrice = precioInicialController.text;
              }else{
                precioInicial= priceController.text;
                productPrice = priceController.text;
              }
              Producto prod = Producto();
              prod.nombre = productName;
              prod.precio = double.parse(productPrice);
              prod.descripcion = productDescription;
              prod.fechaFin = fechaFinal;

              int productID = 0;
              await Conexion().anadirProducto(prod,user).then((results){
                debugPrint(results.toString());
                productID = results;
                if(results != -1){
                  int newId = results;
                  pickedFile?.readAsBytes().then((value1) {
                      prod.image = Blob.fromBytes(value1);
                      Conexion().anadirImagen(productName, newId, value1).then((value) {
                              Navigator.of(context).pop();
                      });
                  });
                  if(esSubasta){
                    Conexion().anadirProductoSubasta(productID , int.parse(precioInicial),fechaFinal).then((value) => null);
                  }
                }

                else{
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text("¡Error!"),
                        content: const Text("Falta algun campo."),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("OK"))
                        ],
                      ));
                }
              });
              //Navigator.pop(context);
            },
            child: Text('Anadir Producto'),
          ),
        ],
      ),
    );
  }



}
