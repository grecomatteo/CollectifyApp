import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:collectify/ConexionBD.dart';

void main() {
  group("Pruebas Base de Datos", () {
    Usuario? u;
    test('Test de conexion', () async {
      expect(await Conexion().conectar(), true);
    });

    test('Test Lista Productos', () async {
      expect(await Conexion().getAllProductos(), isA<List<Producto>>());
    });

    test('Test getUsuarioByID', () async {
      u = await Conexion().getUsuarioByID(1);
      expect(u, isA<Usuario>());
    });

    test('Test getUsuarioByNick', () async {
      u = await Conexion().getUsuarioByNick("admin");
      expect(u, isA<Usuario>());
    });
    test('Test Login', () async {
      u = await Conexion().login("admin", "admin");
      expect(u, isA<Usuario>());
      expect(u?.nombre, "admin");
    });
    /*
  test('test Registro', () async {
     bool success = await Conexion( ).registrarUsuario("Pepe", "Garcia", "pep02", "aaa@gmail.com" , "contraseña", DateTime(2000,12,12));
     expect(success, isTrue);
    });
    //Esto literalmente solo se puede hacer 1 vez
*/
  });

  group("Pruebas unitarias", () {
    test('Test Usuario', () async {
      Usuario u = Usuario(
          usuarioID: 1,
          nombre: "Pepe",
          apellidos: "Garcia",
          nick: "pep02",
          correo: "pepe@gmail.com",
          contrasena: "contraseña",
          fechaNacimiento: DateTime(2000, 12, 12),
          esEmpresa: 0);

      expect(u.usuarioID, 1);
      expect(u.nombre, "Pepe");
      expect(u.apellidos, "Garcia");
      expect(u.nick, "pep02");
      expect(u.correo, "pepe@gmail.com");
      expect(u.contrasena, "contraseña");
      expect(u.fechaNacimiento, DateTime(2000, 12, 12));
      expect(u.esEmpresa, 0);
    });
    test('Test Producto', () async {
      Producto p = Producto(
        usuarioID: 1,
        productoID: 1,
        nombre: "Producto",
        descripcion: "Descripcion",
        precio: 10,
        esPremium: false,
        esSubasta: false,



      );
      expect(p.usuarioID, 1);
      expect(p.productoID, 1);
      expect(p.nombre, "Producto");
      expect(p.descripcion, "Descripcion");
      expect(p.precio, 10);
      expect(p.esPremium, false);
      expect(p.esSubasta, false);

    });
    test('Test Imagen', () async {
      Imagen i = Imagen(
        productoID: 1,
        nombre: "Producto",
        image: Uint8List(10)
      );
      expect(i.productoID, 1);
      expect(i.nombre, "Producto");
      expect(i.image, Uint8List(10));
    });
    test('Test Evento', () async {
      Evento e = Evento(
        usuarioID: 1,
        idEvento: 1,
        nombre: "Evento",
        descripcion: "Descripcion",
        fechaEvento: DateTime(2000, 12, 12),
        direccion: "Direccion",

      );
      expect(e.usuarioID, 1);
      expect(e.idEvento, 1);
      expect(e.nombre, "Evento");
      expect(e.descripcion, "Descripcion");
      expect(e.fechaEvento, DateTime(2000, 12, 12));
      expect(e.direccion, "Direccion");


    });
  });
}
