import 'package:mysql1/mysql1.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class Conexion {
  MySqlConnection? conn;
  Future<void> conectar() async {
    debugPrint("Conectando");
    try{

      conn = await MySqlConnection.connect(
          ConnectionSettings(
            host: "collectify-server-mysql.mysql.database.azure.com",
            port: 3306,
            user: "pin2023",
            password: "AsLpqR_23",
            db: "collectifyDB",
          ));
      await conn?.query('select * from usuario').then((results) {
        for (var row in results) {
          debugPrint(row.toString());
        }
      });
      debugPrint("Conectado");

    }catch(e){
      debugPrint(e.toString() + "Error");
    }
}
}