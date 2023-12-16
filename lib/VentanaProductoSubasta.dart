import 'dart:convert';
import 'package:flutter/material.dart';
import 'ConexionBD.dart';
import 'package:share_plus/share_plus.dart';

Usuario user = Usuario();
String? userUltPuja;
Producto product = Producto();


class VentanaProductoSubasta extends StatelessWidget {
  const VentanaProductoSubasta(
      {super.key, required this.connected, required this.producto});

  final Usuario connected;
  final Producto producto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
          children: [
      Container(
      height: MediaQuery.of(context).size.width * 0.80,
      decoration: BoxDecoration(
          image: DecorationImage(
            image: MemoryImage(
              const Base64Decoder().convert(producto.image.toString()),
            ),
            fit: BoxFit.cover,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          )),
    ),

            ...fixedWidgets(context),
    ]
    ),


    );
  }


}
List<Widget> fixedWidgets(BuildContext context) {
  return [
    Positioned(
      top: 20,
      left: 20,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    ),
    Positioned(
      top: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: IconButton(
          icon: Icon(Icons.share, color: Colors.white),
          onPressed: () {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final String textoCompartir =
                '¡Echa un vistazo a este objeto en venta!\nhttps://collectify.es/${product.productoID}';
            Share.share(
              textoCompartir,
              subject: 'Enlace del objeto en ventana',
              sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
            );
          },
        ),
      ),
    ),
    Positioned(
      top: 20,
      right: 70,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: IconButton(
          icon: Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (buildcontext) {
                return AlertDialog(
                  contentPadding: const EdgeInsets.all(8.0),
                  title: const Text("¡Error!",
                      style: TextStyle(color: Colors.red)),
                  content: const Text(
                      "tt esperate que esto aun no esta implementao"),
                  actions: <Widget>[
                    ElevatedButton(
                      child: const Text(
                        "volver pa tras",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.of(buildcontext).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    ),
  ];
}

