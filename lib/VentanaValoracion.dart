import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ConexionBD.dart';
import 'VentanaMensajesChat.dart';
import 'package:share_plus/share_plus.dart';


Usuario user = new Usuario();
Producto product = new Producto();
class VentanaValoracion extends StatelessWidget {
  const VentanaValoracion({super.key, required this.connected, required this.producto});

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
      bottomNavigationBar: const NavigationBar(),
      //Columna con la imagen, abajo el precio, abajo una fila con un boton para añadir a la lista de deseos y otro para comenzar chat con el vendedor, abajo la lista de valoraciones
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.memory(const Base64Decoder().convert(producto!.image.toString()), fit: BoxFit.fill, width: 200, height: 200,),
          Text("${producto.precio} €", style: const TextStyle(fontSize: 20, color: Colors.deepPurple),),
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
                  final String textoCompartir = '¡Echa un vistazo a este objeto en venta!';
                  Share.share(textoCompartir,
                      subject: 'Enlace del objeto en venta',
                      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
                },
                child: const Icon(Icons.share),
              ),
              ChatButton(producto: producto)
            ],
          ),
          const Text("Valoraciones", style: TextStyle(fontSize: 20, color: Colors.deepPurple),),
          ProductValoracion(),
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

class ProductValoracion extends StatefulWidget {
  const ProductValoracion({Key? key}) : super(key: key);

  @override
  State<ProductValoracion> createState() => _ProductValoracionState();
}

class _ProductValoracionState extends State<ProductValoracion> {
  static late StreamController<List<Valoracion>> _streamController = StreamController<List<Valoracion>>.broadcast();

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<List<Valoracion>>.broadcast();
    refresh();
  }

  static void refresh() async {
    List<Valoracion> valoraciones = await Conexion().getValoraciones(product.productoID!);
    _streamController.add(valoraciones);
  }

  @override
  Widget build(BuildContext context) {
    refresh();
    return StreamBuilder(
        stream: _streamController.stream,
        builder: (BuildContext context, AsyncSnapshot<List<Valoracion>> snapshot) {
      if (snapshot.hasData) {
        print(snapshot.data!.length);
        if(snapshot.data!.isEmpty){
          return const Center(
            child: Text("No hay valoraciones"),
          );
        }
        return Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data?.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: ListTile(
                  title: Text(snapshot.data![index].nickUsuario as String),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(snapshot.data![index].comentario as String),
                      Row(
                        children: [
                          for(int i = 0; i < snapshot.data![index].valoracion!; i++)
                            const Icon(Icons.star, color: Colors.orangeAccent,),
                          for(int i = 0; i < 5 - snapshot.data![index].valoracion!; i++)
                            const Icon(Icons.star_border, color: Colors.orangeAccent,),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    });
  }
}


class NavigationBar extends StatefulWidget {
  const NavigationBar({Key? key}) : super(key: key);

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  Future<void> sendMessage(int productID) async {
    Conexion().anadirValoracion(productID, user.usuarioID!, toSendMessage, valoracion);
    valoracion = 0;

    //Refresh ProductValoracion
    _ProductValoracionState.refresh();
  }

  final textField = TextEditingController();
  String toSendMessage = "";
  int valoracion = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      //Make height of NavigationBar the same as the height of the keyboard
      height: MediaQuery
          .of(context)
          .viewInsets
          .bottom + 70 + 46,
      alignment: Alignment.bottomCenter,
      color: Colors.grey[200],
      child: Column(
          children: [
            Row(
              children: [
                for(int i = 0; i < valoracion; i++)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        valoracion = i + 1;
                      });
                    },
                    icon: const Icon(Icons.star, color: Colors
                        .orangeAccent,),
                  ),
                for(int i = valoracion; i < 5; i++)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        valoracion = i + 1;
                      });
                    },
                    icon: const Icon(Icons.star_border, color: Colors
                        .orangeAccent,),
                  ),
              ],
            ),
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child:
              Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Type a comment",
                        border: InputBorder.none,
                      ),
                      onChanged: (text) {
                        toSendMessage = text;
                      },
                      controller: textField,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      if (toSendMessage
                          .replaceAll(' ', '')
                          .isEmpty) return;

                      if(valoracion == 0) return;
                      //send message, clear text field, scroll to the bottom, close keyboard and refresh the page
                      setState(() {
                        sendMessage(product.productoID!);
                      });
                      //empty the text field
                      textField.clear();
                      toSendMessage = "";
                      FocusScope.of(context).unfocus();
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}