import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';

import 'VentanaAnadirProducto.dart';
import 'VentanaAnadirSubasta.dart';
import 'VentanaChat.dart';
import 'package:collectify/ConexionBD.dart';

import 'VentanaPerfil.dart';
import 'VentanaProducto.dart';
import 'dart:io';

import 'VentanaProductosSubasta.dart';

Usuario user = Usuario();
bool isValid = true;
bool loading = false;
Evento evento = Evento();
//Hazme un map con los numeros del mes y su nombre acordado
Map<int, String> meses = {
  1: "Ene",
  2: "Feb",
  3: "Mar",
  4: "Abr",
  5: "May",
  6: "Jun",
  7: "Jul",
  8: "Ago",
  9: "Sep",
  10: "Oct",
  11: "Nov",
  12: "Dic"
};

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
    evento = await Conexion().getRandomEvento();
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
          color: Color(0XFF161616),
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
              Expanded(
                child: ProductList(searchResults: _searchResults),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical:0.0),
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
    "Arte y artesanía",
    "Juguetes",
    "Libros y comics",
    "Monedas y billetes",
    "Música",
    "Sellos y postales",
    "Moda",
    "Vehículos",
  ];

  String selectedCategory = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 20.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0XFF343434),
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: TextField(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontFamily: 'Aeonik',
              ),
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
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontFamily: 'Aeonik',
                ),
                hintText: 'Buscar',
                hintStyle: const TextStyle(
                  color: Colors.white,
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
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
        if (selectedCategory != "")
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        selectedCategory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          height: 1,
                          fontFamily: 'Aeonik',
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ],
                ),
                if (selectedCategory == "Joyas y relojes")
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                    child: Image(
                        height: 50,
                        width: 50,
                        image: AssetImage('lib/assets/tags/Joyas_relojes.png')),
                  ),
                if (selectedCategory == "Arte y artesanía")
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                    child: Image(
                        height: 50,
                        width: 50,
                        image:
                            AssetImage('lib/assets/tags/Arte_artesania.png')),
                  ),
                if (selectedCategory == "Juguetes")
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                    child: Image(
                        height: 50,
                        width: 50,
                        image: AssetImage('lib/assets/tags/Juguetes.png')),
                  ),
                if (selectedCategory == "Libros y comics")
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                    child: Image(
                        height: 50,
                        width: 50,
                        image: AssetImage('lib/assets/tags/Libros_comics.png')),
                  ),
                if (selectedCategory == "Monedas y billetes")
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                    child: Image(
                        height: 50,
                        width: 50,
                        image:
                            AssetImage('lib/assets/tags/Monedas_sellos.png')),
                  ),
                if (selectedCategory == "Música")
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                    child: Image(
                        height: 50,
                        width: 50,
                        image: AssetImage('lib/assets/tags/Musica.png')),
                  ),
                if (selectedCategory == "Sellos y postales")
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                    child: Image(
                        height: 50,
                        width: 50,
                        image: AssetImage('lib/assets/tags/Postales.png')),
                  ),
                if (selectedCategory == "Moda")
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                    child: Image(
                        height: 50,
                        width: 50,
                        image: AssetImage('lib/assets/tags/Ropa.png')),
                  ),
                if (selectedCategory == "Vehículos")
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                    child: Image(
                        height: 50,
                        width: 50,
                        image:
                            AssetImage('lib/assets/tags/Icono Monedas y Sellos-1.png')),
                  ),
              ],
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
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
              itemCount: _displayedProducts.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 4) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFF000000),
                    ),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 7.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                              color: Color(0xFFfa7030),
                            ),
                            width: MediaQuery.of(context).size.width * 0.8,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 5.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Image(
                                        image: AssetImage(
                                            'lib/assets/tags/GrupoPartido.png'),
                                        height: 58,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        evento.fechaEvento!.day.toString() +
                                            " " +
                                            meses[evento.fechaEvento!.month]! +
                                            " " +
                                            evento.fechaEvento!.year.toString(),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 11,
                                          fontFamily: 'Aeonik',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ]),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5.0,
                                                vertical: 10.0),
                                            child: Wrap(
                                              children: [
                                                Text(
                                                  evento.direccion!,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                    fontFamily: 'Aeonik',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  softWrap: true,
                                                ),
                                              ],
                                            ))),
                                  ],
                                ),
                                SizedBox(height: 10),
                              ],
                            )),
                        Spacer(),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 10.0),
                                      child: Wrap(
                                        children: [
                                          Text(
                                            evento.descripcion!,
                                            style: const TextStyle(
                                              color: Color(0xFFFE6F1F),
                                              fontSize: 11,
                                              fontFamily: 'Aeonik',
                                              fontWeight: FontWeight.bold,
                                            ),
                                            softWrap: true,
                                          ),
                                        ],
                                      )))
                            ]),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 10.0),
                                      backgroundColor: Color(0xFFFFFFFF),
                                      surfaceTintColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ),
                                    onPressed: () {},
                                    child: const Text("Guardar Evento",
                                        style: TextStyle(
                                          color: Colors.black,
                                          //Quiero que esté en negrita
                                          fontFamily: 'Aeonik',

                                          fontWeight: FontWeight.bold,
                                        ))))
                          ],
                        ),
                      ],
                    ),
                  );
                }
                if (index > 4) {
                  return ProductoWidget(
                      producto: _displayedProducts[index - 1]);
                } else
                  return ProductoWidget(producto: _displayedProducts[index]);
              },
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 5.0),
                      child: const Icon(Icons.favorite_border,
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
                    style:  TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: 'Aeonik',
                    ),

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
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.transparent,
      selectedItemColor: Color(0XFFB3FF77),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (int index) {
        switch (index) {
          case 0:
            //Se queda en la misma ventana
            break;
          case 1: //Articulos con me gusta, por implementar
            Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (context, _, __) =>
                      ListaProductosSubasta(connected: user),
                  transitionDuration: const Duration(seconds: 0)),
            );
            break;
          case 2:
            showAnadirOptions(context);

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
          icon: Image(
              width: 24,
              height: 24,
              color: Color(0XFFB3FF77),
              image: AssetImage('lib/assets/BottomBar/Home.png'),
            ),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Image(
            image: AssetImage('lib/assets/BottomBar/Subasta.png'),
            width: 24,
            height: 24,
          ),
          label: "Subastas",
        ),
        BottomNavigationBarItem(
          icon: Image(
            image: AssetImage('lib/assets/BottomBar/AddProduct.png'),
            width: 24,
            height: 24,
          ),
          label: "Añadir",
        ),
        BottomNavigationBarItem(
          icon: Image(
            image: AssetImage('lib/assets/BottomBar/Chat.png'),
            width: 24,
            height: 24,
          ),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Image(
            image: AssetImage('lib/assets/BottomBar/Perfil.png'),
            width: 24,
            height: 24,
          ),
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

void showAnadirOptions(BuildContext context) {
  showBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
          decoration: const BoxDecoration(
            color: Color(0XFF161616),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height *
              0.77, // Ajusta la altura según tus necesidades
          child: Column(
            children: [
              SizedBox(height: 15),
              Container(
                width: 100,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0XFF343434),
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 10.0),
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            VentanaAnadirProducto(user: user)),
                  );
                  //Aqui irá la descripcion detallada de producto
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 0.0, vertical: 0.0),
                  decoration: const BoxDecoration(
                    color: Color(0XFF343434),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Subir",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 50,
                                        height: 1.2,
                                        fontFamily: 'Aeonik',
                                      )),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0, vertical: 5.0),
                                    decoration: const BoxDecoration(
                                      color: Colors.white10,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Color(0XFFB3FF77),
                                      size: 25,
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                "artículo",
                                style: TextStyle(
                                  color: Color(0XFFB3FF77),
                                  fontSize: 50,
                                  height: 0.5,
                                  fontFamily: 'Aeonik',
                                ),
                              ),
                            ],
                          )),
                      SizedBox(height: 26),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image(
                              image:
                                  AssetImage('lib/assets/tags/Group 315.png'),
                              height: 58,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 10.0),
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VentanaAnadirSubasta(user: user)),
                  );
                  //Aqui irá la descripcion detallada de producto
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 0.0, vertical: 0.0),
                  decoration: const BoxDecoration(
                    color: Color(0XFF343434),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Iniciar",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 50,
                                        height: 1.2,
                                        fontFamily: 'Aeonik',
                                      )),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0, vertical: 5.0),
                                    decoration: const BoxDecoration(
                                      color: Colors.white10,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Color(0XFFFE6F1F),
                                      size: 25,
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                "Subasta",
                                style: TextStyle(
                                  color: Color(0XFFFE6F1F),
                                  fontSize: 50,
                                  height: 0.5,
                                  fontFamily: 'Aeonik',
                                ),
                              ),
                            ],
                          )),
                      SizedBox(height: 26),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image(
                              image: AssetImage(
                                  'lib/assets/tags/Group 315 (1).png'),
                              height: 58,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      });
}
