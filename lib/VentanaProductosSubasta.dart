import 'dart:convert';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'VentanaAnadirProducto.dart';
import 'VentanaAnadirSubasta.dart';
import 'VentanaChat.dart';
import 'VentanaListaProductos.dart';
import 'VentanaPerfil.dart';
import 'VentanaProductoSubasta.dart';

Usuario user = Usuario();
bool isValid = true;
bool loading = false;

class ListaProductosSubasta extends StatefulWidget {
  const ListaProductosSubasta({Key? key, required this.connected})
      : super(key: key);
  final Usuario connected;
  @override
  _ListaProductosState createState() =>
      _ListaProductosState(connected: connected);
}

class _ListaProductosState extends State<ListaProductosSubasta>
    with SingleTickerProviderStateMixin {
  _ListaProductosState({required this.connected});
  final Usuario connected;
  List<Producto> _searchResults = [];
  late TabController _tabController;

  void _handleTabSelection() {
    // Obtener el índice de la pestaña activa
    int tabIndex = _tabController.index;
    if (tabIndex == 0) {
      cargarProductos();
    } else {
      cargarPujas();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _handleTabSelection();
    _tabController.addListener(_handleTabSelection);
    // Inicializa _searchResults con todos los productos al momento de la creación del estado
  }

  Future<void> cargarProductos() async {
    List<Producto> allProducts =
        await Conexion().getProductosSubastaBasadoPreferencias(user);
    setState(() {
      _searchResults = allProducts;
    });
  }

  Future<void> cargarPujas() async {
    List<Producto> allProducts = await Conexion().getPujasRealizadas(user);
    setState(() {
      _searchResults = allProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    user = connected;
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
            decoration: const BoxDecoration(
              color: Color(0XFF343434),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            child: const NavigationBar(),
          )),

      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            SearchBar(onSearchResults: (results) {
              setState(() {
                _searchResults = results;
              });
              if (results.isEmpty) {
                _handleTabSelection();
              }
            }),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              dragStartBehavior: DragStartBehavior.start,
              dividerColor: const Color(0XFF161616),
              enableFeedback: true,
              indicatorWeight: 3.0,
              indicator: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.zero,
                    bottomRight: Radius.zero),
                color: Color(0XFF161616),
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 20,
                fontFamily: 'Aeonik',
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 50,
                fontFamily: 'Aeonik',
              ),
              tabs: [
                Tab(
                  text: 'Subastas',
                  height: 60,
                ),
                Tab(
                  text: 'Pujas',
                  height: 60,
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Container(
                      decoration: const BoxDecoration(
                        color: Color(0XFF161616),
                      ),
                      child: ProductList(searchResults: _searchResults)),
                  Container(
                      decoration: const BoxDecoration(
                        color: Color(0XFF161616),
                      ),
                      child: PujasList(searchResults: _searchResults)),
                ],
              ),
            ),
          ],
        ),
      ),
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
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0XFF161616),
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
              hintText: 'Buscar',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 16.0,
                fontFamily: 'Aeonik',
              ),
              border: InputBorder.none,
              prefixIcon: IconButton(
                icon: const Icon(Icons.search),
                color: Colors.grey.withOpacity(0.8),
                onPressed: () {
                  // Acciones a realizar cuando se presiona el ícono de búsqueda
                  _handleSearch(_controller.text);
                },
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 15.0),
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
                          ? Color(0XFFB3FF77)
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Aeonik',
                      ),
                    ),
                  ));
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
      searchResults =
          await Conexion().getProductosSubastaBasadoPreferencias(user);
      setState(() {
        loading = false;
      });
    } else if (query.isEmpty && category != null) {
      searchResults = await Conexion().getSubastaPorCategoria(category);
      setState(() {
        loading = false;
      });
    } else {
      //Mostrar un widget de cargando

      // Llama a la lógica de búsqueda de la base de datos usando la clase Conexion
      searchResults = await Conexion().searchSubastas(query);
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
      future: Conexion().getProductosSubastaBasadoPreferencias(user),
      builder: (BuildContext context, AsyncSnapshot<List<Producto>> snapshot) {
        if (snapshot.hasData) {
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
            return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                itemBuilder: (BuildContext context, int index) {
                  return ProductoWidget(producto: _displayedProducts[index]);
                },
                itemCount: _displayedProducts.length);
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

  String Temporizador() {
    DateTime now = DateTime.now();
    Duration diferencia = producto.fechaFin!.difference(now);
    var Dia = diferencia.inDays;
    var Hora = diferencia.inHours - Dia * 24;
    if (diferencia.isNegative) {
      return "¡Terminada!";
    } else {
      return "${Dia}d ${Hora}h";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0XFF161616),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VentanaProductoSubasta(
                    connected: user, producto: producto)),
          );
          //Aqui irá la descripcion detallada de producto
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
                flex: 0,
                child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        image: Image.memory(const Base64Decoder()
                                .convert(producto.image.toString()))
                            .image,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.zero,
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20)),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 15.0),
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0XFF161616),
                                  blurRadius: 10.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(2.0,
                                      5.0), // shadow direction: bottom right
                                )
                              ],
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.zero,
                                  topRight: Radius.zero,
                                  bottomLeft: Radius.zero,
                                  bottomRight: Radius.circular(20)),
                              color: Color(0XFF161616),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Finaliza en   ",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontFamily: 'Aeonik')),
                                Text(Temporizador(),
                                    style: const TextStyle(
                                        color: Color(0XFFB3FF77),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Aeonik'))
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 11.0, vertical: 11.0),
                            child: const Icon(Icons.favorite_border,
                                color: Colors.white),
                          )
                        ]))),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(
                  height: 15,
                ),
                Text(
                  producto.nombre!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                      fontFamily: 'Aeonik'),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(47),
                    color: Color(0XFFB3FF77),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Color(0XFF99DC64),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.gavel, color: Color(0XFF161616)),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text("Pujar",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Aeonik'))
                  ]),
                ),
              ]),
              Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    producto.categoria!,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13, fontFamily: 'Aeonik'),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text("Última puja",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontFamily: 'Aeonik')),
                  Text("${producto.ultimaOferta} €",
                      style: const TextStyle(
                          color: Color(0XFFB3FF77),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Aeonik')),
                ],
              )
            ]),
            //const Spacer(),
          ],
        ),
      ),
    );
  }
}

class PujasList extends StatefulWidget {
  const PujasList({Key? key, this.searchResults = const []}) : super(key: key);
  final List<Producto> searchResults;
  @override
  PujasListState createState() => PujasListState();
}

class PujasListState extends State<PujasList> {
  List<Producto> _displayedProducts = [];
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Conexion().getPujasRealizadas(user),
      builder: (BuildContext context, AsyncSnapshot<List<Producto>> snapshot) {
        if (snapshot.hasData) {
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
              child: Text('No hay ningún proudcto'),
            );
          } else {
            return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                itemBuilder: (BuildContext context, int index) {
                  return PujaWidget(producto: _displayedProducts[index]);
                },
                itemCount: _displayedProducts.length);
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

class PujaWidget extends StatelessWidget {
  final Producto producto;
  const PujaWidget({super.key, required this.producto});

  String Temporizador() {
    DateTime now = DateTime.now();
    Duration diferencia = producto.fechaFin!.difference(now);
    var Dia = diferencia.inDays;
    var Hora = diferencia.inHours - Dia * 24;
    if (diferencia.isNegative) {
      return "¡Terminada!";
    } else {
      return "${Dia}d ${Hora}h";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0XFF161616),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0XFF161616),
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VentanaProductoSubasta(
                    connected: user, producto: producto)),
          );
          //Aqui irá la descripcion detallada de producto
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
                flex: 0,
                child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        image: Image.memory(const Base64Decoder()
                                .convert(producto.image.toString()))
                            .image,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.zero,
                          topRight: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25)),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 15.0),
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0XFF161616),
                                  blurRadius: 10.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(2.0,
                                      5.0), // shadow direction: bottom right
                                )
                              ],
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.zero,
                                  topRight: Radius.zero,
                                  bottomLeft: Radius.zero,
                                  bottomRight: Radius.circular(30)),
                              color: Color(0XFF161616),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Finaliza en   ",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontFamily: 'Aeonik')),
                                Text(Temporizador(),
                                    style: const TextStyle(
                                        color: Color(0XFFFE6F1F),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Aeonik'))
                              ],
                            ),
                          ),
                          const Icon(Icons.favorite_border,
                              color: Colors.white),
                        ]))),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(
                  height: 15,
                ),
                Text(
                  producto.nombre!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                      fontFamily: 'Aeonik'),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 11.0, vertical: 11.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(47),
                    color: Color(0XFFFE6F1F),
                  ),
                  child: Text("Editar Puja",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Aeonik')),
                ),
              ]),
              Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    producto.categoria!,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13, fontFamily: 'Aeonik'),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text("Última puja",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontFamily: 'Aeonik')),
                  Text("tus ${producto.ultimaOferta} €",
                      style: const TextStyle(
                          color: Color(0XFFFE6F1F),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Aeonik')),
                ],
              )
            ]),
          ],
        ),
      ),
    );
  }
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

class NavigationBar extends StatelessWidget {
  const NavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
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
            Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (context, _, __) =>
                      ListaProductos(connected: user),
                  transitionDuration: const Duration(seconds: 0)),
            );
            break;

          case 1: //Articulos con me gusta, por implementar

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
      items: [
        BottomNavigationBarItem(
          icon: Image(

            image: AssetImage('lib/assets/BottomBar/Home.png'),
            width: 24,
            height: 24,
          ),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Image(
            color: Color(0XFFB3FF77),
            image: AssetImage('lib/assets/BottomBar/Subasta.png'),
            width: 24,
            height: 24,
          ),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Image(
            image: AssetImage('lib/assets/BottomBar/AddProduct.png'),
            width: 24,
            height: 24,
          ),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Image(
            image: AssetImage('lib/assets/BottomBar/Chat.png'),
            width: 24,
            height: 24,
          ),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Image(
            image: AssetImage('lib/assets/BottomBar/Perfil.png'),
            width: 24,
            height: 24,
          ),
          label: "",
        ),
      ],
    );
  }
}