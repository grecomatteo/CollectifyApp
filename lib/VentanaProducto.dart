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
    Producto product = producto;
    product = producto;
    if(product.idUserUltimaPuja != null) {
      Conexion().getUsuarioByID(product.idUserUltimaPuja).then((results) {
         userUltPuja = results?.nick;
      });
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          Container(
            height: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: MemoryImage(
                  const Base64Decoder().convert(producto.image.toString()),
                ),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              )
            ),
          ),

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
                  final String textoCompartir = '¡Echa un vistazo a este objeto en venta!\nhttps://collectify.es/${product.productoID}';
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
                        content: const Text("tt esperate que esto aun no esta implementao"),
                        actions: <Widget>[
                          ElevatedButton(
                            child: const Text("volver pa tras", style: TextStyle(color: Colors.black),
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
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Align(
                alignment: Alignment(
                  0,
                  (MediaQuery.of(context).size.width * 0.75 + 40) /
                      MediaQuery.of(context).size.height,
                ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                if(producto.esSubasta == true)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                                "${producto.nombre}",
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontFamily: "Aeonik",
                                  color: Colors.white,
                                ),
                              ),
                        ],
                      ),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Text(
                            "${producto.categoria} ",
                            style: const TextStyle(
                                fontSize: 15,
                                fontFamily: "Aeonik",
                                color: Colors.white24,
                            ),
                          ),
                      ],
                     ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    if(producto.esSubasta == true)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                            Text(
                              "Precio inicial : ${producto.precioInicial} €",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontFamily: "Aeonik",
                                  color: Colors.lightGreenAccent
                              ),
                            ),
                            if(producto.idUserUltimaPuja != null)
                              Text(
                                "Última puja : ${producto.ultimaOferta} € realizada por $userUltPuja",
                                style: const TextStyle(fontSize: 15, color: Colors.blueGrey),
                              )
                            else const Text(
                                "Nadie ha pujado todavía",
                                style: TextStyle(fontSize: 15, color: Colors.blueGrey),
                              ),
                        ],
                      )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${producto.nombre}",
                        style: const TextStyle(
                          fontSize: 25,
                          fontFamily: "Aeonik",
                          color: Colors.white,
                        ),
                      ),
                      Container(width:80),
                      Text(
                        "${producto.precio} €",
                        style: const TextStyle(
                                      fontSize: 30,
                                      fontFamily: "Aeonik",
                                      color: Colors.lightGreenAccent
                                  ),
                        ),
                    ],
                  ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${producto.categoria}",
                          style: const TextStyle(
                            fontSize: 17,
                            fontFamily: "Aeonik",
                            color: Colors.white24,
                          ),
                        ),
                      ],
                    ),

                  ElevatedButton(
                    onPressed:() {
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:  [
                        const Icon(
                            Icons.account_circle,
                            size: 50,
                          color: Colors.grey,
                        ),
                        const Spacer(),
                        Text(producto.usuarioNick.toString(),style: TextStyle(
                            fontFamily: "Aeonik",
                            color: Colors.white,
                          ),
                        ),
                        const Spacer( flex: 5,)
                      ],
                    ),
                  ),
                ],
              ),
            ]),
            ),
          ],
          ),




          Positioned(
            bottom: 20,
            left: 20,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 150,
                height: 50,
                child: ChatButton(producto: producto),
              ),
            ),
          ),

          if (producto.esSubasta==false)
            Positioned(
              bottom: 20,
              right: 20,
              child: Padding(
              padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 160,
                  height: 50,
                  child: ElevatedButton(
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
                                    }
                                ),


                                  if(producto.esSubasta==true && user.usuarioID != producto.usuarioID)
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
                                      else
                                        const Text("Este producto es tuyo por tanto no puedes pujar por el.", style: TextStyle(fontSize: 15, color: Colors.black),),
                              ],
                            );
                          });
                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    child: const Text("Comprar",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Aeonik",
                          color: Colors.black,
                      ),
                    )
                  )
                )
              )
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
          MaterialPageRoute(builder: (context) => VentanaMensajesChat(user.usuarioID!, producto.usuarioID!)),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white12,
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Text("Contactar", style:
            TextStyle(
              fontSize:20,
              fontFamily: "Aeonik",
              color: Colors.lightGreenAccent,
            )
          ),
        ],
      ),
    );
  }
}