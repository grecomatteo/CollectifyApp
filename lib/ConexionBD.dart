import 'package:mysql1/mysql1.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class Producto{
    int? productoID;
    String? nombre;
    String? descripcion;
    double? precio;
    String? imagePath;
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
        Producto producto = new Producto();
        producto.productoID = row[0];
        producto.nombre = row[1];
        producto.descripcion = row[2];
        producto.precio = row[3];
        producto.imagePath = row[4];
        productos.add(producto);
      }
    });
    return productos;
  }




}
