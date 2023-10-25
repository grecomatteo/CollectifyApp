import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';


void main() {
  runApp(VentanaSubasta());
}

class VentanaSubasta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collectify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: VentanaSubastaScreen(),
    );
  }
}

class VentanaSubastaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Lista de objetos en subasta'),
      ),
      body: SubastasForm(),
    );
  }
}

class SubastasForm extends StatefulWidget {
  @override
  _SubastasFormState createState() => _SubastasFormState();
}

class _SubastasFormState extends State<SubastasForm> {
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
                nombre: e.nombre, precio: e.precio, imagePath: e.imagePath, esPremium: e.esPremium, e ))
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
  final bool? esPremium;
  final DateTime? fechaFin;

  const ProductoWidget({super.key, this.nombre, this.precio, this.imagePath, this.esPremium, this.fechaFin});

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
                          if(esPremium == true)
                            const Row(
                              children: [
                                Icon(Icons.star, color: Colors.yellow,),
                                Text("Premium", style: TextStyle(color: Colors.yellow),),
                              ],
                            ),
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
                          Text(Temporizador()),
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

String Temporizador(){
  return "21:23:12";
}