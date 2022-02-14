// ignore_for_file: unnecessary_const
import 'dart:convert';

import 'package:test_emad/admin/adminHome.dart';
import 'package:test_emad/costanti.dart';
import 'package:flutter/material.dart';
import 'package:test_emad/admin/lista_dottori.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const CreaNuovoFamiliare());

/// This is the main application widget.
class CreaNuovoFamiliare extends StatelessWidget {
  const CreaNuovoFamiliare({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            tooltip: "Indietro",
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text("Crea nuovo familiare"),
        ),
        body: const SingleChildScrollView(child: CreateProfile()),
      ),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class CreateProfile extends StatefulWidget {
  const CreateProfile({Key? key}) : super(key: key);

  @override
  State<CreateProfile> createState() => _MyModifyProfile();
}

// This is the stateless widget that the main application instantiates.
class _MyModifyProfile extends State<CreateProfile> {
  @override
  void initState() {
    super.initState();
  }

  Map<String, dynamic> senddata = {};
  TextEditingController _cont1 = TextEditingController();
  TextEditingController _cont2 = TextEditingController();
  TextEditingController _cont3 = TextEditingController();
  TextEditingController _cont4 = TextEditingController();
  TextEditingController _cont5 = TextEditingController();
  TextEditingController _cont6 = TextEditingController();

  Future<void> creaFamiliareServer() async {
    var uri = Uri.parse(urlServer + 'crea_utente');

    int role = 4;
    print(senddata);

    Map<String, dynamic> message = {
      "role": role,
      "cod_fiscale": senddata["Codice Fiscale"],
      "nome": senddata["Nome"],
      "cognome": senddata["Cognome"],
      "num_cellulare": senddata["Numero di cellulare"],
      "email": senddata["E-mail"],
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
      TextEditingController _cont) {
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
        senddata[labelText] = value;
        return null;
      },
    );
  }

  Widget _form() {
    final _formKey = GlobalKey<FormState>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _textFormField(
                Icons.person_rounded, "Nome", "Inserisci Nome", _cont1),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _textFormField(
                Icons.person_rounded, "Cognome", "Inserisci Cognome", _cont2),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _textFormField(Icons.credit_card_outlined, "Codice Fiscale",
                "Inserisci Codice Fiscale", _cont3),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _textFormField(Icons.smartphone, "Numero di cellulare",
                "Inserisci numero di cellulare", _cont4),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _textFormField(
                Icons.email, "E-mail", "Inserisci e-mail", _cont5),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid
                    creaFamiliareServer().then((value) => {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminHome()),
                          ),
                        });
                  }
                },
                child: const Text('Crea'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _form();
  }
}
