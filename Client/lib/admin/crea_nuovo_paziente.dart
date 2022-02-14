// ignore_for_file: unnecessary_const
import 'package:test_emad/costanti.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_emad/admin/adminHome.dart';
import 'package:test_emad/admin/lista_pazienti.dart';
import 'gender_switch.dart';
import 'chat_switch.dart';
import 'package:flutter/material.dart';

void main() => runApp(const CreaPaziente());

/// This is the main application widget.
class CreaPaziente extends StatelessWidget {
  const CreaPaziente({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
              //   Navigator.pushReplacement(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => AdminHome(),
              //         ));
            },
          ),
          title: Text("Crea nuovo paziente"),
        ),
        body: const SingleChildScrollView(child: MyModifyProfile()),
      ),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyModifyProfile extends StatefulWidget {
  const MyModifyProfile({Key? key}) : super(key: key);

  @override
  State<MyModifyProfile> createState() => _MyModifyProfile();
}

// This is the stateless widget that the main application instantiates.
class _MyModifyProfile extends State<MyModifyProfile> {
  List<bool> isChecked = [false, false, false];
  Map<String, dynamic> senddata = {};
  TextEditingController _cont1 = TextEditingController();
  TextEditingController _cont2 = TextEditingController();
  TextEditingController _cont3 = TextEditingController();
  TextEditingController _cont4 = TextEditingController();
  TextEditingController _cont5 = TextEditingController();
  TextEditingController _cont6 = TextEditingController();
  String sesso = 'M';
  //TextEditingController _cont7 = TextEditingController();
  TextEditingController _cont8 = TextEditingController();
  int chat_mode = 0;

  Future<void> creaPazienteServer() async {
    var uri = Uri.parse(urlServer + 'crea_utente');
    print(uri);
    CollectionReference patients =
        FirebaseFirestore.instance.collection('patients');
    int role = 1;
    print(senddata);

    Map<String, dynamic> message = {
      "role": role,
      "cod_fiscale": senddata["cod_fiscale"],
      "nome": senddata["nome"],
      "cognome": senddata["cognome"],
      "num_cellulare": senddata["num_cellulare"],
      "email": senddata["email"],
      "tipologia_chat": chat_mode,
      "eta": senddata['eta'].toString(),
      "sesso": sesso,
      "titolo_studio": senddata['titolo_studio']
    };
    var body = json.encode(message);
    var data;
    print("\nBODY:: " + body);

    data = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: body);

    if (data.statusCode == 200) {
      patients.doc(message['cod_fiscale']).set({
        'nome': message['nome'],
        'cognome': message['cognome'],
        'status': 'offline',
        'ultimo_accesso': 'Nessun accesso'
      }).catchError((error) => {print("ERRORE LATO FIRESTORE: err: " + error)});

      // creaPazienteServer();
      final snackBar = SnackBar(
        content: const Text('Utente inserito con successo'),
      );
      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print("ERRORE LATO POSTGRESQL: err: ");
      const snackBar = const SnackBar(
        content: Text('Utente non inserito'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Widget _textFormField(IconData icon, String labelText, String validator,
      String i, TextEditingController _cont) {
    return TextFormField(
      controller: _cont,
      decoration: InputDecoration(
        icon: Icon(icon),
        labelText: labelText,
      ),
      // The validator receives the text that the user has entered.
      validator: (value) {
        if (labelText == "Numero di cellulare") {
          int? val = int.tryParse(value!) ?? 0;
          if (value == null || value.isEmpty || val == 0) {
            return validator;
          }
        }
        if (value == null || value.isEmpty) {
          return validator;
        }
        senddata[i] = value;
        return null;
      },
    );
  }

  Widget _form() {
    final _formKey = GlobalKey<FormState>();
    String select_chat_mode;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _textFormField(Icons.credit_card, "Codice fiscale",
                "Inserisci codice fiscale", "cod_fiscale", _cont1),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _textFormField(
                Icons.people, "Nome", "Inserisci nome", "nome", _cont2),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _textFormField(Icons.people, "Cognome", "Inserisci cognome",
                "cognome", _cont3),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _textFormField(
                Icons.smartphone,
                "Numero di cellulare",
                "Inserisci numero di cellulare (deve contenere solo numeri)",
                "num_cellulare",
                _cont4),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _textFormField(
                Icons.email, "E-mail", "Inserisci e-mail", "email", _cont5),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _textFormField(
                Icons.cake, "Età", "Inserisci età", "eta", _cont6),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text("Sesso:  ", style: TextStyle(fontSize: 15)),
                GenderSwitch(
                  onToggle: (Gender gender) {
                    sesso = gender.toString().split('.').last;
                    print('>>>>>>>>>> Gender ' + sesso);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _textFormField(Icons.work, "Titolo di studio",
                "Inserisci titolo di studio", "titolo_studio", _cont8),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Tipologia chat:", style: TextStyle(fontSize: 15)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ChatSwitch(
                  onToggle: (Chat chat) {
                    select_chat_mode = chat.toString().split('.').last;
                    switch (select_chat_mode) {
                      case 'testo':
                        chat_mode = 0;
                        break;
                      case 'vocale':
                        chat_mode = 1;
                        break;
                      case 'video':
                        chat_mode = 2;
                        break;
                      default:
                    }
                    print('>>>>>>>>>> mode: ' + chat_mode.toString());
                  },
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate() && chat_mode >= 0) {
                    creaPazienteServer().then((value) => {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminHome()),
                          ),
                        });
                  } else {
                    final snackBar = SnackBar(
                      content: const Text('Seleziona tipologia di chat'),
                    );

                    // Find the ScaffoldMessenger in the widget tree
                    // and use it to show a SnackBar.
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: const Text('Salva'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkboxListTile(String text, int index) {
    return CheckboxListTile(
      title: Text(text),
      contentPadding: const EdgeInsets.symmetric(horizontal: 100),
      value: isChecked[index],
      onChanged: (bool? value) {
        setState(() {
          isChecked[index] = value!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _form();
  }
}
