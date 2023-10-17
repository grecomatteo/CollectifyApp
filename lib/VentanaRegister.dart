import 'package:collectify/VentanaListaProductos.dart';
import 'package:collectify/VentanaLogin.dart';
import 'package:flutter/material.dart';

import 'ConexionBD.dart';

void main() {
  runApp(VentanaRegister());
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
  bool _isValidEmail = true;
  bool _isValidNick = true;
  bool ok = true;

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

  void _validateEmail(String email){
    final emailRegExp = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    setState(() {
      _isValidEmail = emailRegExp.hasMatch(email);
    });
  }
  void _validateNick(String nick) {
    final user = Conexion().getUsuarioByNick(nick);
    setState(() {
      _isValidNick = user == null;
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
            decoration: InputDecoration(labelText: 'Nombre'),
          ),
          TextFormField(
            controller: surnameController,
            decoration: InputDecoration(labelText: 'Apellidos'),
          ),
          TextFormField(
            controller: mailController,
            onChanged: _validateEmail,
            decoration: InputDecoration(
                labelText: 'Correo',
            ),
          ),
          if (!_isValidEmail)
            Text('Por favor, ingrese un correo electrónico válido.',
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.red)
            ),
          TextFormField(
            controller: nickController,
            onChanged: _validateNick,
            decoration: InputDecoration(labelText: 'Nombre de usuario'),
          ),
          if (!_isValidNick)
            Text('Este Nick ya esta en uso. Pruebe con otro',
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.red)
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
            onPressed: () async {
              final nick = nickController.text;
              final password = passwordController.text;
              final name = nameController.text;
              final surname = surnameController.text;
              final mail = mailController.text;
              final birthdate = selectedDate;

              //Comprueba si los campos del nuevo usuario son correctos
              if(_isValidEmail == true && _isValidNick == true && birthdateController.text!= '' && nameController.text!= '' && surnameController.text!= '' && passwordController.text!= ''  && birthdateController.text!= ''){
                 if(await Conexion().registrarUsuario(name, surname, nick, mail, password, birthdate)) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VentanaLogin()));
                }
              }
              else DiagnosticsNode.message('Alguno de los campos es erroneo o esta vacio. Haga el favor de comprobarlos.');
            },
            child: Text('Registrar'),
          ),
        ],
      ),
    );
  }

}