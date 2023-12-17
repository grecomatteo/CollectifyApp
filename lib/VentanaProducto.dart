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
  const VentanaProducto(
      {super.key, required this.connected, required this.producto});

  final Usuario connected;
  final Producto producto;
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Detalles'),
    Tab(text: 'Estado'),
    Tab(text: 'Relacionados '),
  ];

  @override
  Widget build(BuildContext context) {
    user = connected;

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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Align(
                alignment: Alignment(
                  0,
                  (MediaQuery.of(context).size.width * 0.75 + 40) /
                      MediaQuery.of(context).size.height,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                          child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${producto.nombre}",
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontFamily: "Aeonik",
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "${producto.categoria}",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontFamily: "Aeonik",
                                      color: Colors.white24,
                                    ),
                                  ),
                                ]),
                            Text(
                              "${producto.precio} €",
                              style: const TextStyle(
                                  fontSize: 30,
                                  fontFamily: "Aeonik",
                                  color: Colors.lightGreenAccent),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Conexion()
                              .getUsuarioByID(producto.usuarioID!)
                              .then((value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VentanaPerfil(
                                        mUser: user,
                                        rUser: value,
                                      )),
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(
                              MediaQuery.of(context).size.width * 0.95, 65),
                          backgroundColor:
                              const Color.fromARGB(190, 52, 52, 52),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.account_circle,
                              size: 50,
                              color: Color.fromARGB(255, 179, 255, 119),
                            ),
                            Text(
                              producto.usuarioNick.toString(),
                              style: const TextStyle(
                                fontFamily: "Aeonik",
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 72, 72, 72)),
                              child: const Text(
                                "Seguir",
                                style: TextStyle(
                                    fontFamily: "Aeonik",
                                    color: Color.fromARGB(255, 179, 255, 119)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: DefaultTabController(
                              length: 3,
                              child: Scaffold(
                                backgroundColor: Colors.black,
                                appBar: PreferredSize(
                                  preferredSize: const Size.fromHeight(50),
                                  child: AppBar(
                                      backgroundColor: Colors.black,
                                      automaticallyImplyLeading: false,
                                      bottom: const TabBar(
                                        labelColor: Colors.white,
                                        indicatorColor:
                                            Color.fromARGB(255, 179, 255, 119),
                                        tabs: myTabs,
                                      )),
                                ),
                                body: TabBarView(
                                  children: [
                                    Tab(
                                        child: SingleChildScrollView(
                                      child: Text(
                                        "${producto.descripcion}",
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontFamily: "Aeonik",
                                          color: Colors.white,
                                        ),
                                      ),
                                    )),
                                    const Tab(
                                        child: Text(
                                      "Aqui van los detalles",
                                      style: TextStyle(color: Colors.white),
                                    )),
                                    const Tab(
                                        child: Text(
                                      "Aqui van productos relacionados",
                                      style: TextStyle(color: Colors.white),
                                    ))
                                  ],
                                ),
                              ),
                            )),
                      ),
                    ]),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.1,
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VentanaMensajesChat(
                                    user.usuarioID!, producto.usuarioID!)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(
                              MediaQuery.of(context).size.width * 0.42, 60),
                          backgroundColor:
                              const Color.fromARGB(255, 52, 52, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        ),
                        child: const Text(
                          "Contactar",
                          style: TextStyle(
                            fontFamily: "Aeonik",
                            color: Color.fromARGB(255, 179, 255, 119),
                          ),
                        )),
                    const Spacer(flex: 2),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(MediaQuery.of(context).size.width * 0.42, 60),
                        backgroundColor:
                            const Color.fromARGB(255, 254, 111, 31),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                      child: const Text(
                        "Comprar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
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
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
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
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
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
