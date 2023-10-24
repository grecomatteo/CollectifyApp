import 'package:flutter/material.dart';

import 'ConexionBD.dart';

class VentanaPerfil extends StatelessWidget {
  VentanaPerfil({super.key, required this.user});

  final Usuario user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
            child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            const Text('Perfil'),
            Icon(Icons.account_circle, size: 100),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                if (await Conexion()
                    .esPremium(user.usuarioID as int)
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
                  Conexion().hacerPremium(user.usuarioID as int);
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
              child: Text("Hazte Premium"),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.yellow),
              ),
            ),
            Spacer(),
          ],
        )));
  }
}
