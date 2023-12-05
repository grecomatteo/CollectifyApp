import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

import 'VentanaAnadirProducto.dart';
import 'VentanaChat.dart';
import 'package:collectify/ConexionBD.dart';

import 'VentanaEventos.dart';
import 'VentanaPerfil.dart';
import 'VentanaProducto.dart';
import 'dart:io';

Usuario user = Usuario();
bool isValid = true;
bool loading = false;
ImageLabelerOptions options =  ImageLabelerOptions(confidenceThreshold: 0.75);
ImageLabeler imageLabeler = ImageLabeler(options: options);

class ListaProductos extends StatefulWidget {
  const ListaProductos({Key? key, required this.connected}) : super(key: key);


  final Usuario connected;

  @override
  _ListaProductosState createState() =>
      _ListaProductosState(connected: connected);
}

class _ListaProductosState extends State<ListaProductos> {
  _ListaProductosState({required this.connected});

  final Usuario connected;

  List<Producto> _searchResults = [];

  @override
  void initState() {
    super.initState();

    // Inicializa _searchResults con todos los productos al momento de la creación del estado
    cargarProductos();
  }

  Future<void> cargarProductos() async {
    List<Producto> allProducts =
    await Conexion().getProductosBasadoPreferencias(user);

    setState(() {
      _searchResults = allProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    user = connected;
    return Scaffold(

      body: Column(

        children: [

            SearchBar(onSearchResults: (results) {
              setState(() {
                _searchResults = results;
              });
            }),

          Expanded(
            child: ProductList(searchResults: _searchResults),
          ),
        ],
      ),
      bottomNavigationBar: const NavigationBar(),
    );
  }
}

class SearchBar extends StatefulWidget {
  final Function(List<Producto>) onSearchResults;

  const SearchBar({Key? key, required this.onSearchResults}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();
  final List<String> categories = ["Relojes", "Arte", "Joyeria", "Numismatica"];

  String selectedCategory = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 4.0,
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              onChanged: (query) {
                if (query.isEmpty) {
                  _handleSearch(_controller.text);
                  setState(() {
                    loading = true;
                  });
                }
              },
              onSubmitted: (query) {
                setState(() {
                  loading = true;
                });
                _handleSearch(_controller.text);},

              decoration: InputDecoration(
                hintText: 'Buscar',
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.camera_alt_rounded),
                  onPressed: () async {

                        ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.camera);
                        //Transforma el XFile en un File
                        File file = File(image!.path);
                        await imageLabeler.processImage(InputImage.fromFile(file)).then((value){
                          if(value.isEmpty){
                            //error
                          }
                          else {
                            _controller.text = value[0].label;
                            setState(() {
                              loading = true;
                            });
                            _handleSearch(_controller.text);
                          }
                        });
                        //Hacer como si se pulsar la tecla enter





                  },
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = category;
                  });
                  _handleSearch(_controller.text, category: selectedCategory);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedCategory == category
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                  foregroundColor: selectedCategory == category
                      ? Theme.of(context).colorScheme.onSurface // Colore del testo quando è premuto
                      : Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                child: Text(category),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }


  void _handleSearch(String query, {String? category}) async {
    List<Producto> searchResults;

    //Antes de consultar la base de datos, verifique si no se ha ingresado nada en el campo de búsqueda
    if (query.isEmpty && category== null) {
      searchResults = await Conexion().getProductosBasadoPreferencias(user);
      setState(() {
        loading = false;
      });
    } else if(query.isEmpty && category != null){
      searchResults = await Conexion().getProductoPorCategoria(category);
      setState(() {
        loading = false;
      });
    }
    else {
      //Mostrar un widget de cargando

      // Llama a la lógica de búsqueda de la base de datos usando la clase Conexion
      searchResults = await Conexion().searchProductos(query);
      setState(() {

        loading = false;
      });
    }

    // Pasa los resultados de la búsqueda a la función onSearchResults proporcionada como parámetro
    widget.onSearchResults(searchResults);
  }
}



class ProductList extends StatefulWidget {
  const ProductList({Key? key, this.searchResults = const []})
      : super(key: key);
  final List<Producto> searchResults;

  @override
  ProductListState createState() => ProductListState();
}

class ProductListState extends State<ProductList> {
  List<Producto> _displayedProducts = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Conexion().getProductosBasadoPreferencias(user),
      builder: (BuildContext context, AsyncSnapshot<List<Producto>> snapshot) {
        if (loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          _displayedProducts = widget.searchResults.isNotEmpty
              ? widget.searchResults
              : snapshot.data!;

          if (isValid == false) {
            isValid = true;
            return const Center(
              child: Text(
                  'La búsqueda no es válida. Ingrese un término de búsqueda válido.'),
            );
          } else if (widget.searchResults.isEmpty) {
            return const Center(
              child: Text('No hay ningún producto con ese nombre'),
            );
          } else {
            return GridView.count(
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              padding: const EdgeInsets.all(10),
              crossAxisCount: 2,
              children: _displayedProducts
                  .map((e) => ProductoWidget(producto: e))
                  .toList(),
            );
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
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
            MaterialPageRoute(
                builder: (context) =>
                    VentanaProducto(connected: user, producto: producto)),
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
                        image: Image.memory(const Base64Decoder()
                                .convert(producto.image.toString()))
                            .image,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (producto.esPremium == true)
                    const Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        Text(
                          "Premium",
                          style: TextStyle(color: Colors.yellow),
                        ),
                      ],
                    ),
                  Text(
                    producto.nombre!,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 50, 50, 50),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${producto.precio} €",
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]),
                const Spacer(),
                const Icon(Icons.favorite_border_outlined),
              ]),
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
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VentanaEventos()),
          );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VentanaAnadirProducto(user: user)),
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
              MaterialPageRoute(
                  builder: (context) => VentanaPerfil(
                        mUser: user,
                        rUser: user,
                      )),
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
