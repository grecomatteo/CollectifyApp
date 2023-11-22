import 'dart:async';
import 'dart:convert';

import 'package:collectify/VentanaPerfil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ConexionBD.dart';
import 'VentanaMensajesChat.dart';
import 'package:share_plus/share_plus.dart';


Usuario user = new Usuario();
Producto product = new Producto();
class VentanaProducto extends StatelessWidget {
  const VentanaProducto({super.key, required this.connected, required this.producto});

  final Usuario connected;
  final Producto producto;

  @override
  Widget build(BuildContext context) {
    user = connected;
    product = producto;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(producto.nombre as String),
      ),
      //Columna con la imagen, abajo el precio, abajo una fila con un boton para añadir a la lista de deseos y otro para comenzar chat con el vendedor
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.memory(const Base64Decoder().convert(producto!.image.toString()), fit: BoxFit.fill, width: 200, height: 200,),
          Text("${producto.precio} €", style: const TextStyle(fontSize: 20, color: Colors.deepPurple),),
          ElevatedButton(onPressed:
              () {
            Conexion().getUsuarioByID(producto!.usuarioID!).then((value)
            {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VentanaPerfil(mUser: user, rUser: value,)),
              );
            }
            );
          },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Image(image: AssetImage("lib/assets/productos/pikachu.png"), width: 50, height: 50,),
                Text(producto.usuarioID.toString()),
              ],
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  //Conexion().addProductoListaDeseos(producto.productoID!, user.usuarioID!);
                },
                child: const Icon(Icons.favorite),
              ),
              ElevatedButton(
                onPressed: () {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final String textoCompartir = '¡Echa un vistazo a este objeto en venta!\nhttps://collectify.es/${product.productoID}';
                  Share.share(textoCompartir,
                      subject: 'Enlace del objeto en ventana',
                      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
                },
                child: const Icon(Icons.share),
              ),
              ChatButton(producto: producto)
            ],
          ),
        ],
      ),
    );
  }
}

class ChatButton extends StatelessWidget {
  final Producto producto;
  const ChatButton({Key? key, required this.producto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(producto.usuarioID == user.usuarioID) return const SizedBox.shrink();
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VentanaMensajesChat(producto.usuarioID!, user.usuarioID!)),
        );
      },
      child: const Icon(Icons.chat),
    );
  }
}