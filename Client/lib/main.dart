import 'package:flutter/material.dart' hide Key;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:crypt/crypt.dart';
import 'package:test_emad/dottore/main_dottore.dart';
import 'package:test_emad/patient/home.dart';
import 'package:test_emad/admin/adminHome.dart';
import 'package:test_emad/recupera_password.dart';

import 'costanti.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if( Firebase.apps.length == 0){
  await Firebase.initializeApp(
    // Replace with actual values
    options: FirebaseOptions(
      apiKey: "AIzaSyBIuXrd5qAH-i8J0NlZYGE0nZPvxL5VXJs",
      appId: "1:538201922332:android:43e7210d4ce4a6a7e9f8d9",
      messagingSenderId:
          "538201922332-b9n2vl6lggp4hiaulkn3f7j5gvbdij6k.apps.googleusercontent.com",
      projectId: "app-challenge-sht",
    ),
  );
  // }
  // else Firebase.app();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // String token;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Social Health Talk",
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TextEditingController _cod_fiscaleC = TextEditingController();
  TextEditingController _passwordC = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<String> login(cod_fiscale, password) async {
    final digest = Crypt.sha256(password).toString();
    var uri = Uri.parse(urlServer + 'login');

    print(uri);

    print("\nECCOMI IN getUser. COD_FISCALE: " +
        cod_fiscale +
        " PASSWORD: " +
        digest);

    Map<String, String> message = {
      "cod_fiscale": cod_fiscale,
      "password": password
    };
    var body = json.encode(message);
    print("\nBODY:: " + body);
    final data = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: body);
    print('Response status: ${data.statusCode}');
    print('Response body: ${data.body}');

    return data.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, colors: [
          Colors.lightBlue.shade200,
          Colors.lightBlue.shade100,
          Colors.lightBlue.shade200
        ])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Text("Login", style: TextStyle(color: Colors.white, fontSize: 40),),
                  SizedBox(height: 10,),
                  Center(
                      child: Image.asset(
                    'assets/images/SHT.png',
                    fit: BoxFit.scaleDown,
                    width: 960,
                  ))
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60))),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      color: Color.fromRGBO(109, 193, 255, .3),
                                      blurRadius: 20,
                                      offset: Offset(0, 10))
                                ]),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey.shade200))),
                                  child: TextFormField(
                                    controller: _cod_fiscaleC,
                                    decoration: InputDecoration(
                                        hintText: "Codice fiscale",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: InputBorder.none),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Inserire il codice fiscale";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey.shade200))),
                                  child: TextFormField(
                                    controller: _passwordC,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        hintText: "Password",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: InputBorder.none),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Inserire la password";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Container(
                              height: 50,
                              margin: EdgeInsets.symmetric(horizontal: 50),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(90),
                                  color: Colors.lightBlue.shade700),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    var cod_fiscale = _cod_fiscaleC.text;
                                    var password = _passwordC.text;

                                    login(cod_fiscale, password).then((data) {
                                      int role = json.decode(data)['role'];
                                      String token = json.decode(data)['token'];
                                      String nome = json.decode(data)['nome'];
                                      String cognome =
                                          json.decode(data)['cognome'];
                                      String email = json.decode(data)['email'];
                                      String num_cellulare = json
                                          .decode(data)['num_cellulare']
                                          .toString();

                                      switch (role) {
                                        case 1: //PAZIENTE
                                          int tipologia_chat = json
                                              .decode(data)['tipologia_chat'];
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Patient_Home(
                                                        cod_fiscale:
                                                            cod_fiscale,
                                                        nome: nome,
                                                        cognome: cognome,
                                                        email: email,
                                                        num_cellulare:
                                                            num_cellulare,
                                                        tipologia_chat:
                                                            tipologia_chat,
                                                        token: token)),
                                          );
                                          break;
                                        case 2: //DOTTORE
                                          if (cod_fiscale == 'admin') {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AdminHome()));
                                          } else {
                                            String specializzazione =
                                                json.decode(
                                                    data)['specializzazione'];
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MainDottore(
                                                            token: token,
                                                            cod_fiscale:
                                                                cod_fiscale,
                                                            nome: nome,
                                                            cognome: cognome,
                                                            email: email,
                                                            num_cellulare:
                                                                num_cellulare,
                                                            specializzazione:
                                                                specializzazione)));
                                          }

                                          break;
                                        case 3: //VOLONTARIO
                                          // Navigator.push(context,
                                          //        MaterialPageRoute(
                                          //           builder: (context) => Familiare(token: token)));
                                          break;
                                        case 4: //FAMILIARE
                                          // Navigator.push(context,
                                          //        MaterialPageRoute(
                                          //           builder: (context) => Familiare(token: token)));
                                          break;
                                        default:
                                      }
                                    }).catchError((error) => {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'Utente non esistente'))),
                                          print(error)
                                        });
                                  }
                                },
                                child: Center(
                                    child: Text(
                                  "Accedi",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(90)),
                                    primary: Colors.lightBlue.shade900),
                              )),
                          SizedBox(
                            height: 20,),
                        
                        const Divider(
                            height: 20,
                            thickness: 1,
                            indent: 10,
                            endIndent: 30),
                          SizedBox(height: 20, ),
                        Container(
                            height: 50,
                            margin: EdgeInsets.symmetric(horizontal: 50),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.lightBlue.shade600
                                
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                               Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RecuperaPassword()),
                              );
                              },
                              child: Center(
                                  child: Text(
                                "Recupera Password",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(90)),
                                  primary: Colors.lightBlue.shade700),
                            )
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
            )],
        ),
      ),
    );
  }
}
