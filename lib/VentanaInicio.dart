import 'dart:io';
import 'dart:math';

import 'package:collectify/VentanaRegister.dart';
import 'package:flutter/material.dart';
import 'Gradients/gradient.dart';

import 'VentanaLogin.dart';

class VentanaInicio extends StatelessWidget {
  const VentanaInicio({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(height: 50),
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
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: <InlineSpan>[
                      const TextSpan(
                        text: 'Descubre artículos únicos, conecta con otros amantes de las rarezas y encuentra piezas que hagan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Aeonik',
                          color: Color.fromRGBO(70,70,70,1),
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: GradientText(' brillar ',
                          colors: const <Color>[
                            Color.fromRGBO(255, 84, 0, 1),
                            Color.fromRGBO(180, 253, 118, 1)
                          ],
                        ),
                      ),
                      const TextSpan(
                        text: 'tu colección.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Aeonik',
                          color: Color.fromRGBO(70,70,70,1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
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