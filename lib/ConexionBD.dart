import'dart:convert';
import 'dart:typed_data';

import 'package:mysql1/mysql1.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import 'VentanaListaProductos.dart';

class Producto{
    int? usuarioID;
    int? productoID;
    String? nombre;
    String? descripcion;
    double? precio;
    Blob? image;
    bool? esPremium;
    //Cosas subasta
    DateTime? fechaFin;
    int? precioInicial;
    int? ultimaOferta;
    Producto({this.usuarioID,this.productoID, this.nombre, this.descripcion, this.precio, this.image, this.esPremium});
    //Producto({this.usuarioID,this.productoID, this.nombre, this.descripcion, this.precio, this.imagePath, this.esPremium, this.fechaFin, this.precioInicial, this.ultimaOferta});
}



class Imagen{
  int? productoID;
  String? nombre;
  Uint8List? image;
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
  int? esEmpresa;
  Usuario({this.usuarioID, this.nombre, this.apellidos, this.nick, this.correo, this.contrasena, this.fechaNacimiento,this.esEmpresa});
}


class Evento {

  int? usuarioID;
  int? idEvento;
  String? direccion;
  String? descripcion;
  String? nombre;
  DateTime? fechaEvento;
  Evento({this.usuarioID, this.idEvento, this.direccion, this.descripcion, this.nombre, this.fechaEvento});

}

class Valoracion
{
  int? id;
  int? idUsuario;
  String? nickUsuarioReviewer;
  String? comentario;
  int? valoracion;
  Valoracion({this.id, this.idUsuario, this.nickUsuarioReviewer, this.comentario, this.valoracion});
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

    await conn?.query('''SELECT producto.*, IMAGEN.image, usuario.esPremium
        FROM producto
        JOIN usuario ON producto.usuarioID = usuario.userID
        JOIN IMAGEN ON producto.pruductoID = IMAGEN.id_producto
        WHERE esSubasta = false
        ORDER BY usuario.esPremium DESC;
      ''').then((results) {
      for (var row in results) {
        Producto producto = Producto(
          usuarioID: row['usuarioID'],
          productoID: row['pruductoID'],
          nombre:row['nombre'],
          descripcion: row['descripcion'],
          precio: row['precio'],
          //Get blob 'image'
          image: row['image'],
          esPremium: row['esPremium'] == 1 ? true : false,
        );

        productos.add(producto);
      }
    });


    return productos;
  }

  Future<List<Producto>> getProductosBasadoPreferencias(Usuario user) async{
    if(conn == null) await conectar();
    String categorias = " ";
    List<Producto> productos = [];
    debugPrint("Obteniendo categorias");
    await getCategoriasUsuario(user).then((result){
      if(result.isEmpty) return;
      result.forEach((element) {
        categorias = categorias + "'$element', ";
      });
      categorias = categorias.substring(0, categorias.length - 2);
      categorias = categorias + " ";

    });

    if(categorias == " ") return await getProductos();

    await conn?.query('''SELECT producto.*, IMAGEN.image, usuario.esPremium
        FROM producto
        JOIN usuario ON producto.usuarioID = usuario.userID
        JOIN IMAGEN ON producto.pruductoID = IMAGEN.id_producto
        WHERE esSubasta = false
        ORDER BY FIELD(categoria,${categorias}) DESC, usuario.esPremium ASC;
    ''').then((results){
      for (var row in results) {
        Producto producto = Producto(
            usuarioID: row['usuarioID'],
            productoID: row['pruductoID'],
            nombre: row['nombre'],
            descripcion: row['descripcion'],
            precio: row['precio'],
            //Get blob 'image'
            image: row['image'],
            //image: row['image'],
            esPremium: row['esPremium'] == 1 ? true : false);
        productos.add(producto);
      }
    });

    return productos;
  }

  Future<List<String>> getCategoriasUsuario(Usuario user)  async{

    if(conn == null) await conectar();
    List<String> categorias = [];
    await conn?.query("select categoria from categorias_usuario where usuarioID = ${user.usuarioID}").then((results) {
      for (var row in results) {
        categorias.add(row[0]);
      }
    });
    return categorias;

  }

  Future<List<Producto>> searchProductos(String query) async {
    print('Executing searchProductos with query: $query');

    if (conn == null) {
      print('Connection is null. Connecting...');
      await conectar();
      print('Connection established.');
    }

    //Elimino los espacios antes y después de las letras, también para obtener ayuda para el próximo cheque
    query=query.trim();

    //Compruebo si query esta toda compuesta por espacios, si es así muestro mensaje de error
    if(query.isEmpty){
      isValid=false;
    }

    List<Producto> productos = [];

    await conn?.query(
      '''
    SELECT producto.*, IMAGEN.image
    FROM producto
    JOIN usuario ON producto.usuarioID = usuario.userID
    JOIN IMAGEN ON producto.pruductoID = IMAGEN.id_producto
    WHERE LOWER(producto.nombre) LIKE ?;
    ''',
      ['%${query.toLowerCase()}%'],
    ).then((results) {

      // Iterar sobre todos los resultados devueltos por la consulta
      for (var row in results) {
        print('Processing row: $row');
        //crear nuevo objecto producton da anadir a la lista
        Producto producto = Producto(
          usuarioID: row['usuarioID'],
          productoID: row['pruductoID'],
          nombre: row['nombre'],
          descripcion: row['descripcion'],
          precio: row['precio'],
          image: row['image'],
          esPremium: row['esPremium'] == 1,
        );

        productos.add(producto);
        print('Created Producto: $producto');
      }
    }).catchError((error) {
      print('Error executing query: $error');
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
          esEmpresa : row[8],

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
          esEmpresa : row[8],
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
          esEmpresa : row[8],
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
    //Blob? image = product.image;
    double? precio = product.precio;
    try {
      await conn?.query("INSERT INTO producto (usuarioID, nombre, descripcion, precio) "
          "VALUES ('$userID', '$nombre', '$descripcion', '$precio'); "
          );

      var id = await conn?.query("SELECT LAST_INSERT_ID() as id;");

      return id!.first['id'];
    }
    catch(e){
      debugPrint(e.toString());
    }
    return -1;
  }


  Future<int> anadirEvento(Evento evento, Usuario user) async{
    if(conn==null) await conectar();
    int userID = user.usuarioID!;
    String? direccion = evento.direccion;
    String? descripcion = evento.descripcion;
    String? nombre = evento.nombre;
    DateTime? fecha = evento.fechaEvento;
    try {
      await conn?.query("INSERT INTO evento (usuarioID, direccion, descripcion, nombre, fecha) "
          "VALUES ('$userID', '$direccion', '$descripcion', '$nombre','$fecha'); "
      );
      return 1;
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

  void hacerEmpresa(int id) async{
    if(conn==null) await conectar();
    await conn?.query("update usuario set esEmpresa = 1 where userID = $id");
  }

  Future<bool> anadirImagen(String nombre, int ID, Uint8List img) async{
    if(conn==null) await conectar();

    try {
      String s = Base64Encoder().convert(img);
      await conn?.query("INSERT INTO imagen (id_producto, nombre, image) "
          "VALUES ('$ID', '$nombre', '$s'); "
      );
    }
    catch(e){
      debugPrint(e.toString());
    }
    return true;
  }

  Future<Blob?> obtenerImagen(int id) async{
    if(conn==null) await conectar();

    Blob? image;

    try {
      await conn?.query("SELECT image FROM IMAGEN WHERE id_producto = $id").then((results) {
        for (var row in results) {
          image = row['image'];

        }
      });
    }
    catch(e){
      debugPrint(e.toString());
    }
    return image;
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

  Future<int> esEmpresa(int id) async {
    if(conn==null) await conectar();
    int esEmpresa = 0;
    await conn?.query("select esEmpresa from usuario where userID = $id").then((results) {
      for (var row in results) {
        esEmpresa = row[0];
      }
    });
    return esEmpresa;
  }


  Future<bool> anadirProductoSubasta(int productID, int precioInicial, DateTime fechaFinal) async {
    if(conn==null) await conectar();
    await conn?.query("INSERT INTO productos_subasta (idProducto, precioInicial, fechaFin) "
        "VALUES ('$productID', '$precioInicial', '$fechaFinal'); "
    );

    return true;
  }

  Future<List<Producto>> getProductosSubasta() async{
    if(conn==null) await conectar();
    List<Producto> productos = [];
    Producto producto;
    await conn?.query('''SELECT p.*, ps.*,i.image, u.esPremium 
                         FROM producto p 
                         JOIN productos_subasta ps ON ps.idProducto = p.pruductoID 
                         JOIN usuario u ON p.usuarioID = u.userID 
                         JOIN imagen i ON p.pruductoID = i.id_producto
                         Order By u.esPremium ASC;''').then((results) => {
      for (var row in results) {
        producto = Producto(
            usuarioID: row['usuarioID'],
            productoID: row['productoID'],
            nombre:row['nombre'],
            descripcion: row['descripcion'],
            precio: row['precio'],
            image: row['image'],
            esPremium: row['esPremium'] == 1 ? true : false,
        ),
        producto.fechaFin = row['fechaFin'],
        producto.precioInicial = row['precioInicial'],
        producto.ultimaOferta = row['ultimaOferta'],

        productos.add(producto)
      }

    });

    return productos;
  }

  Future<List<Valoracion>> getValoraciones(int usuarioID) async{
    if(conn==null) conectar();
    List<Valoracion> comentarios = [];
    Valoracion comentario;
    await conn?.query("""
    SELECT valoracion.*, usuario.nick AS reviewerName
    FROM valoracion
    JOIN usuario ON valoracion.idReviewer = usuario.userID
    WHERE valoracion.idUsuario = $usuarioID;
    """).then((results) => {
      for (var row in results) {
        comentario = Valoracion(
          id: row['id'],
          idUsuario: row['idUsuario'],
          nickUsuarioReviewer: row['reviewerName'],
          comentario: row['comentario'],
          valoracion: row['valoracion'],
        ),
        print(comentario),
        comentarios.add(comentario)
      }
    });
    return comentarios;
  }

  void anadirValoracion(int idUsuario, int idReviewer, String comentario, int valoracion)
  async {
    if(conn==null) conectar();
    await conn?.query("INSERT INTO valoracion (idUsuario, idReviewer, comentario, valoracion) "
        "VALUES ('$idUsuario', '$idReviewer', '$comentario', '$valoracion'); "
    );
  }
}