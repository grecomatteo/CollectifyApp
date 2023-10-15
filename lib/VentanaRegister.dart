import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'package:collectify/VentanaLogin.dart';

void main() {
  runApp(VentanaRegister());
  Conexion().conectar();
}

class VentanaRegister extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegistroUsuariosScreen(),
    );
  }
}

class RegistroUsuariosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de usuarios'),
      ),
      body: RegistroForm(),
    );
  }
}

class RegistroForm extends StatefulWidget {
  @override
  _RegistroFormState createState() => _RegistroFormState();
}

class _RegistroFormState extends State<RegistroForm> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        birthdateController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
  }

  final TextEditingController nickController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[

          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
                labelText: 'Nombre'
            ),
          ),
          TextFormField(
            controller: surnameController,
            decoration: InputDecoration(labelText: 'Apellidos'),
          ),
          TextFormField(
            controller: mailController,
            decoration: InputDecoration(labelText: 'Correo'),
          ),
          TextFormField(
            controller: nickController,
            decoration: InputDecoration(labelText: 'Nombre de usuario'),
          ),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(labelText: 'Contraseña'),
            obscureText: true,
          ),
          TextFormField(
            controller: birthdateController,
            readOnly: true,
            decoration: InputDecoration(
                labelText: 'Fecha de nacimiento',
                suffixIcon: ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Seleccionar Fecha'),
                ),

            ),
          ),
          const SizedBox(height: 50.0),
          ElevatedButton(
            onPressed: () {
              String nick = nickController.text;
              String password = passwordController.text;
              String name = nameController.text;
              String surname = surnameController.text;
              String mail = mailController.text;
              DateTime birthdate = selectedDate;
              if(true){ //Comprueba si los datos del nuevo usuario son validos
                Usuario user = Usuario(
                  usuarioID : 1,
                  nombre: name,
                  apellidos : surname,
                  nick : nick,
                  correo : mail,
                  contrasena : password,
                  fechaNacimiento : birthdate);
              } else {}//mostrar mensaje de error
            },
            child: Text('Registrar'),
          ),
        ],
      ),
    );
  }
}