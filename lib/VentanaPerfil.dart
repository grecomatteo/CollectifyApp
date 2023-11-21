import 'dart:async';

import 'package:flutter/material.dart';

import 'ConexionBD.dart';
import 'VentanaAnadirEvento.dart';

Usuario? myUser;
Usuario? reviewUser;

class VentanaPerfil extends StatelessWidget {
  VentanaPerfil({super.key, required this.mUser, required this.rUser});

  Usuario mUser;
  Usuario? rUser;
  bool visibility =  false;

  @override
  Widget build(BuildContext context) {
    myUser = mUser;
    reviewUser = rUser;
    if (mUser.esEmpresa == 1){
      visibility =  true;
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        bottomNavigationBar: const NavigationBar(),
        body: Center(
            child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text('Perfil'),
            const Icon(Icons.account_circle, size: 100),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                if (await Conexion()
                    .esPremium(mUser.usuarioID as int)
                    .then((value) => value == 1)) {
                  //Mostrar un cuadro de error
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            title: const Text("Error"),
                            content: const Text("Ya eres premium"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("OK"))
                            ],
                          ));
                } else {
                  Conexion().hacerPremium(mUser.usuarioID as int);
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            title: const Text("¡Enhorabuena!"),
                            content: const Text("Ahora eres premium"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("OK"))
                            ],
                          ));
                }
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.yellow),
              ),
              child: const Text("Hazte Premium"),
            ),
            Visibility(
                visible: visibility
                ,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VentanaAnadirEvento(user : mUser)),
                );
                },
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.green),
               ),
              child: const Text("Crear nuevo evento"),
              ),
            ),
            const Spacer(),
            const Text("Valoraciones", style: TextStyle(fontSize: 20, color: Colors.deepPurple),),
            const UserValoracion(),
          ],
        )),
    );
  }
}



class UserValoracion extends StatefulWidget {
  const UserValoracion({Key? key}) : super(key: key);

  @override
  State<UserValoracion> createState() => _UserValoracionState();
}

class _UserValoracionState extends State<UserValoracion> {
  static StreamController<List<Valoracion>> _streamController = StreamController<List<Valoracion>>.broadcast();

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<List<Valoracion>>.broadcast();
    refresh();
  }

  static void refresh() async {
    List<Valoracion> valoraciones = await Conexion().getValoraciones(reviewUser!.usuarioID!);
    _streamController.add(valoraciones);
  }

  @override
  Widget build(BuildContext context) {
    refresh();
    return StreamBuilder(
        stream: _streamController.stream,
        builder: (BuildContext context, AsyncSnapshot<List<Valoracion>> snapshot) {
          if (snapshot.hasData) {
            if(snapshot.data!.isEmpty){
              return const Center(
                child: Text("No hay valoraciones"),
              );
            }
            return Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      //Calcular media de valoraciones de cada usuario
                      Text("Media de valoraciones: ${snapshot.data!.map((e) => e.valoracion!).reduce((a, b) => a + b) / snapshot.data!.length}"),
                      Card(
                        child: ListTile(
                          title: Text(snapshot.data![index].nickUsuarioReviewer as String),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(snapshot.data![index].comentario as String),
                              Row(
                                children: [
                                  for(int i = 0; i < snapshot.data![index].valoracion!; i++)
                                    const Icon(Icons.star, color: Colors.orangeAccent,),
                                  for(int i = 0; i < 5 - snapshot.data![index].valoracion!; i++)
                                    const Icon(Icons.star_border, color: Colors.orangeAccent,),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                },
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}


class NavigationBar extends StatefulWidget {
  const NavigationBar({Key? key}) : super(key: key);

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  Future<void> sendMessage(int userID) async {
    Conexion().anadirValoracion(userID, myUser!.usuarioID!, toSendMessage, valoracion);
    valoracion = 0;

    //Refresh ProductValoracion
    _UserValoracionState.refresh();
  }

  final textField = TextEditingController();
  String toSendMessage = "";
  int valoracion = 0;

  @override
  Widget build(BuildContext context) {
    if(reviewUser == null) {
      return const SizedBox.shrink();
    } else {
      if(reviewUser!.usuarioID == myUser!.usuarioID) {
        return const SizedBox.shrink();
      }
    }
    return Container(
      //Make height of NavigationBar the same as the height of the keyboard
      height: MediaQuery
          .of(context)
          .viewInsets
          .bottom + 70 + 46,
      alignment: Alignment.bottomCenter,
      color: Colors.grey[200],
      child: Column(
        children: [
          Row(
            children: [
              for(int i = 0; i < valoracion; i++)
                IconButton(
                  onPressed: () {
                    setState(() {
                      valoracion = i + 1;
                    });
                  },
                  icon: const Icon(Icons.star, color: Colors
                      .orangeAccent,),
                ),
              for(int i = valoracion; i < 5; i++)
                IconButton(
                  onPressed: () {
                    setState(() {
                      valoracion = i + 1;
                    });
                  },
                  icon: const Icon(Icons.star_border, color: Colors
                      .orangeAccent,),
                ),
            ],
          ),
          Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child:
            Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Type a comment",
                      border: InputBorder.none,
                    ),
                    onChanged: (text) {
                      toSendMessage = text;
                    },
                    controller: textField,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    if (toSendMessage
                        .replaceAll(' ', '')
                        .isEmpty) return;

                    if(valoracion == 0) return;
                    //send message, clear text field, scroll to the bottom, close keyboard and refresh the page
                    setState(() {
                      sendMessage(reviewUser!.usuarioID!);
                    });
                    //empty the text field
                    textField.clear();
                    toSendMessage = "";
                    FocusScope.of(context).unfocus();
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}