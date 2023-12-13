
import 'dart:io';

import 'package:collectify/VentanaProducto.dart';
import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'package:flutter/services.dart';
import 'package:mysql1/mysql1.dart';
import 'package:image_picker/image_picker.dart';
import 'VentanaListaProductos.dart';
import 'VentanaPerfil.dart' as perfil;



MySqlConnection? conn;
String nombre = "";
String description = "";
Usuario logged = new Usuario();


class VentanaAnadirProducto extends StatelessWidget {
  const VentanaAnadirProducto({super.key, required this.user});

  final Usuario user;

  @override
  Widget build(BuildContext context) {
    logged = user;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(child: AddProductForm()),
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
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

  Image photo_image = new Image(image: AssetImage('lib/assets/Group_277.png'));
  String default_image = 'lib/assets/Group_277.png';
  bool _imageTaken = false;
  bool esSubasta = false;
  int changeColor = 13; //Este va con rima jejejejejeje
  String tag = "";
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
                fontFamily: 'Aeonik',
            )
          ),
          Text(
            'artículo',
            style: const TextStyle(
              fontSize: 50,
              color: Colors.lightGreen,
              fontFamily: 'Aeonik',
            )
          ),
          Text(
            'Añade fotos',
            style: const TextStyle(
              color: Colors.white,
              height: 4,
              fontFamily: 'Aeonik',
            )
          ),
          ElevatedButton(
            onPressed: () async {
              final imagePicker = ImagePicker();
              pickedFile = await imagePicker.pickImage(source: ImageSource.camera, maxHeight: 150, imageQuality: 90);
              if (pickedFile != null) {
                setState(() {
                  _imageTaken = true;
                  final path = pickedFile!.path;
                  photo_image = Image.file(File(path));
                });
              }
            },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent
              ),

            child: photo_image,
          ),
          Text(
            '¿Que quieres vender?',
              style: const TextStyle(
                  color: Colors.white,
                  height: 4,
                  fontFamily: 'Aeonik',
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
              height: 0.05,
              fontFamily: 'Aeonik',
              color: Colors.white,
            )
          ),
          Text(
            'Categoría',
            style: const TextStyle(
                color: Colors.white,
                height: 4,
                fontFamily: 'Aeonik',
            )
          ),
          Container(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.transparent,
                  child: ElevatedButton(
                      onPressed: (){
                        tag = "Arte y artesanía";
                        setState((){changeColor = 0;});
                      },
                      child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Image.asset(
                                  'lib/assets/tags/Arte_artesania.png',
                                  width: 70,
                                  height: 70
                              ),
                            ),
                            Text(
                                'Arte y artesanía',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Aeonik',
                                )
                            )
                          ]
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: changeColor==0 ? Colors.lightGreen : Colors.white24,
                        padding: EdgeInsets.zero,
                        fixedSize: const Size(80, 130),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      )
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.transparent,
                  child: ElevatedButton(
                      onPressed: (){
                        tag = "Joyas y relojes";
                        setState((){changeColor = 1;});
                      },
                      child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Image.asset(
                                  'lib/assets/tags/Joyas_relojes.png',
                                  width: 70,
                                  height: 70
                              ),
                            ),
                            Text(
                                'Joyas y relojes',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Aeonik',
                                )
                            )
                          ]
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: changeColor==1 ? Colors.lightGreen : Colors.white24,
                        padding: EdgeInsets.zero,
                        fixedSize: const Size(80, 130),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      )
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.transparent,
                  child: ElevatedButton(
                      onPressed: (){
                        tag = "Juguetes";
                        setState((){changeColor = 2;});
                      },
                      child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Image.asset(
                                  'lib/assets/tags/Juguetes.png',
                                  width: 70,
                                  height: 70
                              ),
                            ),
                            Text(
                                'Juguetes',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Aeonik',
                                )
                            ),
                            Text(
                                ''
                            )
                          ]
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: changeColor==2 ? Colors.lightGreen : Colors.white24,
                        padding: EdgeInsets.zero,
                        fixedSize: const Size(80, 130),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      )
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.transparent,
                  child: ElevatedButton(
                      onPressed: (){
                        tag = "Libros y comics";
                        setState((){changeColor = 3;});
                      },
                      child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Image.asset(
                                  'lib/assets/tags/Libros_comics.png',
                                  width: 70,
                                  height: 70
                              ),
                            ),
                            Text(
                                'Libros y comics',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Aeonik',
                                )
                            )
                          ]
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: changeColor==3 ? Colors.lightGreen : Colors.white24,
                        padding: EdgeInsets.zero,
                        fixedSize: const Size(80, 130),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      )
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.transparent,
                  child: ElevatedButton(
                      onPressed: (){
                        tag = "Monedas";
                        setState((){changeColor = 4;});
                      },
                      child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Image.asset(
                                  'lib/assets/tags/Monedas_sellos.png',
                                  width: 70,
                                  height: 70
                              ),
                            ),
                            Text(
                                'Monedas',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Aeonik',
                                )
                            ),
                            Text(
                                ''
                            )
                          ]
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: changeColor==4 ? Colors.lightGreen : Colors.white24,
                        padding: EdgeInsets.zero,
                        fixedSize: const Size(80, 130),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      )
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.transparent,
                  child: ElevatedButton(
                      onPressed: (){
                        tag = "Música";
                        setState((){changeColor = 5;});
                      },
                      child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Image.asset(
                                  'lib/assets/tags/Musica.png',
                                  width: 70,
                                  height: 70
                              ),
                            ),
                            Text(
                                'Música',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Aeonik',
                                )
                            ),
                            Text(
                                ''
                            )
                          ]
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: changeColor==5 ? Colors.lightGreen : Colors.white24,
                        padding: EdgeInsets.zero,
                        fixedSize: const Size(80, 130),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      )
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.transparent,
                  child: ElevatedButton(
                      onPressed: (){
                        tag = "Postales y sellos";
                        setState((){changeColor = 6;});
                      },
                      child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Image.asset(
                                  'lib/assets/tags/Postales.png',
                                  width: 70,
                                  height: 70
                              ),
                            ),
                            Text(
                                'Postales y sellos',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Aeonik',
                                )
                            )
                          ]
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: changeColor==6 ? Colors.lightGreen : Colors.white24,
                        padding: EdgeInsets.zero,
                        fixedSize: const Size(80, 130),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      )
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.transparent,
                  child: ElevatedButton(
                      onPressed: (){
                        tag = "Ropa";
                        setState((){changeColor = 7;});
                      },
                      child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Image.asset(
                                  'lib/assets/tags/Ropa.png',
                                  width: 70,
                                  height: 70
                              ),
                            ),
                            Text(
                                'Ropa',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Aeonik',
                                )
                            ),
                            Text(
                                ''
                            )
                          ]
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: changeColor==7 ? Colors.lightGreen : Colors.white24,
                        padding: EdgeInsets.zero,
                        fixedSize: const Size(80, 130),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      )
                  ),
                ),
              ]
            ),
          ),
          Text(
              'Cuenta un poco más',
              style: const TextStyle(
                  color: Colors.white,
                  height: 4,
                  fontFamily: 'Aeonik',
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
                    color: Colors.grey,
                    fontFamily: 'Aeonik',
                )
            ),
              style: const TextStyle(
                height: 0.05,
                fontFamily: 'Aeonik',
                color: Colors.white,
              )
          ),
          Text(
              'Precio',
              style: const TextStyle(
                  color: Colors.white,
                  height: 4,
                  fontFamily: 'Aeonik',
              )
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
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(),
                  hintText: '€',
                  hintStyle: const TextStyle(
                      color: Colors.grey
                  )
              ),
              style: const TextStyle(
                height: 0.05,
                fontFamily: 'Aeonik',
                color: Colors.white
              ),
            inputFormatters: [priceFormatter], // Applica il formatter per il prezzo
            keyboardType: TextInputType.numberWithOptions(decimal: true)
          ),
          if(esSubasta)
            TextFormField(
                controller: fechaFinalController,
                decoration: InputDecoration(labelText: 'Fecha y hora de finalización (YYYY-MM-DD HH:MM)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true)
            ),

          const SizedBox(height: 16),
          const SizedBox(height: 16),

          ElevatedButton(
              onPressed: () async {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => perfil.VentanaPerfil(mUser: logged, rUser: null)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                fixedSize: const Size(350, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Image(image: AssetImage('lib/assets/Group_233.png')),
                  SizedBox(width: 5),
                  Text(
                      'Destaca tu artículo',
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: 'Aeonik'
                      )
                  ),
                  SizedBox(width: 5),
                  Image(image: AssetImage('lib/assets/cPlusText.png')),
                ]
              )
          ),

          const SizedBox(height: 16),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final productName = nameController.text;
              final productDescription = descriptionController.text;
              //final fecha = fechaFinalController.text;
              final String precioInicial;
              final String productPrice;
              //DateTime fechaFinal =DateTime.parse(fecha);
              precioInicial= priceController.text;
              productPrice = priceController.text;
              Producto prod = Producto();
              prod.nombre = productName;
              //Los doubles le dan ansiedada Flutter, hay que checkear si es null
              if(productPrice.isNotEmpty && productPrice != null){
                prod.precio = double.parse(productPrice);
              }
              prod.descripcion = productDescription;
              prod.categoria = tag;
              //prod.fechaFin = fechaFinal;

              int productID = 0;
              await Conexion().anadirProducto(prod,logged).then((results){
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              fixedSize: const Size(350, 50),
            ),

            child: Text(
                'Subir artículo',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: 'Aeonik'
                ),
            ),
          ),
        ],
      ),
    );
  }



}
