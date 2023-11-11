import 'package:flutter/material.dart';

import 'ConexionBD.dart';

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
      body: const ProductValoracion(),

    );
  }
}

class ProductValoracion extends StatefulWidget {
  const ProductValoracion({super.key});

  @override
  State<StatefulWidget> createState() {
    return ProductValoracionState();
  }
}

class ProductValoracionState extends State<ProductValoracion> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Conexion().getValoraciones(product.productoID!),
      builder: (BuildContext context, AsyncSnapshot<List<Valoracion>> snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data!.length);
          if(snapshot.data!.isEmpty){
            return const Center(
              child: Text("No hay valoraciones"),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: ListTile(
                  title: Text(snapshot.data?[index].comentario as String),
                  subtitle: Row(
                    children: [
                      for(int i = 0; i < snapshot.data![index].valoracion!; i++)
                        const Icon(Icons.star, color: Colors.orangeAccent,),
                      for(int i = 0; i < 5 - snapshot.data![index].valoracion!; i++)
                        const Icon(Icons.star_border, color: Colors.orangeAccent,),
                    ],
                  ),
                ),
              );
            },
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