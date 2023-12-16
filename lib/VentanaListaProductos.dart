import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';

import 'VentanaAnadirProducto.dart';
import 'VentanaChat.dart';
import 'package:collectify/ConexionBD.dart';

import 'VentanaPerfil.dart';
import 'VentanaProducto.dart';
import 'dart:io';

import 'VentanaProductosSubasta.dart';

Usuario user = Usuario();
bool isValid = true;
bool loading = false;

//Labelers para imageenes
ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.76);
ImageLabeler imageLabeler = ImageLabeler(options: options);
//Traductor para las labels generadas
TranslateLanguage sourceLanguage = TranslateLanguage.english;
TranslateLanguage targetLanguage = TranslateLanguage.spanish;

final onDeviceTranslator = OnDeviceTranslator(
    sourceLanguage: sourceLanguage, targetLanguage: targetLanguage);

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
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: Container(
          color: Colors.black,
          child: Column(
            children: [
              //SizedBox(height: 20),
              SearchBar(onSearchResults: (results) {
                setState(() {
                  _searchResults = results;
                });
                if (results.isEmpty) {
                  cargarProductos();
                }
              }),
              const SizedBox(height: 15),
              Expanded(
                child: ProductList(searchResults: _searchResults),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
              decoration: const BoxDecoration(
                color: Color(0XFF343434),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: const NavigationBar(),
            )));
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
  final List<String> categories = [
    "Joyas y relojes",
    "Numismatica",
    "Arte y artesanía",
    "Juguetes",
    "Libros y comics",
    "Monedas",
    "Música",
    "Postales y sellos",
    "Ropa"
  ];

  String selectedCategory = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 20.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0XFF161616),
              borderRadius: BorderRadius.all(Radius.circular(30)),
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
                _handleSearch(_controller.text);
                setState(() {
                  loading = true;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                  fontFamily: 'Aeonik',
                ),
                border: InputBorder.none,
                suffixIcon: PopupMenuButton<int>(
                  icon: const Icon(Icons.camera_alt, color: Colors.grey),
                  onSelected: (int result) async {
                    ImagePicker picker = ImagePicker();
                    if (result == 1) {
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);
                      File file = File(image!.path);
                      await imageLabeler
                          .processImage(InputImage.fromFile(file))
                          .then((value) async {
                        if (value.isNotEmpty) {
                          _controller.text = await onDeviceTranslator
                              .translateText(value[0].label);
                          setState(() {
                            loading = true;
                          });
                          _handleSearch(_controller.text);
                        } else {
                          showError(context);
                        }
                      });
                    } else {
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      File file = File(image!.path);
                      await imageLabeler
                          .processImage(InputImage.fromFile(file))
                          .then((value) async {
                        if (value.isNotEmpty) {
                          _controller.text = await onDeviceTranslator
                              .translateText(value[0].label);
                          setState(() {
                            loading = true;
                          });
                          _handleSearch(_controller.text);
                        } else {
                          showError(context);
                        }
                      });
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 1,
                      child: Text(
                        "Tomar foto",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontFamily: 'Aeonik',
                        ),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Text(
                        "Seleccionar foto",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontFamily: 'Aeonik',
                        ),
                      ),
                    ),
                  ],
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          //padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 15.0),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: ElevatedButton(
                  onPressed: () {
                    toggleCategory(category);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 14.0),
                    backgroundColor: selectedCategory == category
                        ? Color(0XFFFE6F1F)
                        : Color(0XFF343434),
                    foregroundColor: selectedCategory == category
                        ? Colors.black // Colore del testo quando è premuto
                        : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Aeonik',
                    ),
                  ),
                ),
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
    if (query.isEmpty && category == null) {
      searchResults = await Conexion().getProductosBasadoPreferencias(user);
      setState(() {
        loading = false;
      });
    } else if (query.isEmpty && category != null) {
      searchResults = await Conexion().getProductoPorCategoria(category);
      setState(() {
        loading = false;
      });
    } else {
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

  void toggleCategory(String category) {
    setState(() {
      if (selectedCategory == category) {
        selectedCategory = ""; // deselecciona el tag
      } else {
        selectedCategory = category; // selecciona el tag
      }
    });
    _handleSearch(_controller.text, category: selectedCategory);
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
              mainAxisSpacing: 5,
              crossAxisSpacing: 0,
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
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
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
      child: Column(
        children: [
          const Spacer(),
          Flexible(
              flex: 100,
              child: Container(
                height: 200,
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
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                      child:const Icon(Icons.favorite_border,
                          color: Colors.white),
                    ),

                  ],
                ),
              )),
          //const Spacer(),
          const SizedBox(height: 7),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    producto.nombre!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: 'Aeonik'),
                  ),
                  Text(
                    "${producto.categoria}",
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13, fontFamily: 'Aeonik'),
                  ),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text("${producto.precio} €",
                      style: const TextStyle(
                        color: Color(0XFFB3FF77),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Aeonik',
                        overflow: TextOverflow.ellipsis,
                      )),
                ]),
              ]),
          const Spacer(),
        ],
      ),
    );
  }
}

class NavigationBar extends StatelessWidget {
  const NavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.transparent,
      selectedItemColor: Color(0XFFB3FF77),
      unselectedItemColor: Colors.grey,
      selectedIconTheme: const IconThemeData(size: 30),
      onTap: (int index) {
        switch (index) {
          case 0:
            //Se queda en la misma ventana
            break;
          case 1: //Articulos con me gusta, por implementar
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ListaProductosSubasta(connected: user)),
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
      items: const[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: "Inicio",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.gavel_rounded),
          label: "Subastas",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_outlined),
          label: "Añadir",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_rounded),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: "Perfil",
        ),
      ],
    );
  }
}

Future<String> getLabelFromXFile(XFile? image) async {
  File file = File(image!.path);
  debugPrint('\n' + " 1 " + file.path);
  String label = "";
  await imageLabeler.processImage(InputImage.fromFile(file)).then((value) {
    if (value.isNotEmpty) {
      debugPrint('\n' + "2 " + value[0].label);
      onDeviceTranslator.translateText(value[0].label).then((value) {
        if (value.isNotEmpty) {
          debugPrint('\n' + " 3" + value);
          label = value;
          debugPrint('\n' + " 4" + label);
          return value;
        }
      });
    }
  });
  return label;
}

void showError(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: const Text("No se ha podido reconocer el objeto"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"))
          ],
        );
      });
}
