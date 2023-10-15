import 'package:collectify/ConexionBD.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(VentanaRegister());
}

class VentanaRegister extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        dateNacController.text= "${selectedDate.toLocal()}".split(' ')[0];
      });
  }

  final TextEditingController nickController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController dateNacController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[

          TextFormField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Nombre'),
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
            controller: dateNacController,
            decoration: InputDecoration(
                labelText: 'Fecha de nacimiento',
                hintText : "${selectedDate.toLocal()}".split(' ')[0]
            ),
          ),
          ElevatedButton(
            onPressed: () => _selectDate(context),
            child: Text('Seleccionar Fecha'),
          ),
          //SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              // Aquí puedes realizar el registro del usuario
              final nick = nickController.text;
              final password = passwordController.text;
              final name = nameController.text;
              final surname = surnameController.text;

              // Realiza acciones de registro aquí
            },
            child: Text('Registrar'),
          ),
        ],
      ),
    );
  }

}