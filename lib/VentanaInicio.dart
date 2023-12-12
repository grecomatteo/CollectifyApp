

import 'dart:io';

import 'package:collectify/VentanaRegister.dart';
import 'package:flutter/material.dart';

import 'VentanaLogin.dart';

class VentanaInicio extends StatelessWidget {
  const VentanaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text('Bienvenido a',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Aeonik',
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(30),
                  //height: 80,
                  transformAlignment: Alignment.center,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/assets/collectify.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Text('Descubre artículos únicos, conecta con otros amantes de las rarezas y encuentra piezas que hagan brillar tu colección.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Aeonik',
                    color: Color.fromRGBO(47,47,47,1),
                  ),
                  textAlign: TextAlign.center,
                ),
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
          ],
        )
      )
    );
  }
}