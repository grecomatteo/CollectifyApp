import 'dart:convert';
import 'dart:typed_data';

import 'package:mysql1/mysql1.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import 'VentanaListaProductos.dart';

class Producto {
  int? usuarioID;
  int? productoID;
  String? usuarioNick;
  String? nombre;
  String? descripcion;
  double? precio;
  Blob? image;
  bool? esPremium;
  bool? esSubasta;
  //Cosas subasta
  DateTime? fechaFin;
  int? precioInicial;
  int? ultimaOferta;
  int? idUserUltimaPuja;
  String? categoria;
  String? nombreUsuarioUltimaPuja;
  Producto(
      {this.usuarioID,
      this.productoID,
      this.usuarioNick,
      this.nombre,
      this.descripcion,
      this.precio,
      this.image,
      this.esPremium,
      this.esSubasta,
      this.categoria});
//Producto({this.usuarioID,this.productoID, this.nombre, this.descripcion, this.precio, this.imagePath, this.esPremium, this.fechaFin, this.precioInicial, this.ultimaOferta});
}

class Imagen {
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
  Usuario(
      {this.usuarioID,
      this.nombre,
      this.apellidos,
      this.nick,
      this.correo,
      this.contrasena,
      this.fechaNacimiento,
      this.esEmpresa});
}

class Evento {
  int? usuarioID;
  int? idEvento;
  String? direccion;
  String? descripcion;
  String? nombre;
  DateTime? fechaEvento;
  Evento(
      {this.usuarioID,
      this.idEvento,
      this.direccion,
      this.descripcion,
      this.nombre,
      this.fechaEvento});
}

class Valoracion {
  int? id;
  int? idUsuario;
  String? nickUsuarioReviewer;
  String? comentario;
  int? valoracion;
  Valoracion(
      {this.id,
      this.idUsuario,
      this.nickUsuarioReviewer,
      this.comentario,
      this.valoracion});
}

class Conexion {
  static MySqlConnection? conn;

  static List<Producto> productosVentaBasadoPreferencias = [];
  static List<Producto> productosSubastaBasadoPreferencias = [];
  static List<Evento> eventos = [];

  Future<bool> conectar() async {
    debugPrint("Conectando");
    if (conn != null) {
      return true;
    }

    try {
      conn = await MySqlConnection.connect(ConnectionSettings(
        host: "143.47.181.8",
        port: 3306,
        user: "root",
        password: "root",
        db: "collectifydb",
        //Quiero que sea insensible a mayusculas
        //useCompression: false,


      ));

      debugPrint("Conectado");
      return true;
    } catch (e) {
      debugPrint(e.toString() + "Error al conectar");
      return false;
    }
  }

  Future<List<Producto>> getProductosVenta() async {
    if (conn == null) await conectar();
    List<Producto> productos = [];

    await conn?.query('''SELECT producto.*, imagen.image, usuario.esPremium, usuario.nick
        FROM producto
        JOIN usuario ON producto.usuarioID = usuario.userID
        JOIN imagen ON producto.pruductoID = imagen.id_producto
        WHERE esSubasta = false
        ORDER BY usuario.esPremium DESC;
      ''').then((results) {
      for (var row in results) {
        Producto producto = Producto(
          usuarioID: row['usuarioID'],
          productoID: row['pruductoID'],
          nombre: row['nombre'],
          descripcion: row['descripcion'],
          precio: row['precio'],
          usuarioNick: row['nick'],
          //Get blob 'image'
          image: row['image'],
          esPremium: row['esPremium'] == 1 ? true : false,
          esSubasta: row['esSubasta'] == 1 ? true : false,
          categoria: row['categoria'],
        );

        productos.add(producto);
      }
    });

    return productos;
  }

  Future<List<Producto>> getAllProductos() async {
    if (conn == null) await conectar();
    List<Producto> productos = [];

    await conn?.query('''SELECT producto.*, imagen.image, usuario.esPremium, usuario.nick
        FROM producto
        JOIN usuario ON producto.usuarioID = usuario.userID
        JOIN imagen ON producto.pruductoID = imagen.id_producto
        ORDER BY usuario.esPremium DESC;
      ''').then((results) {
      for (var row in results) {
        Producto producto = Producto(
          usuarioID: row['usuarioID'],
          productoID: row['pruductoID'],
          usuarioNick: row['nick'],
          nombre: row['nombre'],
          descripcion: row['descripcion'],
          precio: row['precio'],
          //Get blob 'image'
          image: row['image'],
          esPremium: row['esPremium'] == 1 ? true : false,
          esSubasta: row['esSubasta'] == 1 ? true : false,
          categoria: row['categoria'],
        );

        productos.add(producto);
      }
    });

    return productos;
  }

  Future<List<Producto>> getProductoPorCategoria(String categoria) async {
    if (conn == null) await conectar();
    List<Producto> productos = [];

    await conn?.query('''SELECT producto.*, imagen.image, usuario.esPremium, usuario.nick
      FROM producto
      JOIN usuario ON producto.usuarioID = usuario.userID
      JOIN imagen ON producto.pruductoID = imagen.id_producto
      WHERE producto.categoria = ?
      ORDER BY usuario.esPremium DESC;
    ''', [categoria]).then((results) {
      for (var row in results) {
        Producto producto = Producto(
          usuarioID: row['usuarioID'],
          productoID: row['pruductoID'],
          usuarioNick: row['nick'],
          nombre: row['nombre'],
          descripcion: row['descripcion'],
          precio: row['precio'],
          // Get blob 'image'
          image: row['image'],
          esPremium: row['esPremium'] == 1 ? true : false,
          esSubasta: row['esSubasta'] == 1 ? true : false,
          categoria: row['categoria'],
        );

        productos.add(producto);
      }
    });

    return productos;
  }

  Future<List<Producto>> getSubastaPorCategoria(String categoria) async {
    if (conn == null) await conectar();
    List<Producto> productos = [];

    await conn?.query('''SELECT p.*, ps.*, imagen.image, usuario.esPremium, usuario.nick
      FROM producto p
      JOIN productos_subasta ps ON p.pruductoID = ps.idProducto
      JOIN usuario ON p.usuarioID = usuario.userID
      JOIN imagen ON p.pruductoID = imagen.id_producto
      WHERE p.categoria = ?
      ORDER BY usuario.esPremium DESC;
    ''', [categoria]).then((results) {
      for (var row in results) {
        Producto producto = Producto(
          usuarioID: row['usuarioID'],
          productoID: row['pruductoID'],
          usuarioNick: row['nick'],
          nombre: row['nombre'],
          descripcion: row['descripcion'],
          precio: row['precio'],
          // Get blob 'image'
          image: row['image'],
          esPremium: row['esPremium'] == 1 ? true : false,
          esSubasta: row['esSubasta'] == 1 ? true : false,
          categoria: row['categoria'],
        );
        producto.fechaFin = row['fechaFin'];
        producto.precioInicial = row['precioInicial'];
        producto.ultimaOferta = row['ultimaOferta'];
        producto.idUserUltimaPuja = row['idUsuarioUltPuja'];

        productos.add(producto);
      }
    });

    return productos;
  }

  Future<List<Producto>> getProductosBasadoPreferencias(Usuario user) async {
    if (productosVentaBasadoPreferencias.isNotEmpty) {
      return productosVentaBasadoPreferencias;
    }
    if (conn == null) await conectar();
    String categorias = " ";
    List<Producto> productos = [];
    debugPrint("Obteniendo categorias");
    await getCategoriasUsuario(user).then((result) {
      if (result.isEmpty) return;
      result.forEach((element) {
        categorias = categorias + "'$element', ";
      });
      categorias = categorias.substring(0, categorias.length - 2);
      categorias = categorias + " ";
    });

    if (categorias == " ") return await getProductosVenta();

    await conn?.query('''SELECT producto.*, imagen.image, usuario.esPremium, usuario.nick
        FROM producto
        JOIN usuario ON producto.usuarioID = usuario.userID
        JOIN imagen ON producto.pruductoID = imagen.id_producto
        WHERE esSubasta = false
        ORDER BY FIELD(categoria,${categorias}) DESC, usuario.esPremium ASC;
    ''').then((results) {
      for (var row in results) {
        Producto producto = Producto(
            usuarioID: row['usuarioID'],
            productoID: row['pruductoID'],
            usuarioNick: row['nick'],
            nombre: row['nombre'],
            descripcion: row['descripcion'],
            precio: row['precio'],
            //Get blob 'image'
            image: row['image'],
            esPremium: row['esPremium'] == 1 ? true : false,
            esSubasta: row['esSubasta'] == 1 ? true : false,
            categoria: row['categoria']
        );
        productos.add(producto);
      }
    });
    productosVentaBasadoPreferencias = productos;
    return productos;
  }

  Future<List<Producto>> getProductosSubastaBasadoPreferencias(
      Usuario user) async {
    if (productosSubastaBasadoPreferencias.isNotEmpty) {
      return productosSubastaBasadoPreferencias;
    }
    if (conn == null) await conectar();
    String categorias = " ";
    List<Producto> productos = [];
    Producto producto;
    debugPrint("Obteniendo categorias");
    await getCategoriasUsuario(user).then((result) {
      if (result.isEmpty) return;
      for (var element in result) {
        categorias = "$categorias'$element', ";
      }
      categorias = categorias.substring(0, categorias.length - 2);
      categorias = "$categorias ";
    });
    if (categorias == " ") return await getProductosSubasta();
    await conn?.query('''SELECT p.*, ps.*,i.image, u.esPremium, u.nick
        FROM producto p 
        JOIN productos_subasta ps ON ps.idProducto = p.pruductoID 
        JOIN usuario u ON p.usuarioID = u.userID 
        JOIN imagen i ON p.pruductoID = i.id_producto
        ORDER BY FIELD(categoria,$categorias) DESC, u.esPremium ASC;
    ''').then((results) => {
          for (var row in results)
            {
              producto = Producto(
                usuarioID: row['usuarioID'],
                productoID: row['pruductoID'],
                usuarioNick: row['nick'],
                nombre: row['nombre'],
                descripcion: row['descripcion'],
                precio: row['precio'],
                image: row['image'],
                esPremium: row['esPremium'] == 1 ? true : false,
                esSubasta: row['esSubasta'] == 1 ? true : false,
                categoria: row['categoria'],
              ),
              productos.add(producto),
              producto.fechaFin = row['fechaFin'],
              producto.precioInicial = row['precioInicial'],
              producto.ultimaOferta = row['ultimaOferta'],
              producto.idUserUltimaPuja = row['idUsuarioUltPuja']
            }
        });
    productosSubastaBasadoPreferencias = productos;
    return productos;
  }


  Future<List<Producto>> getPujasRealizadas(Usuario user) async {
    if (conn == null) await conectar();
    List<Producto> productos = [];
    Producto producto;
    await conn?.query('''SELECT p.*, ps.*,i.image, u.esPremium, u.nick
        FROM producto p 
        JOIN productos_subasta ps ON ps.idProducto = p.pruductoID 
        JOIN usuario u ON p.usuarioID = u.userID 
        JOIN imagen i ON p.pruductoID = i.id_producto
        WHERE ps.idUsuarioUltPuja = ${user.usuarioID}
        ORDER BY fechaFin ASC;
    ''').then((results) => {
      for (var row in results)
        {
          producto = Producto(
            usuarioID: row['usuarioID'],
            productoID: row['pruductoID'],
            usuarioNick: row['nick'],
            nombre: row['nombre'],
            descripcion: row['descripcion'],
            precio: row['precio'],
            image: row['image'],
            esPremium: row['esPremium'] == 1 ? true : false,
            esSubasta: row['esSubasta'] == 1 ? true : false,
            categoria: row['categoria'],
          ),
          producto.fechaFin = row['fechaFin'],
          producto.precioInicial = row['precioInicial'],
          producto.ultimaOferta = row['ultimaOferta'],
          producto.idUserUltimaPuja = row['idUsuarioUltPuja'],
          productos.add(producto)
        }
    });
    return productos;
  }

  Future<List<String>> getCategoriasUsuario(Usuario user) async {
    if (conn == null) await conectar();
    List<String> categorias = [];
    await conn
        ?.query(
            "select categoria from categorias_usuario where usuarioID = ${user.usuarioID}")
        .then((results) {
      for (var row in results) {
        categorias.add(row[0]);
      }
    });
    return categorias;
  }



  Future<List<Producto>> searchProductos(String query) async {

    if (conn == null) {
      await conectar();
    }

    //Elimino los espacios antes y después de las letras, también para obtener ayuda para el próximo cheque
    query = query.trim();

    //Compruebo si query esta toda compuesta por espacios, si es así muestro mensaje de error
    if (query.isEmpty) {
      isValid = false;
    }

    List<Producto> productos = [];

    // Usare il metodo rawQuery di SQL per filtrare i prodotti in base alla query
    await conn?.query(
      '''
    SELECT producto.*, imagen.image, usuario.nick
    FROM producto
    JOIN usuario ON producto.usuarioID = usuario.userID
    JOIN imagen ON producto.pruductoID = imagen.id_producto
    WHERE NOT producto.esSubasta AND LOWER(producto.descripcion) LIKE ?;
    ''',
      ['%${query.toLowerCase()}%'],
    ).then((results) {
      //print('Query executed successfully. Results: $results');

      // Iterar sobre todos los resultados devueltos por la consulta
      for (var row in results) {
        //crear nuevo objecto producton da anadir a la lista
        Producto producto = Producto(
          usuarioID: row['usuarioID'],
          productoID: row['pruductoID'],
          usuarioNick: row['nick'],
          nombre: row['nombre'],
          descripcion: row['descripcion'],
          precio: row['precio'],
          image: row['image'],
          esPremium: row['esPremium'] == 1,
          esSubasta: row['esSubasta'] == 1,
          categoria: row['categoria'],
        );

        productos.add(producto);
      }
    }).catchError((error) {
    });

    return productos;
  }
  Future<List<Producto>> searchSubastas(String query) async {

    if (conn == null) {
      await conectar();
    }

    //Elimino los espacios antes y después de las letras, también para obtener ayuda para el próximo cheque
    query = query.trim();

    //Compruebo si query esta toda compuesta por espacios, si es así muestro mensaje de error
    if (query.isEmpty) {
      isValid = false;
    }

    List<Producto> productos = [];

    // Usare il metodo rawQuery di SQL per filtrare i prodotti in base alla query
    await conn?.query(
      '''
    SELECT producto.*,ps.*, imagen.image, usuario.nick
    FROM producto 
    JOIN productos_subasta ps ON producto.pruductoID = ps.idProducto
    JOIN usuario ON producto.usuarioID = usuario.userID
    JOIN imagen ON producto.pruductoID = imagen.id_producto
    WHERE LOWER(producto.descripcion) LIKE ?;
    ''',
      ['%${query.toLowerCase()}%'],
    ).then((results) {
      //print('Query executed successfully. Results: $results');

      // Iterar sobre todos los resultados devueltos por la consulta
      for (var row in results) {
        //crear nuevo objecto producton da anadir a la lista
        Producto producto = Producto(
          usuarioID: row['usuarioID'],
          productoID: row['pruductoID'],
          usuarioNick: row['nick'],
          nombre: row['nombre'],
          descripcion: row['descripcion'],
          precio: row['precio'],
          image: row['image'],
          esPremium: row['esPremium'] == 1,
          esSubasta: row['esSubasta'] == 1,
          categoria: row['categoria'],
        );
        producto.fechaFin = row['fechaFin'];
        producto.precioInicial = row['precioInicial'];
        producto.ultimaOferta = row['ultimaOferta'];
        producto.idUserUltimaPuja = row['idUsuarioUltPuja'];
        productos.add(producto);
      }
    }).catchError((error) {
    });

    return productos;
  }


  Future<List<Usuario>> getUsuarios() async {
    if (conn == null) await conectar();
    List<Usuario> usuarios = [];
    await conn?.query('select * from usuario').then((results) {
      for (var row in results) {
        Usuario usuario = Usuario(
          usuarioID: row[0],
          nombre: row[1],
          apellidos: row[2],
          nick: row[3],
          correo: row[4],
          contrasena: row[5],
          fechaNacimiento: row[6],
          esEmpresa: row[8],
        );
        usuarios.add(usuario);
      }
    });
    return usuarios;
  }

  Future<Usuario?> getUsuarioByID(int? id) async {
    Usuario? usuario;
    if (conn == null) await conectar();

    await conn
        ?.query("select * from usuario where userID = $id limit 1")
        .then((results) {
      for (var row in results) {
        usuario = Usuario(
          usuarioID: row[0],
          nombre: row[1],
          apellidos: row[2],
          nick: row[3],
          correo: row[4],
          contrasena: row[5],
          fechaNacimiento: row[6],
          esEmpresa: row[8],
        );
      }
    });

    if (usuario == null) throw new Exception("Usuario no encontrado");
    return usuario;
  }
  Future<Usuario?> getUsuarioByEmail(String email) async{
    Usuario? usuario;
    if (conn == null) await conectar();

    await conn
        ?.query("select * from usuario where correo = '$email' limit 1")
        .then((results) {
      for (var row in results) {
        usuario = Usuario(
          usuarioID: row[0],
          nombre: row[1],
          apellidos: row[2],
          nick: row[3],
          correo: row[4],
          contrasena: row[5],
          fechaNacimiento: row[6],
          esEmpresa: row[8],
        );
      }
    });
    if (usuario == null) return null;
    return usuario;

  }

  Future<Usuario?> getUsuarioByNick(String nick) async {
    Usuario? usuario;
    if (conn == null) await conectar();

    await conn
        ?.query("select * from usuario where nick = '$nick' limit 1")
        .then((results) {
      for (var row in results) {
        usuario = Usuario(
          usuarioID: row[0],
          nombre: row[1],
          apellidos: row[2],
          nick: row[3],
          correo: row[4],
          contrasena: row[5],
          fechaNacimiento: row[6],
          esEmpresa: row[8],
        );
      }
    });
    if (usuario == null) return null;
    return usuario;
  }

  Future<Usuario?> login(String nick, String contrasena) async {
    if (conn == null) await conectar();

    Usuario? usuario = await getUsuarioByNick(nick);

    if (usuario == null) throw Exception("Usuario no encontrado");

    if (usuario.contrasena == contrasena) {
      return usuario;
    } else {
      throw Exception("Contraseña incorrecta");
    }
  }

  Future<int> getNumeroUsuarios() async {
    if (conn == null) await conectar();
    int numeroUsuarios = 0;
    await conn?.query('select count(*) from usuario').then((results) {
      for (var row in results) {
        numeroUsuarios = row[0];
      }
    });
    return numeroUsuarios;
  }

  Future<int> getNumeroProductos() async {
    if (conn == null) await conectar();
    int numeroProductos = 0;
    await conn
        ?.query('select count(*) as product_count from producto')
        .then((results) {
      numeroProductos = results.first['product_count'];
    });
    return numeroProductos;
  }

  Future<bool> registrarUsuario(String nombre, String apellido, String nick,
      String correo, String contrasena, DateTime fechaNac) async {
    if (conn == null) await conectar();
    try {
      await conn?.query(
          "insert into usuario(nombre,apellidos,nick,correo,contrasena,fechaNac) values('$nombre', '$apellido', '$nick', '$correo', '$contrasena', '$fechaNac')");
    } catch (e) {
      debugPrint(e.toString());

      throw Exception(e.toString());

    }

    return true;
  }

  Future<int> anadirProducto(Producto product, Usuario user) async {
    if (conn == null) await conectar();
    int userID = user.usuarioID!;
    String? nombre = product.nombre;
    String? descripcion = product.descripcion;
    //Blob? image = product.image;
    double? precio = product.precio;
    String? categoria = product.categoria;
    try {
      await conn?.query(
          "INSERT INTO producto (usuarioID, nombre, descripcion, precio, categoria) "
          "VALUES ('$userID', '$nombre', '$descripcion', '$precio', (SELECT categoria FROM categorias WHERE categoria = '$categoria')); ");

      var id = await conn?.query("SELECT LAST_INSERT_ID() as id;");

      return id!.first['id'];
    } catch (e) {
      debugPrint(e.toString());
    }
    return -1;
  }

  Future<int> anadirEvento(Evento evento, Usuario user) async {
    if (conn == null) await conectar();
    int userID = user.usuarioID!;
    String? direccion = evento.direccion;
    String? descripcion = evento.descripcion;
    String? nombre = evento.nombre;
    DateTime? fecha = evento.fechaEvento;
    try {
      await conn?.query(
          "INSERT INTO evento (usuarioID, direccion, descripcion, nombre, fecha) "
          "VALUES ('$userID', '$direccion', '$descripcion', '$nombre','$fecha'); ");
      return 1;
    } catch (e) {
      debugPrint(e.toString());
    }
    return -1;
  }

  void hacerPremium(int id) async {
    if (conn == null) await conectar();
    await conn?.query("update usuario set esPremium = 1 where userID = $id");
  }

  void hacerEmpresa(int id) async {
    if (conn == null) await conectar();
    await conn?.query("update usuario set esEmpresa = 1 where userID = $id");
  }

  Future<bool> anadirImagen(String nombre, int ID, Uint8List img) async {
    if (conn == null) await conectar();

    try {
      String s = Base64Encoder().convert(img);
      await conn?.query("INSERT INTO imagen (id_producto, nombre, image) "
          "VALUES ('$ID', '$nombre', '$s'); ");
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }

  Future<Blob?> obtenerImagen(int id) async {
    if (conn == null) await conectar();

    Blob? image;

    try {
      await conn
          ?.query("SELECT image FROM imagen WHERE id_producto = $id")
          .then((results) {
        for (var row in results) {
          image = row['image'];
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
    return image;
  }

  Future<int> esPremium(int id) async {
    if (conn == null) await conectar();
    int esPremium = 0;
    await conn
        ?.query("select esPremium from usuario where userID = $id")
        .then((results) {
      for (var row in results) {
        esPremium = row[0];
      }
    });
    return esPremium;
  }

  Future<int> esEmpresa(int id) async {
    if (conn == null) await conectar();
    int esEmpresa = 0;
    await conn
        ?.query("select esEmpresa from usuario where userID = $id")
        .then((results) {
      for (var row in results) {
        esEmpresa = row[0];
      }
    });
    return esEmpresa;
  }

  Future<bool> anadirProductoSubasta(
      int productID, int precioInicial, DateTime fechaFinal) async {
    if (conn == null) await conectar();
    await conn?.query(
        "INSERT INTO productos_subasta (idProducto, precioInicial, fechaFin) "
        "VALUES ('$productID', '$precioInicial', '$fechaFinal'); ");

    return true;
  }
  Future<bool> addUltimaPuja(int productID, int userID, String nombre, int ultimaOferta) async {
    if (conn == null) await conectar();
    await conn?.query(
        "UPDATE productos_subasta SET idUsuarioUltPuja = $userID, nombreUsuarioUltPuja = '$nombre' ,ultimaOferta = $ultimaOferta WHERE idProducto = $productID; "
    ).then((results) => {print("Puja añadida")});


    return true;
  }
  Future<Producto> getSubastaById( int id) async {
    if (conn == null) await conectar();
    Producto producto = Producto();
    await conn?.query('''SELECT p.*, ps.*,i.image, u.esPremium, u.nick
        FROM producto p 
        JOIN productos_subasta ps ON ps.idProducto = p.pruductoID 
        JOIN usuario u ON p.usuarioID = u.userID 
        JOIN imagen i ON p.pruductoID = i.id_producto
        WHERE p.pruductoID = $id;
    ''').then((results) => {
      for (var row in results)
        {
          producto = Producto(
            usuarioID: row['usuarioID'],
            productoID: row['pruductoID'],
            usuarioNick: row['nick'],
            nombre: row['nombre'],
            descripcion: row['descripcion'],
            precio: row['precio'],
            image: row['image'],
            esPremium: row['esPremium'] == 1 ? true : false,
            esSubasta: row['esSubasta'] == 1 ? true : false,
            categoria: row['categoria'],
          ),
          producto.fechaFin = row['fechaFin'],
          producto.precioInicial = row['precioInicial'],
          producto.ultimaOferta = row['ultimaOferta'],
          producto.idUserUltimaPuja = row['idUsuarioUltPuja'],
          producto.nombreUsuarioUltimaPuja = row['nombreUsuarioUltPuja']

        }
    });
    return producto;
  }

  Future<List<Producto>> getProductosSubasta() async {
    if (conn == null) await conectar();
    List<Producto> productos = [];
    Producto producto;
    await conn?.query('''SELECT p.*, ps.*,i.image, u.esPremium, u.nick
                         FROM producto p 
                         JOIN productos_subasta ps ON ps.idProducto = p.pruductoID 
                         JOIN usuario u ON p.usuarioID = u.userID 
                         JOIN imagen i ON p.pruductoID = i.id_producto
                         Order By u.esPremium ASC;''').then((results) => {
          for (var row in results)
            {
              producto = Producto(
                usuarioID: row['usuarioID'],
                productoID: row['pruductoID'],
                usuarioNick: row['nick'],
                nombre: row['nombre'],
                descripcion: row['descripcion'],
                precio: row['precio'],
                image: row['image'],
                esPremium: row['esPremium'] == 1 ? true : false,
                esSubasta: row['esSubasta'] == 1 ? true : false,
                categoria: row['categoria'],
              ),
              producto.fechaFin = row['fechaFin'],
              producto.precioInicial = row['precioInicial'],
              producto.ultimaOferta = row['ultimaOferta'],
              producto.idUserUltimaPuja = row['idUsuarioUltPuja'],
              productos.add(producto)
            }
        });

    return productos;
  }

  Future<List<Valoracion>> getValoraciones(int usuarioID) async {
    if (conn == null) conectar();
    List<Valoracion> comentarios = [];
    Valoracion comentario;
    await conn?.query("""
    SELECT valoracion.*, usuario.nick AS reviewerName
    FROM valoracion
    JOIN usuario ON valoracion.idReviewer = usuario.userID
    WHERE valoracion.idUsuario = $usuarioID;
    """).then((results) => {
          for (var row in results)
            {
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

  void anadirValoracion(
      int idUsuario, int idReviewer, String comentario, int valoracion) async {
    if (conn == null) conectar();
    await conn?.query(
        "INSERT INTO valoracion (idUsuario, idReviewer, comentario, valoracion) "
        "VALUES ('$idUsuario', '$idReviewer', '$comentario', '$valoracion'); ");
  }

  Future<List<Evento>> getListaEventos() async {
    if(eventos.isNotEmpty) return eventos;
    if (conn == null) await conectar();
    List<Evento> eventosAux = [];
    Evento evento;
    await conn?.query(
      "SELECT * FROM evento;"
    ).then((results){
      for(var row in results){

        evento = Evento(
          usuarioID: row['usuarioID'],
          idEvento: row['idEvento'],
          direccion: row['direccion'],
          descripcion: row['descripcion'],
          nombre: row['nombre'],
          fechaEvento: row['fechaEvento'],
        );
        eventosAux.add(evento);
      }
    });
    eventos = eventosAux;
    return eventos;
  }
}
