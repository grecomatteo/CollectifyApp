import 'package:collectify/VentanaLogin.dart';
import 'package:flutter/material.dart';
import 'ConexionBD.dart';

class VentanaRegister extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RegistroForm(),
      backgroundColor: Colors.black,
    );
  }
}

class RegistroForm extends StatefulWidget {
  @override
  _RegistroFormState createState() => _RegistroFormState();
}

class _RegistroFormState extends State<RegistroForm> {
  DateTime selectedDate = DateTime.now();
  String _isValidEmail = "true";
  bool _isValidNick = true;
  bool ok = true;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        birthdateController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void _validateEmail(String email) {

    final emailRegExp = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if(emailRegExp.hasMatch(email)){
      Conexion().getUsuarioByEmail(email).then((value) => setState(() {
        if(value!=null)
          _isValidEmail = "El correo ya esta en uso";
        else
          _isValidEmail = "true";
        }));
    }
    else {
      setState(() {
        _isValidEmail = "Ingrese un correo valido";
      });
    }

  }

  void _validateNick(String nick) {
    //Comprobar si el nick tiene espacios
    if (nick.contains(' ')) {
      setState(() {
        _isValidNick = false;
      });
      return;
    }
    Conexion().getUsuarioByNick(nick).then((value) => setState(() {
          _isValidNick = value == null;
        }));
  }

  final TextEditingController nickController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();

  bool esEmpresa = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const SizedBox(height: 50),
              const Text(
                'Bienvenido a',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Aeonik',
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(30),
                //height: 80,
                transformAlignment: Alignment.center,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/assets/collectify.png'),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
              child: Container(
                  height: 320,
                  child: ShaderMask(
                      shaderCallback: (Rect rect) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.purple,
                            Colors.transparent,
                            Colors.transparent,
                            Colors.purple
                          ],
                          stops: [
                            0.0,
                            0.1,
                            0.9,
                            1.0
                          ], // 10% purple, 80% transparent, 10% purple
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.dstOut,
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(10.0),
                        children: [
                          const SizedBox(
                            height: 25,
                          ),
                          TextFormField(
                              controller: nameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Nombre',
                                labelStyle: TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 0.4)),
                                filled: true,
                                fillColor: Color.fromRGBO(52, 52, 52, 1),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(179, 255, 119, 1),
                                      width: 2.0),
                                ),
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                              controller: surnameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Apellidos',
                                labelStyle: TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 0.4)),
                                filled: true,
                                fillColor: Color.fromRGBO(52, 52, 52, 1),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(179, 255, 119, 1),
                                      width: 2.0),
                                ),
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                              controller: mailController,
                              style: const TextStyle(color: Colors.white),
                              onChanged: _validateEmail,
                              decoration: const InputDecoration(
                                labelText: 'Correo',
                                labelStyle: TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 0.4)),
                                filled: true,
                                fillColor: Color.fromRGBO(52, 52, 52, 1),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(179, 255, 119, 1),
                                      width: 2.0),
                                ),
                              )),
                          if (_isValidEmail!="true")
                             Text(
                                _isValidEmail.toString(),
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.red)),

                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                              controller: nickController,
                              onChanged: _validateNick,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Nick',
                                labelStyle: TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 0.4)),
                                filled: true,
                                fillColor: Color.fromRGBO(52, 52, 52, 1),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(179, 255, 119, 1),
                                      width: 2.0),
                                ),
                              )),
                          if (!_isValidNick)
                            const Text(
                                'Este Nick ya esta en uso. Pruebe con otro',
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.red)),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: passwordController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              labelStyle: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 0.4)),
                              filled: true,
                              fillColor: Color.fromRGBO(52, 52, 52, 1),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(179, 255, 119, 1),
                                    width: 2.0),
                              ),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 2),
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(52, 52, 52, 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: TextFormField(
                              controller: birthdateController,
                              style: const TextStyle(color: Colors.white),
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Fecha de nacimiento',
                                suffixStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Aeonik',
                                ),
                                suffixIcon: ElevatedButton(
                                  onPressed: () => _selectDate(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromRGBO(0, 0, 0, 1),
                                    minimumSize: const Size(150, 50),
                                    alignment: Alignment.center,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(20.0),
                                  ),
                                  child: const Text(
                                    'Seleccionar Fecha',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Aeonik',
                                    ),
                                  ),
                                ),
                                labelStyle: TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 0.4)),
                                filled: true,
                                fillColor: Color.fromRGBO(52, 52, 52, 1),
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(179, 255, 119, 1),
                                      width: 2.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: esEmpresa,
                                onChanged: (e) {
                                  setState(() {
                                    esEmpresa = e!;
                                  });
                                },
                              ),
                              const Text(
                                "Es empresa",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Aeonik',
                                ),
                              ),
                            ],
                          ),
                        ],
                      )))),
          Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(254, 111, 31, 1),
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                child: IconButton(
                  onPressed: () async {
                    final nick = nickController.text;
                    final password = passwordController.text;
                    final name = nameController.text;
                    final surname = surnameController.text;
                    final mail = mailController.text;
                    final birthdate = selectedDate;

                    //Comprueba si los campos del nuevo usuario son correctos
                    if (_isValidEmail!="true") {
                      showErrorDialog(context, _isValidEmail);
                      return;
                    }

                    if (!_isValidNick) {
                      showErrorDialog(
                          context, 'Este Nick ya esta en uso. Pruebe con otro');
                      return;
                    }
                    if (birthdateController.text == '') {
                      showErrorDialog(context,
                          'Por favor, ingrese una fecha de nacimiento.');
                      return;
                    }
                    if (nameController.text == '') {
                      showErrorDialog(context, 'Por favor, ingrese un nombre.');
                      return;
                    }
                    if (surnameController.text == '') {
                      showErrorDialog(
                          context, 'Por favor, ingrese un apellido.');
                      return;
                    }
                    if (passwordController.text == '') {
                      showErrorDialog(
                          context, 'Por favor, ingrese una contraseña.');
                      return;
                    }
                    if (nickController.text == '') {
                      showErrorDialog(context, 'Por favor, ingrese un nick.');
                      return;
                    }

                    try {
                      await Conexion().registrarUsuario(
                          name, surname, nick, mail, password, birthdate);
                      if (esEmpresa) {
                        await Conexion().getUsuarioByNick(nick).then((results) {
                          int? id = results?.usuarioID;
                          Conexion().hacerEmpresa(id!);
                        });

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VentanaLogin()));
                      }
                    } catch (e) {
                      //Mostrar cuadro de error
                      showErrorDialog(context, e.toString());
                    }
                  },
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  color: Colors.white,
                  iconSize: 40,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Ya eres miembro?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Aeonik',
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VentanaLogin()));
                    },
                    child: const Text(
                      'Inicia sesión',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Aeonik',
                        color: Color.fromRGBO(254, 111, 31, 1),
                      ),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

void showErrorDialog(BuildContext context, String error) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(error),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Aceptar'))
          ],
        );
      });
}
