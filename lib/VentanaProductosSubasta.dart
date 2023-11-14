import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'package:mysql1/mysql1.dart';


void main() {
  runApp(VentanaSubasta());
}

class VentanaSubasta extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
    return FutureBuilder(
      future: Conexion().getProductosSubasta(),
      builder: (BuildContext context, AsyncSnapshot<List<Producto>> snapshot) {
        if (snapshot.hasData) {
          debugPrint(snapshot.data!.length.toString());
          return GridView.count(
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            padding: const EdgeInsets.all(10),
            crossAxisCount: 2,
            children: snapshot.data!
                .map((e) => ProductoWidget(
                id: e.productoID, nombre: e.nombre, precioInicial: e.precioInicial, image: e.image, esPremium: e.esPremium,ultimaOferta:e.ultimaOferta, fechaFin: e.fechaFin ))
                .toList(),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class ProductoWidget extends StatelessWidget {
  final int? id;
  final String? nombre;
  final Blob? image;
  final bool? esPremium;
  final DateTime? fechaFin;
  final int? precioInicial;
  final int? ultimaOferta;

  const ProductoWidget({super.key, this.id, this.nombre, this.precioInicial, this.image, this.esPremium,this.ultimaOferta, this.fechaFin});

  String Temporizador(){
    DateTime now= DateTime.now();
    final diferencia = fechaFin?.difference(now);
    final Dia = diferencia?.inDays ;
    final Hora = diferencia!.inHours % 24;
    final Min = diferencia.inMinutes%60;
    final Sec = diferencia.inSeconds%60;

    if(diferencia.isNegative){return "¡Terminada!";}
    else {return "Cierra en: ${Dia}d, ${Hora}h, ${Min}m, ${Sec}s";}
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(250, 240, 217, 248),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          //Aqui irá la descripcion detallada de producto
        },
        child: Center(
          child: Column(
            children: [
              const Spacer(),
              Flexible(
                  flex: 15,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        image: Image.memory(const Base64Decoder().convert(image.toString())).image,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),

                  )
              ),

              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(esPremium == true)
                            //Make a row with the icon and the text, the icon must be in the left border
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.yellow,),
                                Text("Premium", style: TextStyle(color: Colors.yellow),),
                                //Add icon to the left Icon(Icons.favorite_border_outlined),
                                Container(width: 20),
                                Icon(Icons.favorite_border_outlined),
                              ],
                            ),
                          Text(nombre!,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 50, 50, 50),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            "Ultima oferta: $ultimaOferta €",
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            Temporizador(),
                            style: const TextStyle(
                              color: Colors.purple,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]
                    ),
                    const Spacer(),
                  ]
              ),
              const Spacer(),
            ],
          ),
        ));
  }
}

