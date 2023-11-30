import 'package:flutter_test/flutter_test.dart';
import 'package:collectify/ConexionBD.dart';
void main(){

Usuario? u;
 test('Test de conexion', () async {
      expect(await Conexion().conectar(), true);
    });

 test('Test Lista Productos', () async {
      expect(await Conexion().getAllProductos(), isA<List<Producto>>());
    });

 test('Test getUsuarioByID', () async {
   u = await Conexion().getUsuarioByID(1);
      expect( u, isA<Usuario>());
    });

 test('Test getUsuarioByNick', () async {
    u = await Conexion().getUsuarioByNick("admin");
        expect( u, isA<Usuario>());
      });
 test('test Login', () async {
   u = await Conexion().login("admin", "admin");
   expect(u, isA<Usuario>());
 });
 /*
  test('test Registro', () async {
     bool success = await Conexion( ).registrarUsuario("Pepe", "Garcia", "pep02", "aaa@gmail.com" , "contraseña", DateTime(2000,12,12));
     expect(success, isTrue);
    });
    //Esto literalmente solo se puede hacer 1 vez
*/

}