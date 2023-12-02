import 'dart:convert';
import 'package:collectify/VentanaPerfil.dart';
import 'package:flutter/material.dart';
import 'ConexionBD.dart';
import 'VentanaMensajesChat.dart';
import 'package:share_plus/share_plus.dart';


Usuario user = Usuario();
String? userUltPuja;
Producto product = Producto();
class VentanaProducto extends StatelessWidget {
  const VentanaProducto({super.key, required this.connected, required this.producto});

  final Usuario connected;
  final Producto producto;

  @override
  Widget build(BuildContext context) {
    user = connected;
    product = producto;
    if(product.idUserUltimaPuja != null) {
      Conexion().getUsuarioByID(product.idUserUltimaPuja).then((results) {
         userUltPuja = results?.nick;
      });
    }
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
          Image.memory(const Base64Decoder().convert(producto.image.toString()), fit: BoxFit.fill, width: 200, height: 200,),
          const Text("Descripción", style: TextStyle(fontSize: 30, color: Colors.deepPurple),),
          Text("${producto.descripcion}.", style: const TextStyle(fontSize: 15, color: Colors.blueGrey),),
          if(producto.esSubasta == true)
            Column(
              children: [
                  Text("Precio inicial : ${producto.precioInicial} €", style: const TextStyle(fontSize: 20, color: Colors.deepPurple),),
                  if(producto.idUserUltimaPuja != null)
                    Text("Última puja : ${producto.ultimaOferta} € realizada por $userUltPuja",
                      style: const TextStyle(fontSize: 15, color: Colors.blueGrey),)
                  else const Text("Nadie ha pujado todavía", style: TextStyle(fontSize: 15, color: Colors.blueGrey),),
              ],
            )
          else Text("${producto.precio} €", style: const TextStyle(fontSize: 20, color: Colors.deepPurple),),

          ElevatedButton(onPressed:
              () {
            Conexion().getUsuarioByID(producto.usuarioID!).then((value)
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
          Row(
            children: [
              if(producto.esSubasta == false)
                ElevatedButton(
                  onPressed:(){
                    //abrir ventana de compra
                    showDialog(
                        context: context,
                        builder: (buildcontext) {
                          return AlertDialog(
                            contentPadding: const EdgeInsets.all(8.0),
                            title: const Text("¡Error!",
                                style: TextStyle(color: Colors.red)),
                            content: const Text("tt esperate que esto aun no esta implementao"),
                            actions: <Widget>[
                              ElevatedButton(
                                  child: const Text("volver pa tras", style: TextStyle(color: Colors.black),
                                  ),
                                  onPressed: () {Navigator.of(buildcontext).pop();
                                  })
                            ],
                          );
                        });
                  },
                  child: const Text("Comprar"))
              else
                if(user.usuarioID != producto.usuarioID)
                ElevatedButton(
                    onPressed:() async {
                      await Conexion().addUltimaPuja(producto.productoID!, user.usuarioID!, product.ultimaOferta!+5 );
                      showDialog(
                          context: context,
                          builder: (buildcontext) {
                            return AlertDialog(
                              contentPadding: const EdgeInsets.all(8.0),
                              title: const Text("¡Enhorabuena!",
                                  style: TextStyle(color: Colors.red)),
                              content: const Text("Has pujado por este producto."),
                              actions: <Widget>[
                                ElevatedButton(
                                    child: const Text("Ok", style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {Navigator.of(buildcontext).pop();
                                    })
                              ],
                            );
                          });
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => VentanaProducto(connected: user, producto: producto)),);
                      },
                    child: const Text("Pujar"))
                else const Text("Este producto es tuyo por tanto no puedes pujar por el.", style: TextStyle(fontSize: 15, color: Colors.black),),
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
          MaterialPageRoute(builder: (context) => VentanaMensajesChat(producto.usuarioID!, user.usuarioID!, null)),
        );
      },
      child: const Icon(Icons.chat),
    );
  }
}