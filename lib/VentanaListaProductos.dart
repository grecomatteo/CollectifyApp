import 'package:flutter/material.dart';

import 'VentanaAnadirProducto.dart';
import 'VentanaChat.dart';
import 'package:collectify/ConexionBD.dart';

class ListaProductos extends StatelessWidget {
  ListaProductos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Collectify"),
      ),
      body: ProductList(),
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
  String? nombre;
  double? precio;
  String? imagePath;

  ProductoWidget({super.key, this.nombre, this.precio, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {},
        child: Center(
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.all(70),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),

              ),

              Text(nombre!),
              Text(precio.toString() + " €"),
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
        BottomNavigationBarItem(icon: Icon(Icons.chat_rounded), label: "chat"),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}
