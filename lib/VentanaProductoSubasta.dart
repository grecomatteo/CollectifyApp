import 'dart:convert';
import 'package:flutter/material.dart';
import 'ConexionBD.dart';
import 'package:share_plus/share_plus.dart';

import 'VentanaMensajesChat.dart';

Usuario user = Usuario();
String? userUltPuja;
Producto productoF = Producto();
TextEditingController _controller = TextEditingController();

class VentanaProductoSubasta extends StatefulWidget {
  const VentanaProductoSubasta(
      {super.key, required this.connected, required this.producto});

  final Usuario connected;
  final Producto producto;



  @override
  State<StatefulWidget> createState() => VentanaProductoSubastaState( connected: connected, producto: producto);
}
class VentanaProductoSubastaState extends State<VentanaProductoSubasta>{

  VentanaProductoSubastaState({ required this.connected, required this.producto});

  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Detalles'),
    Tab(text: 'Estado'),
    Tab(text: 'Relacionados '),
  ];

  Usuario connected;
  Producto producto;
  @override
  Widget build(BuildContext context)  {
    productoF = producto;
    return FutureBuilder(
        future: Conexion().getSubastaById(producto.productoID!),
        builder: (BuildContext context, AsyncSnapshot<Producto> snapshot){
          if(snapshot.hasData){
            producto = snapshot.data!;
            return Scaffold(
              backgroundColor: Colors.black,
              body: Stack(children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.40,
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
                  children: [
                    Spacer(),
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
                              Column(
                                children: [
                                  const Text("Ultima puja", style: TextStyle(color: Colors.white)),
                                  Text(
                                    "${producto.ultimaOferta} €",
                                    style: const TextStyle(
                                        fontSize: 30,
                                        fontFamily: "Aeonik",
                                        color: Colors.lightGreenAccent),
                                  ),
                                  Text(
                                      "${producto.nombreUsuarioUltimaPuja}"
                                  ),
                                ],
                              )
                            ],
                          ),
                        )),
                    Center(
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.27,
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
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),

                        hintText: 'Introduce tu puja',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                    ),


                    Center(
                      child: SizedBox(
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
                                            connected.usuarioID!, producto.usuarioID!)),
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
                              onPressed: () async {
                                try{
                                  int ultimaPuja = _controller.text.isEmpty ? 0 : int.parse(_controller.text);
                                }
                                catch(e){
                                  print(e.toString() + "error");
                                }


                                  await Conexion().addUltimaPuja(producto.productoID!, connected.usuarioID!, connected.nick!, 100);
                                  showDialog(
                                    context: context,
                                    builder: (buildcontext) {
                                      return AlertDialog(
                                        contentPadding: const EdgeInsets.all(8.0),
                                        title: const Text("¡Puja realizada!"),
                                        content: const Text("Tu puja se ha realizado correctamente"),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            child: const Text(
                                              "Ok",
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
                                "Pujar",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ]),
            );
          }
          else {
            return const Center(child: CircularProgressIndicator());
          }

    });
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
                '¡Echa un vistazo a este objeto en venta!\nhttps://collectify.es/${productoF.productoID}';
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
