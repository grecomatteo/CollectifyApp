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
  List<String> tags = [];
  List<bool> pressed = List<bool>.filled(8, false, growable:false);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFE6F1F),
              onPrimary: Colors.white,
              surface: Color(0xFFFE6F1F),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Color(0xFF343434),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        birthdateController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _validateEmail(String email) async {
    final emailRegExp =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (emailRegExp.hasMatch(email)) {
      await Conexion().getUsuarioByEmail(email).then((value) => setState(() {
            if (value != null)
              _isValidEmail = "El correo ya esta en uso";
            else
              _isValidEmail = "true";
          }));
    } else {
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
                          if (_isValidEmail != "true")
                            Text(_isValidEmail.toString(),
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
                          Text(
                            'Indica tus preferencias',
                              style: const TextStyle(
                                color: Colors.white,
                                height: 4,
                                fontFamily: 'Aeonik',
                              )
                          ),
                          Container(
                            height: 130,
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  Card(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    color: Colors.transparent,
                                    child: ElevatedButton(
                                        onPressed: (){
                                          if(tags.contains("Arte y artesania"))
                                            {
                                              tags.remove("Arte y artesania");
                                            }
                                          else{ tags.add("Arte y artesanía"); }
                                          setState((){ pressed[0] = !pressed[0]; });
                                        },
                                        child: Column(
                                            children: <Widget>[
                                              Expanded(
                                                child: Image.asset(
                                                    'lib/assets/tags/Arte_artesania.png',
                                                    width: 70,
                                                    height: 70
                                                ),
                                              ),
                                              Text(
                                                  'Arte y artesanía',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Aeonik',
                                                  )
                                              )
                                            ]
                                        ),

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: pressed[0] ? Colors.lightGreen : Colors.white24,
                                          padding: EdgeInsets.zero,
                                          fixedSize: const Size(80, 130),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                        )
                                    ),
                                  ),
                                  Card(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    color: Colors.transparent,
                                    child: ElevatedButton(
                                        onPressed: (){
                                          if(tags.contains("Joyas y relojes"))
                                          {
                                            tags.remove("Joyas y relojes");
                                          }
                                          else{ tags.add("Joyas y relojes"); }
                                          setState((){ pressed[1] = !pressed[1]; });
                                        },
                                        child: Column(
                                            children: <Widget>[
                                              Expanded(
                                                child: Image.asset(
                                                    'lib/assets/tags/Joyas_relojes.png',
                                                    width: 70,
                                                    height: 70
                                                ),
                                              ),
                                              Text(
                                                  'Joyas y relojes',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Aeonik',
                                                  )
                                              )
                                            ]
                                        ),

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: pressed[1] ? Colors.lightGreen : Colors.white24,
                                          padding: EdgeInsets.zero,
                                          fixedSize: const Size(80, 130),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                        )
                                    ),
                                  ),
                                  Card(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    color: Colors.transparent,
                                    child: ElevatedButton(
                                        onPressed: (){
                                          if(tags.contains("Juguetes"))
                                          {
                                            tags.remove("Juguetes");
                                          }
                                          else{ tags.add("Juguetes"); }
                                          setState((){ pressed[2] = !pressed[2]; });
                                        },
                                        child: Column(
                                            children: <Widget>[
                                              Expanded(
                                                child: Image.asset(
                                                    'lib/assets/tags/Juguetes.png',
                                                    width: 70,
                                                    height: 70
                                                ),
                                              ),
                                              Text(
                                                  'Juguetes',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Aeonik',
                                                  )
                                              ),
                                              Text(
                                                  ''
                                              )
                                            ]
                                        ),

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: pressed[2] ? Colors.lightGreen : Colors.white24,
                                          padding: EdgeInsets.zero,
                                          fixedSize: const Size(80, 130),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                        )
                                    ),
                                  ),
                                  Card(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    color: Colors.transparent,
                                    child: ElevatedButton(
                                        onPressed: (){
                                          if(tags.contains("Libros y comics"))
                                          {
                                            tags.remove("Libros y comics");
                                          }
                                          else{ tags.add("Libros y comics"); }
                                          setState((){ pressed[3] = !pressed[3]; });
                                        },
                                        child: Column(
                                            children: <Widget>[
                                              Expanded(
                                                child: Image.asset(
                                                    'lib/assets/tags/Libros_comics.png',
                                                    width: 70,
                                                    height: 70
                                                ),
                                              ),
                                              Text(
                                                  'Libros y comics',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Aeonik',
                                                  )
                                              )
                                            ]
                                        ),

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: pressed[3] ? Colors.lightGreen : Colors.white24,
                                          padding: EdgeInsets.zero,
                                          fixedSize: const Size(80, 130),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                        )
                                    ),
                                  ),
                                  Card(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    color: Colors.transparent,
                                    child: ElevatedButton(
                                        onPressed: (){
                                          if(tags.contains("Monedas"))
                                          {
                                            tags.remove("Monedas");
                                          }
                                          else{ tags.add("Monedas"); }
                                          setState((){ pressed[4] = !pressed[4]; });
                                        },
                                        child: Column(
                                            children: <Widget>[
                                              Expanded(
                                                child: Image.asset(
                                                    'lib/assets/tags/Monedas_sellos.png',
                                                    width: 70,
                                                    height: 70
                                                ),
                                              ),
                                              Text(
                                                  'Monedas',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Aeonik',
                                                  )
                                              ),
                                              Text(
                                                  ''
                                              )
                                            ]
                                        ),

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: pressed[4] ? Colors.lightGreen : Colors.white24,
                                          padding: EdgeInsets.zero,
                                          fixedSize: const Size(80, 130),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                        )
                                    ),
                                  ),
                                  Card(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    color: Colors.transparent,
                                    child: ElevatedButton(
                                        onPressed: (){
                                          if(tags.contains("Música"))
                                          {
                                            tags.remove("Música");
                                          }
                                          else{ tags.add("Música"); }
                                          setState((){ pressed[5] = !pressed[5]; });
                                        },
                                        child: Column(
                                            children: <Widget>[
                                              Expanded(
                                                child: Image.asset(
                                                    'lib/assets/tags/Musica.png',
                                                    width: 70,
                                                    height: 70
                                                ),
                                              ),
                                              Text(
                                                  'Música',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Aeonik',
                                                  )
                                              ),
                                              Text(
                                                  ''
                                              )
                                            ]
                                        ),

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: pressed[5] ? Colors.lightGreen : Colors.white24,
                                          padding: EdgeInsets.zero,
                                          fixedSize: const Size(80, 130),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                        )
                                    ),
                                  ),
                                  Card(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    color: Colors.transparent,
                                    child: ElevatedButton(
                                        onPressed: (){
                                          if(tags.contains("Postales y sellos"))
                                          {
                                            tags.remove("Postales y sellos");
                                          }
                                          else{ tags.add("Postales y sellos"); }
                                          setState((){ pressed[6] = !pressed[6]; });
                                        },
                                        child: Column(
                                            children: <Widget>[
                                              Expanded(
                                                child: Image.asset(
                                                    'lib/assets/tags/Postales.png',
                                                    width: 70,
                                                    height: 70
                                                ),
                                              ),
                                              Text(
                                                  'Postales y sellos',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Aeonik',
                                                  )
                                              )
                                            ]
                                        ),

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: pressed[6] ? Colors.lightGreen : Colors.white24,
                                          padding: EdgeInsets.zero,
                                          fixedSize: const Size(80, 130),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                        )
                                    ),
                                  ),
                                  Card(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    color: Colors.transparent,
                                    child: ElevatedButton(
                                        onPressed: (){
                                          if(tags.contains("Ropa"))
                                          {
                                            tags.remove("Ropa");
                                          }
                                          else{ tags.add("Ropa"); }
                                          setState((){ pressed[7] = !pressed[7]; });
                                        },
                                        child: Column(
                                            children: <Widget>[
                                              Expanded(
                                                child: Image.asset(
                                                    'lib/assets/tags/Ropa.png',
                                                    width: 70,
                                                    height: 70
                                                ),
                                              ),
                                              Text(
                                                  'Ropa',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Aeonik',
                                                  )
                                              ),
                                              Text(
                                                  ''
                                              )
                                            ]
                                        ),

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: pressed[7] ? Colors.lightGreen : Colors.white24,
                                          padding: EdgeInsets.zero,
                                          fixedSize: const Size(80, 130),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                        )
                                    ),
                                  ),
                                ]
                            ),
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
                    if (_isValidEmail != "true") {
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
                      Conexion()
                          .registrarUsuario(
                              name, surname, nick, mail, password, birthdate)
                          .then((value) async {
                        print("se ha creado el usuario");
                        if (esEmpresa) {
                          await Conexion()
                              .getUsuarioByNick(nick)
                              .then((results) {
                            int? id = results?.usuarioID;
                            Conexion().hacerEmpresa(id!);
                          });
                        }
                        print("se ha hecho empresa");
                        Conexion().anadirCategoriasUsuario(tags, nick);
                        print("se han añadido las categorias");

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VentanaLogin()));
                      });
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
