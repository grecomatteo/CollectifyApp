import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'VentanaProducto.dart';

Usuario user = Usuario();
bool isValid=true;

class ListaProductosSubasta extends StatefulWidget {
  const ListaProductosSubasta({Key? key, required this.connected}) : super(key: key);
  final Usuario connected;
  @override
  _ListaProductosState createState() => _ListaProductosState(connected: connected);
}

class _ListaProductosState extends State<ListaProductosSubasta> {
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
    List<Producto> allProducts = await Conexion().getProductosSubastaBasadoPreferencias(user);
    setState(() {
      _searchResults = allProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    user = connected;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Container(
        //padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        constraints: const BoxConstraints.expand(),
        child:Column(
          children:[
          SearchBar(onSearchResults: (results) {
            setState(() {
              _searchResults = results;
            });
          }),
          const SizedBox(
            height: 10,
          ),
          DefaultTabController(
            length: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white10,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  splashBorderRadius: BorderRadius.circular(15),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: null,
                  labelColor: Colors.white,
                  labelStyle: const TextStyle(
                    fontSize: 30,
                  ),
                  tabs: const [
                    Tab(text: 'Subastas'),
                    Tab(text: 'Pujas'),
                  ],
                ),
               SizedBox(
                 height: MediaQuery.of(context).size.height*0.7,
                     child:TabBarView(
                       children: [
                         ProductList(searchResults: _searchResults),
                         ProductList(searchResults: _searchResults),
                        ],
                     ),
                 ),
          ],),
          ),
        ],),
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
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.all(Radius.circular(60)),
        ),
        child: TextField(
          controller: _controller,
          onChanged: (query) {
            // Actualiza la lista de resultados de búsqueda cada vez que cambia el texto
            _handleSearch(query);
          },
          decoration: InputDecoration(
            hintText: 'Buscar',
            hintStyle: const TextStyle(
              color: Colors.grey,
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
      );
  }

  void _handleSearch(String query) async {
    // Chiamare la logica di ricerca nel database usando la classe Conexion
    List<Producto> searchResults = await Conexion().searchProductos(query);
    // Passare i risultati della ricerca alla funzione onSearchResults fornita come parametro
    widget.onSearchResults(searchResults);
  }
}

class ProductList extends StatefulWidget {
  const ProductList({Key? key, this.searchResults = const []}) : super(key: key);
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
          _displayedProducts =
          widget.searchResults.isNotEmpty ? widget.searchResults : snapshot.data!;

          if (isValid==false) {
            isValid=true;
            return const Center(
              child: Text('La búsqueda no es válida. Ingrese un término de búsqueda válido.'),
            );
          } else if (widget.searchResults.isEmpty) {
            return const Center(
              child: Text('No hay ningún producto con ese nombre'),
            );
          } else {
            return ListView.builder(
              //padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              itemBuilder: (BuildContext context, int index) { return ProductoWidget(producto: _displayedProducts[index]); },
              itemCount: _displayedProducts.length
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


  String Temporizador(){
    DateTime now= DateTime.now();
    final diferencia = producto.fechaFin?.difference(now);
    final Dia = diferencia?.inDays ;
    final Hora = diferencia!.inHours - Dia!*24;
    if(diferencia.isNegative){return "¡Terminada!";}
    else {return "${Dia}d ${Hora}h";}
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child:
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VentanaProducto(connected: user, producto: producto)),
              );
              //Aqui irá la descripcion detallada de producto
            },
            child: Center(
              child: Column(
                children: [
                  //const Spacer(),
                  const SizedBox(
                    height: 15,
                  ),
                  Flexible(
                    flex: 0,
                    fit: FlexFit.tight,
                    child: Container(
                        width:400,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                              image: Image.memory(const Base64Decoder().convert(producto.image.toString())).image,
                              fit: BoxFit.cover
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white10,
                                ),
                                child : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Finaliza en   ", style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    )),
                                    Text(Temporizador(), style: const TextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ))
                                  ],
                                ),
                              ),
                              const Icon(Icons.favorite, color: Colors.deepOrangeAccent)
                            ]
                        )
                    ),
                  ),

                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if(producto.esPremium == true)
                                const Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.yellow,),
                                    Text("Premium", style: TextStyle(color: Colors.yellow),),
                                  ],
                                ),
                              Text(producto.nombre!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.deepOrange,
                                ),
                                child: const Row(
                                    children:[
                                      Text("Editar puja",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15
                                        ))
                                    ]),
                              ),
                            ]
                        ),
                        Column(

                          children: [
                            const Text("Ultima puja", style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            )),
                            Text("${producto.ultimaOferta} €", style: const TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            )),
                          ],
                        )

                      ]
                  ),
                  //const Spacer(),
                  const SizedBox(
                    height: 10,
                    width: 10,
                  )
                ],
              ),
            )),


    );

  }
}
