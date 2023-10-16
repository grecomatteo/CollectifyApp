import 'package:flutter/material.dart';

import 'VentanaAnadirProducto.dart';
import 'VentanaChat.dart';
import 'package:collectify/ConexionBD.dart';

class ListaProductos extends StatelessWidget {
  const ListaProductos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Collectify"),
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
      future: Conexion().getProductos(),
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
                    nombre: e.nombre, precio: e.precio, imagePath: e.imagePath))
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
  final String? nombre;
  final double? precio;
  final String? imagePath;

  const ProductoWidget({super.key, this.nombre, this.precio, this.imagePath});

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
                        image: Image.asset(imagePath!).image,
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
                      Text(nombre!,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 50, 50, 50),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                      Text(
                        "$precio €",
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
              MaterialPageRoute(builder: (context) => const AnadirProducto()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VentanaChat()),
            );
            break;
          case 4: //Perfil, por implementar
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
