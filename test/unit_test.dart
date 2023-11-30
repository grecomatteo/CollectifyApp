import 'package:flutter_test/flutter_test.dart';
import 'package:collectify/ConexionBD.dart';
void main(){


 test('Test de conexion', () async {
      expect(await Conexion().conectar(), true);
    });

 test('Test Lista Productos', () async {
      expect(await Conexion().getAllProductos(), isA<List<Producto>>());
    });

}