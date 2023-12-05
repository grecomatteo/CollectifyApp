import 'package:collectify/VentanaAnadirProducto.dart';
import 'package:collectify/VentanaEventos.dart';
import 'package:mysql1/mysql1.dart';

import 'package:collectify/ConexionBD.dart';
import 'package:collectify/VentanaInicio.dart';
import 'package:collectify/VentanaLogin.dart';
import 'package:collectify/VentanaPerfil.dart';
import 'package:collectify/VentanaProducto.dart';
import 'package:collectify/VentanaRegister.dart';
import 'package:collectify/VentanaListaProductos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("Test Ventana Inicio", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: VentanaInicio()));
  });
  testWidgets("Test Ventana Login", (WidgetTester tester) async {
    await tester.pumpWidget(const VentanaLogin());
  });
  testWidgets("Test Ventana Register", (WidgetTester tester) async {
    await tester.pumpWidget(VentanaRegister());
  });

  testWidgets("Test Ventana Lista Productos", (WidgetTester tester) async {
    Usuario u = new Usuario(usuarioID: 1);
    await tester.pumpWidget(MaterialApp(home: ListaProductos(connected: u)), );
    await tester.pumpAndSettle();

  });
  testWidgets("Test Ventana Eventos", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: VentanaEventos()));
  });
  testWidgets("Test Ventana Añadir Producto", (WidgetTester tester) async {
    Usuario u = await Conexion().getUsuarioByID(1) as Usuario;
    await tester.pumpWidget(VentanaAnadirProducto(
      user: u,
    ));
    await tester.pumpAndSettle();
  });
  testWidgets("Test Ventana Perfil", (WidgetTester tester) async {
    Usuario u = await Conexion().getUsuarioByID(1).then((value){
      debugPrint(value?.nombre.toString());
      return value as Usuario;

    });
    Usuario r = await Conexion().getUsuarioByID(2) as Usuario;
    await tester.pumpWidget(VentanaPerfil(mUser: u, rUser: r));
  });


  testWidgets("Test Ventana Producto", (WidgetTester tester) async {
    Usuario u = new Usuario(usuarioID: 1);
    Blob? imagen = await Conexion().obtenerImagen(62);
    Producto p = new Producto(
        productoID: 1,
        nombre: "Moneda",
        descripcion: "Moneda de 1 euro",
        image: imagen);

    await tester.pumpWidget(
        MaterialApp(home: VentanaProducto(connected: u, producto: p)));
  });

}
