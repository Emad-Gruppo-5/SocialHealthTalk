import 'package:test_emad/admin/profilo_familiari.dart';
import 'package:test_emad/costanti.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:test_emad/admin/lista_pazienti_seach.dart';
import 'lista_familiari_search.dart';
import 'package:http/http.dart' as http;

import 'lista_pazienti_seach.dart';

/// This is the main application widget.
class ProfiloFamiliareModifica extends StatelessWidget {
  final String cod_fiscale;
  final String nome;
  final String cognome;
  final String email;
  final String num_cellulare;
  final List<dynamic> lista_pazienti;

  ProfiloFamiliareModifica({
    required this.cod_fiscale,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.num_cellulare,
    required this.lista_pazienti,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            tooltip: "Indietro",
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text("Modifica dati"),
        ),
        body: SingleChildScrollView(
            child: MyModifyProfile(
          nome: nome,
          cognome: cognome,
          cod_fiscale: cod_fiscale,
          email: email,
          num_cellulare: num_cellulare,
          lista_pazienti: lista_pazienti,
        )),
      ),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyModifyProfile extends StatefulWidget {
  final String cod_fiscale;
  final String nome;
  final String cognome;
  final String email;
  final String num_cellulare;
  final List<dynamic> lista_pazienti;

  MyModifyProfile({
    required this.cod_fiscale,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.num_cellulare,
    required this.lista_pazienti,
  });
  @override
  State<MyModifyProfile> createState() => _MyModifyProfile();
}

// This is the stateless widget that the main application instantiates.
class _MyModifyProfile extends State<MyModifyProfile> {
  late String cod_fiscale;
  late String nome;
  late String cognome;
  late String email;
  late String num_cellulare;
  late List<dynamic> lista_pazienti;
  Map<String, dynamic> senddata = {};

  List<bool> isChecked = [false, true, false];

  @override
  void initState() {
    cod_fiscale = widget.cod_fiscale;
    nome = widget.nome;
    cognome = widget.cognome;
    email = widget.email;
    num_cellulare = widget.num_cellulare;
    lista_pazienti = widget.lista_pazienti;
    //adding item to list, you can add using json from network

    super.initState();
  }

  static List<Map<String, String>> mainDataList = [];
  static List<Map<String, String>> secondDataList = [];

  Future<void> getActors(String cod_fiscale) async {
    mainDataList.clear();
    secondDataList.clear();
    var uri = Uri.parse(urlServer + 'attori_associati');
    print(uri);

    int role = 1;
    Map<String, String> message = {
      "role": role.toString(),
      "cod_fiscale": cod_fiscale,
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

    var i = 0;
    while (i < json.decode(data.body).length) {
      if (json
              .decode(data.body)["lista_pazienti"]
              .toString()
              .compareTo('lista_pazienti') ==
          1) {
        mainDataList.add({
          'cognome': json.decode(data.body)[i]['cognome'],
          'nome': json.decode(data.body)[i]['nome'],
          'cod_fiscale': json.decode(data.body)[i]['cod_fiscale']
        });
      } else {
        secondDataList.add({
          'cognome': json.decode(data.body)[i]['cognome'],
          'nome': json.decode(data.body)[i]['nome'],
          'cod_fiscale': json.decode(data.body)[i]['cod_fiscale']
        });
      }
      i++;
    }
  }

  Future<Map<String, dynamic>> updateProfileData() async {
    print("Inizio funzione");
    var message = {"role": 2, "cod_fiscale": cod_fiscale};

    var body = json.encode(message);

    var uri = Uri.parse(urlServer + 'attori_associati');

    var attori_associati = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: body);

    Map<String, dynamic> resp = {};
    resp['pazienti'] = json.decode(attori_associati.body)["pazienti"];

    lista_pazienti.clear();

    lista_pazienti = json.decode(json.encode(resp["pazienti"]).toString());
    return resp;
  }

  // Copy Main List into New List.
  List<Map<String, String>> newDataList = List.from(mainDataList);

  Future<String> AssociaFamiliare(String pat_cod_fiscale, int role) async {
    var uri = Uri.parse(urlServer + 'associa_attore');
    print(uri);

    print(pat_cod_fiscale + "ukff");

    print(senddata);
    Map<String, String> message = {
      "user_cod_fiscale": cod_fiscale,
      "role": 4.toString(),
      "paziente_cod_fiscale": pat_cod_fiscale,
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
        content: const Text('Associato con successo'),
      );
      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      const snackBar = const SnackBar(
        content: Text('Non associato'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return data.body;
  }

  Future<String> RimuoviAssociazione(String dot_cod_fiscale, int role) async {
    var uri = Uri.parse(urlServer + 'rimuovi_associazione');
    print(uri);

    print(dot_cod_fiscale + "ukff");

    print(senddata);
    Map<String, String> message = {
      "user_cod_fiscale": cod_fiscale,
      "role": role.toString(),
      "paziente_cod_fiscale": dot_cod_fiscale,
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
        content: const Text('Associazione rimossa con successo'),
      );
      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      const snackBar = const SnackBar(
        content: Text('Associazione non rimossa'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return data.body;
  }

  Future<void> updateProfilo() async {
    var uri = Uri.parse(urlServer + 'modifica_utente');

    Map<String, dynamic> message = {
      "role": 4.toString(),
      "cod_fiscale": cod_fiscale,
      "num_cellulare": senddata["Numero di cellulare"],
      "email": senddata["E-mail"]
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
        content: const Text('Utente aggiornato con successo'),
      );
      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print("ERRORE LATO POSTGRESQL: err: ");
      const snackBar = const SnackBar(
        content: Text('Utente non aggiornato'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _navigateAndDisplaySelection(BuildContext context, int role) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    var result;
    if (role == 1) {
      result = await Navigator.push(
        context,
        // Create the SelectionScreen in the next step.
        MaterialPageRoute(builder: (context) => listaPazientiSeach()),
      );
    }
    if (result != null) {
      AssociaFamiliare(result.toString(), 4);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$result')));
      await updateProfileData();
      setState(() {
        //refresh UI after deleting element from list
      });
    }
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
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Pazienti associati",
              style: TextStyle(fontSize: 15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 130,
              child: SingleChildScrollView(
                child: Column(
                  children: lista_pazienti.map((data) {
                    return Card(
                      child: ListTile(
                        title: Text(data["cognome"]! + ' ' + data["nome"]!),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.blue),
                          child: const Icon(Icons.delete),
                          onPressed: () {
                            //delete action for this button
                            lista_pazienti.removeWhere((element) {
                              if (element["cod_fiscale"] ==
                                  data["cod_fiscale"]) {
                                RimuoviAssociazione(element['cod_fiscale'], 4);
                              }
                              return element["cod_fiscale"] ==
                                  data["cod_fiscale"];
                            }); //go through the loop and match content to delete from list
                            setState(() {
                              updateProfileData();
                              //refresh UI after deleting element from list
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _navigateAndDisplaySelection(context, 1);
              },
              child: const Text('Aggiungi paziente'),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    updateProfilo();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfiloFamiliare(cod_fiscale),
                      ),
                    );
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

class Person {
  //modal class for Person object
  String id, name, phone;
  Person({required this.id, required this.name, required this.phone});
}
