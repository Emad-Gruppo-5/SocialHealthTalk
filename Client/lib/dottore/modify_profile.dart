// ignore_for_file: unnecessary_const

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:test_emad/main.dart';
import 'main_dottore.dart';
import 'profile.dart';
import 'package:http/http.dart' as http;
import 'package:test_emad/costanti.dart';
/// This is the main application widget.
class ModifyProfile extends StatelessWidget {
  final String token;
  final String cod_fiscale;
  final String nome;
  final String cognome;
  final String email;
  final String num_cellulare;
  final String specializzazione;
  ModifyProfile({
    required this.cod_fiscale,
    required this.token,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.num_cellulare,
    required this.specializzazione,
  });

  Widget _iconButton(BuildContext context, IconData icon, String tooltip) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _iconButton2(BuildContext context, IconData icon, String tooltip,
      StatefulWidget statelessWidget) {
    IconButton iconButton;

    if (tooltip != "Logout") {
      iconButton = IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ));
        },
      );
    } else {
      iconButton = IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (co) => statelessWidget),
          );
        },
      );
    }

    return iconButton;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: _iconButton(context, Icons.arrow_back_ios, 'Indietro'),
          title: const Text("Modifica dati"),
          actions: [
            _iconButton2(context, Icons.logout, 'Logout', LoginPage()),
          ],
        ),
        body: Center(
            child: MyModifyProfile(
                nome: nome,
                cognome: cognome,
                email: email,
                num_cellulare: num_cellulare,
                specializzazione: specializzazione,
                cod_fiscale: cod_fiscale,
                token: token)),
      ),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyModifyProfile extends StatefulWidget {
  final String token;
  final String cod_fiscale;
  final String nome;
  final String cognome;
  final String email;
  final String num_cellulare;
  final String specializzazione;
  MyModifyProfile({
    required this.cod_fiscale,
    required this.token,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.num_cellulare,
    required this.specializzazione,
  });

  @override
  State<MyModifyProfile> createState() => _MyModifyProfile();
}

// This is the stateless widget that the main application instantiates.
class _MyModifyProfile extends State<MyModifyProfile> {
  late String token;
  late String cod_fiscale;
  late String nome;
  late String cognome;
  late String email;
  late String num_cellulare;
  late String specializzazione;
  Map<String, dynamic> senddata = {};

  @override
  @protected
  @mustCallSuper
  void initState() {
    cod_fiscale = widget.cod_fiscale;
    token = widget.token;
    nome = widget.nome;
    cognome = widget.cognome;
    email = widget.email;
    num_cellulare = widget.num_cellulare;
    specializzazione = widget.specializzazione;
    super.initState();
  }

  Future<String> modificaUtente() async {
    var uri = Uri.parse(urlServer + 'modifica_utente');

    print(uri);


    int role = 2;
    print(senddata);
    Map<String, dynamic> message = {
      "cod_fiscale": cod_fiscale,
      "role": role,
      "num_cellulare": senddata["Numero di cellulare"],
      "email": senddata["E-mail"],
    };
    var body = json.encode(message);
    print("\nBODY:: " + body);
    var data = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: body);
    print('Response status: ${data.statusCode}');
    print('Response body: ' + data.body);

    if (data.statusCode == 200) {
      final snackBar = SnackBar(
        content: const Text('Utente aggiornato con successo'),
      );
      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      const snackBar = const SnackBar(
        content: Text('Utente non aggiornato'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return data.body;
  }

  Widget _textFormField(
      IconData icon, String labelText, String initialValue, String validator) {
    return TextFormField(
      decoration: InputDecoration(
        icon: Icon(icon),
        labelText: labelText,
      ),
      initialValue: initialValue,
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
            child: _textFormField(Icons.smartphone, "Numero di cellulare",
                num_cellulare, "Inserisci numero di cellulare"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _textFormField(
                Icons.email, "E-mail", email, "Inserisci e-mail"),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    modificaUtente();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          nome + " " + cognome,
          style: const TextStyle(fontSize: 30),
        ),
        _form(),
      ],
    );
  }
}
