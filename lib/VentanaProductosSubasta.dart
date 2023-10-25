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
    int inicio = 23;
    double fin = fechaFin!.hour *60*60;
    double tiempo = fin - inicio;
    return "$tiempo" ;
  }

  Future<Blob> callAsyncFetch() async {
    Blob imageBlob = Blob.fromBytes([]);
    await Conexion().obtenerImagen(id!).then((value)
    {
      imageBlob = value!;
    });
    return imageBlob;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Blob?>(
        future: callAsyncFetch(),
        builder: (context, AsyncSnapshot<Blob?> snapshot) {
          if (snapshot.hasData) {
            Blob imageBlob = snapshot.data!;
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
                                image: Image.memory(const Base64Decoder().convert(imageBlob.toString())).image,
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
                                    const Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.yellow,),
                                        Text("Premium", style: TextStyle(color: Colors.yellow),),
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
                                    "Ultima oferta: $ultimaOferta€",
                                    style: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Cierra en" + Temporizador() + "." ,
                                    style: const TextStyle(
                                      color: Colors.purple,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ]
                            ),
                            const Spacer(),
                            const Icon(Icons.favorite_border_outlined),

                          ]
                      ),
                      const Spacer(),
                    ],
                  ),
                ));
          } else {
            return CircularProgressIndicator();
          }
        }
    );
  }
}

