import 'dart:convert';
import 'package:flutter/material.dart';

import 'VentanaAnadirProducto.dart';
import 'VentanaChat.dart';
import 'package:collectify/ConexionBD.dart';

import 'VentanaPerfil.dart';
import 'VentanaProductosSubasta.dart';
import 'VentanaValoracion.dart';

Usuario user = new Usuario();
class ListaProductos extends StatelessWidget {
  const ListaProductos({super.key, required this.connected});

  final Usuario connected;

  @override
  Widget build(BuildContext context) {
    user = connected;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Collectify"),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VentanaSubasta()),

            );
          }, icon: Icon(Icons.gavel)),
        ],

      ),
      body: const ProductList(),
      bottomNavigationBar: const NavigationBar(),

    );
  }
}

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<StatefulWidget> createState() {
    return ProductListState();
  }
}

class ProductListState extends State<ProductList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Conexion().getProductosBasadoPreferencias(user),
      builder: (BuildContext context, AsyncSnapshot<List<Producto>> snapshot) {
        if (snapshot.hasData) {
          return GridView.count(
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            padding: const EdgeInsets.all(10),
            crossAxisCount: 2,
            children: snapshot.data!
                .map((e) => ProductoWidget(producto: e))
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
  final Producto producto;

  const ProductoWidget({super.key, required this.producto});

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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VentanaValoracion(connected: user, producto: producto)),
          );
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
                        image: Image.memory(const Base64Decoder().convert(producto!.image.toString())).image,
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
                          if(producto?.esPremium == true)
                            const Row(
                              children: [
                                Icon(Icons.star, color: Colors.yellow,),
                                Text("Premium", style: TextStyle(color: Colors.yellow),),
                              ],
                            ),
                          Text(producto.nombre!,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 50, 50, 50),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            "${producto?.precio} €",
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
  }
}

class NavigationBar extends StatelessWidget {
  const NavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.purpleAccent,
      onTap: (int index) {
        switch (index) {
          case 0:
            //Se queda en la misma ventana
            break;
          case 1: //Articulos con me gusta, por implementar
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VentanaAnadirProducto(user: user)),
            );
            break;
          case 3:
            int uid = user.usuarioID ?? -1;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VentanaChat(id: uid)),
            );
            break;
          case 4:
            Navigator.push(
              context,

              MaterialPageRoute(builder: (context) => VentanaPerfil(user: user)),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "productos",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle),
          label: "Search",
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded),
            label: "chat",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}
