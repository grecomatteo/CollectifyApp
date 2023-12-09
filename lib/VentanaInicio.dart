

import 'package:collectify/VentanaRegister.dart';
import 'package:flutter/material.dart';

import 'VentanaLogin.dart';

class VentanaInicio extends StatelessWidget {
  const VentanaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collectify'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bienvenido a Collectify'),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  VentanaLogin()));

              },
              child: const Text('Iniciar sesión'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  RegistroUsuariosScreen()));
              },
              child: const Text('Registrarse'),
            ),
          ],
        )
      )
    );
  }
}