

import 'dart:ffi';

import 'package:mysql1/mysql1.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class Producto{
    int? productoID;
    String? nombre;
    String? descripcion;
    double? precio;
    String? imagePath;
    Producto({this.productoID, this.nombre, this.descripcion, this.precio, this.imagePath});
}

class Usuario {
  int? usuarioID;
  String? nombre;
  String? apellidos;
  String? nick;
  String? correo;
  String? contrasena;
  DateTime? fechaNacimiento;
  Usuario({this.usuarioID, this.nombre, this.apellidos, this.nick, this.correo, this.contrasena, this.fechaNacimiento});
}
class Conexion {

  static MySqlConnection? conn;

  Future<void> conectar() async {
    debugPrint("Conectando");
    if(conn != null){
      return;
    }


    try {
      conn = await MySqlConnection.connect(ConnectionSettings(
        host: "collectify-server-mysql.mysql.database.azure.com",
        port: 3306,
        user: "pin2023",
        password: "AsLpqR_23",
        db: "collectifyDB",
      ));
      await conn?.query('select * from usuario').then((results) {
        for (var row in results) {
          debugPrint(row.runtimeType.toString());
          debugPrint(row.toString());
        }
      });
      debugPrint("Conectado");
    } catch (e) {
      debugPrint(e.toString() + "Error");
    }



  }

  Future<List<Producto>> getProductos() async {
    if (conn==null )await conectar();
    List<Producto> productos = [];
    await conn?.query('select * from producto').then((results) {
      for (var row in results) {
        Producto producto = Producto(
            productoID: row[0],
            nombre:row[1],
            descripcion: row[2],
            precio: row[3],
            imagePath: row[4]);
        productos.add(producto);
      }
    });
    return productos;
  }

  Future<List<Usuario>> getUsuarios() async{
    if(conn==null) await conectar();
    List<Usuario> usuarios = [];
    await conn?.query('select * from usuario').then((results) {
      for (var row in results) {
        Usuario usuario = Usuario(
        usuarioID : row[0],
        nombre: row[1],
        apellidos :row[2],
        nick : row[3],
        correo : row[4],
        contrasena : row[5],
        fechaNacimiento : row[6],
        );
        usuarios.add(usuario);
      }
    });
    return usuarios;

  }
  Future<Usuario?> getUsuarioByID(int id) async{
    Usuario? usuario;
    if(conn==null) await conectar();

    await conn?.query("select * from usuario where userID = $id limit 1").then((results) {
      for (var row in results) {
        usuario = Usuario(
          usuarioID : row[0],
          nombre: row[1],
          apellidos :row[2],
          nick : row[3],
          correo : row[4],
          contrasena : row[5],
          fechaNacimiento : row[6],
        );

      }
    });
    if(usuario==null) throw new Exception("Usuario no encontrado");
    return usuario;
  }
  Future<Usuario?> getUsuarioByNick(String nick) async{
    Usuario? usuario;
    if(conn==null) await conectar();

    await conn?.query("select * from usuario where nick = '$nick' limit 1").then((results) {
      for (var row in results) {
        usuario = Usuario(
          usuarioID : row[0],
          nombre: row[1],
          apellidos :row[2],
          nick : row[3],
          correo : row[4],
          contrasena : row[5],
          fechaNacimiento : row[6],
        );

      }
    });
    if(usuario==null) return null;
    return usuario;
  }

  Future<Usuario?> login(String nick, String contrasena) async {
    if(conn==null) await conectar();

    Usuario? usuario = await getUsuarioByNick(nick);


    if(usuario == null) throw Exception("Usuario no encontrado");

    if(usuario.contrasena == contrasena) return usuario;
    else throw Exception("Contraseña incorrecta");

  }
  Future<int> getNumeroUsuarios() async{
    if (conn==null )await conectar();
    int numeroUsuarios = 0;
    await conn?.query('select count(*) from usuario').then((results) {
      for (var row in results) {
        numeroUsuarios = row[0];
      }
    });
    return numeroUsuarios;
  }

  Future<int> getNumeroProductos() async{
    if (conn==null )await conectar();
    int numeroProductos = 0;
    await conn?.query('select count(*) as product_count from producto').then((results) {
      numeroProductos = results.first['product_count'];
    });
    return numeroProductos;
  }

  Future<bool> registrarUsuario(String nombre, String apellido, String nick, String correo, String contrasena, DateTime fechaNac) async{
    if(conn==null) await conectar();
    int id = await getNumeroUsuarios();
    try {
      await conn?.query("insert into usuario values($id, '$nombre', '$apellido', '$nick', '$correo', '$contrasena', '$fechaNac')");

  }
    catch(e){
      debugPrint(e.toString());
    }
    return true;
  }

  Future<bool> anadirProducto(Producto product) async{
    if(conn==null) await conectar();
    int id = await getNumeroProductos() + 1;
    String? nombre = product.nombre;
    String? descripcion = product.descripcion;
    String? image = product.imagePath;
    double? precio = product.precio;
    try {
      await conn?.query("insert into producto values('$id', '$nombre', '$descripcion', '$precio', '$image')");
    }
    catch(e){
      debugPrint(e.toString());
    }
    return true;
  }



}

