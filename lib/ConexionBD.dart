import 'dart:async';

import 'package:mysql1/mysql1.dart';
import 'package:flutter/material.dart';

class Producto{
    int? usuarioID;
    int? productoID;
    String? nombre;
    String? descripcion;
    double? precio;
    String? imagePath;
    bool? esPremium;
    //Cosas subasta
    DateTime? fechaFin;
    int? precioInicial;
    int? ultimaOferta;
    Producto({this.usuarioID,this.productoID, this.nombre, this.descripcion, this.precio, this.imagePath, this.esPremium});
    //Producto({this.usuarioID,this.productoID, this.nombre, this.descripcion, this.precio, this.imagePath, this.esPremium, this.fechaFin, this.precioInicial, this.ultimaOferta});
}


class Imagen{
  int? productoID;
  String? nombre;
  List<int>? image;
  Imagen({this.productoID, this.nombre, this.image});
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

    await conn?.query('select * from producto where usuarioID in(select userID from usuario where esPremium = 1);').then((results) {
      for (var row in results) {
        Producto producto = Producto(
            usuarioID: row[0],
            productoID: row[1],
            nombre:row[2],
            descripcion: row[3],
            precio: row[4],
            imagePath: row[5],
            esPremium: true
        );
        productos.add(producto);
      }
    });
    await conn?.query('select * from producto where usuarioID in(select userID from usuario where esPremium = 0);').then((results) {
      for (var row in results) {
        Producto producto = Producto(
            usuarioID: row[0],
            productoID: row[1],
            nombre:row[2],
            descripcion: row[3],
            precio: row[4],
            imagePath: row[5],
            esPremium: false
        );
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
    try {
      await conn?.query("insert into usuario(nombre,apellidos,nick,correo,contrasena,fechaNac) values('$nombre', '$apellido', '$nick', '$correo', '$contrasena', '$fechaNac')");

  }
    catch(e){
      debugPrint(e.toString());
    }





    return true;
  }

  Future<int> anadirProducto(Producto product, Usuario user) async{
    if(conn==null) await conectar();
    int userID = user.usuarioID!;
    String? nombre = product.nombre;
    String? descripcion = product.descripcion;
    String? image = product.imagePath;
    double? precio = product.precio;
    try {
      await conn?.query("INSERT INTO producto (usuarioID, nombre, descripcion, precio, imagePath) "
          "VALUES ('$userID', '$nombre', '$descripcion', '$precio', '$image'); "
          );

      var id = await conn?.query("SELECT LAST_INSERT_ID() as id;");

      return id!.first['id'];
    }
    catch(e){
      debugPrint(e.toString());
    }
    return -1;
  }

  void hacerPremium(int id) async{
    if(conn==null) await conectar();
    await conn?.query("update usuario set esPremium = 1 where userID = $id");
  }
  Future<bool> anadirImagen(Imagen img) async{
    if(conn==null) await conectar();
    String? nombre = img.nombre;
    int? ID = img.productoID;
    List<int>? image = img.image;

    try {
      await conn?.query("INSERT INTO IMAGEN (id_producto, nombre, image) "
          "VALUES ('$ID', '$nombre', '$image'); "
      );
    }
    catch(e){
      debugPrint(e.toString());
    }
    return true;
  }


  Future<int> esPremium(int id) async {
    if(conn==null) await conectar();
    int esPremium = 0;
    await conn?.query("select esPremium from usuario where userID = $id").then((results) {
      for (var row in results) {
        esPremium = row[0];
      }
    });
    return esPremium;
  }


  Future<bool> anadirProductoSubasta(Producto producto, Usuario usuario, ) async {
    if(conn==null) await conectar();

    return true;
  }

  Future<List<Producto>> getProductosSubasta() async{
    if(conn==null) await conectar();
    List<Producto> productos = [];
    Producto producto;
    await conn?.query('select p.*, ps.*,u.esPremium from producto p JOIN productos_subasta ps ON ps.idProducto = p.pruductoID Join usuario u ON p.usuarioID = u.userID Order By u.esPremium ASC;').then((results) => {
      for (var row in results) {
        producto = Producto(
            usuarioID: row['usuarioID'],
            productoID: row['productoID'],
            nombre:row['nombre'],
            descripcion: row['descripcion'],
            precio: row['precio'],
            imagePath: row['imagePath'],
            esPremium: row['esPremium'],
        ),
        producto.fechaFin = row['fechaFin'],
        producto.precioInicial = row['precioInicial'],
        producto.ultimaOferta = row['ultimaOferta'],

        productos.add(producto)
      }

    });

    return productos;
  }
}


