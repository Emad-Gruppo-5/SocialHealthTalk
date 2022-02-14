import 'package:test_emad/admin/profilo_dottore.dart';
import 'package:test_emad/admin/profilo_paziente.dart';
import 'package:test_emad/costanti.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:test_emad/admin/lista_dottori_seach.dart';
import 'chat_switch.dart';
import 'lista_familiari_search.dart';
import 'package:http/http.dart' as http;

/// This is the main application widget.
class ProfiloPazienteModifica extends StatelessWidget {
  final String cod_fiscale;
  final String nome;
  final String cognome;
  final String email;
  final String num_cellulare;
  final int tipologia_chat;
  final List<dynamic> lista_familiari;
  final List<dynamic> lista_dottori;

  ProfiloPazienteModifica({
    required this.cod_fiscale,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.num_cellulare,
    required this.tipologia_chat,
    required this.lista_familiari,
    required this.lista_dottori,
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
          tipologia_chat: tipologia_chat,
          lista_dottori: lista_dottori,
          lista_familiari: lista_familiari,
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
  final int tipologia_chat;
  final List<dynamic> lista_familiari;
  final List<dynamic> lista_dottori;

  MyModifyProfile({
    required this.cod_fiscale,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.num_cellulare,
    required this.tipologia_chat,
    required this.lista_familiari,
    required this.lista_dottori,
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
  late int tipologia_chat;
  late List<dynamic> lista_dottori;
  late List<dynamic> lista_familiari;
  late int chat_mode;
  Map<String, dynamic> senddata = {};

  List<bool> isChecked = [false, true, false];

  @override
  void initState() {
    cod_fiscale = widget.cod_fiscale;
    tipologia_chat = widget.tipologia_chat;
    nome = widget.nome;
    cognome = widget.cognome;
    email = widget.email;
    num_cellulare = widget.num_cellulare;
    lista_dottori = widget.lista_dottori;
    lista_familiari = widget.lista_familiari;
    chat_mode = widget.tipologia_chat;

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
              .decode(data.body)["lista_dottori"]
              .toString()
              .compareTo('lista_dottori') ==
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
    var message = {"role": 1, "cod_fiscale": cod_fiscale};

    var body = json.encode(message);

    var uri = Uri.parse(urlServer + 'attori_associati');

    var attori_associati = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: body);

    Map<String, dynamic> resp = {};
    resp['familiari'] = json.decode(attori_associati.body)["familiari"];
    resp['dottori'] = json.decode(attori_associati.body)["dottori"];

    lista_dottori.clear();
    lista_familiari.clear();

    lista_familiari = json.decode(json.encode(resp["familiari"]).toString());
    lista_dottori = json.decode(json.encode(resp["dottori"]).toString());
    return resp;
  }


  Future<void> updateProfilo() async {
    var uri = Uri.parse(urlServer + 'modifica_utente');

    Map<String, dynamic> message = {
      "role": 1.toString(),
      "cod_fiscale": cod_fiscale,
      "num_cellulare": senddata["Numero di cellulare"],
      "email": senddata["E-mail"],
      "tipologia_chat": chat_mode
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

  // Copy Main List into New List.
  List<Map<String, String>> newDataList = List.from(mainDataList);

  Future<String> AssociaDottore(String dot_cod_fiscale, int role) async {
    var uri = Uri.parse(urlServer + 'associa_attore');
    print(uri);

    print(senddata);
    Map<String, String> message = {
      "user_cod_fiscale": dot_cod_fiscale,
      "role": role.toString(),
      "paziente_cod_fiscale": cod_fiscale,
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
      "user_cod_fiscale": dot_cod_fiscale,
      "role": role.toString(),
      "paziente_cod_fiscale": cod_fiscale,
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

  void _navigateAndDisplaySelection(BuildContext context, int role) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    var result;
    if (role == 2) {
      result = await Navigator.push(
        context,
        // Create the SelectionScreen in the next step.
        MaterialPageRoute(builder: (context) => listaDottoriSeach()),
      );
    }
    if (role == 4) {
      result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ListaFamiliariSearch()),
      );
    }
    if (result != null) {
      AssociaDottore(result.toString(), role);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("Associazione inserita con successo")));
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
    String select_chat_mode;

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
              "Dttori associati",
              style: TextStyle(fontSize: 15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 130,
              child: SingleChildScrollView(
                child: Column(
                  children: lista_dottori.map((data) {
                    return Card(
                      child: ListTile(
                        title: Text(data["cognome"]! + ' ' + data["nome"]!),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.blue),
                          child: const Icon(Icons.delete),
                          onPressed: () {
                            //delete action for this button
                            lista_dottori.removeWhere((element) {
                              if (element["cod_fiscale"] ==
                                  data["cod_fiscale"]) {
                                RimuoviAssociazione(element['cod_fiscale'], 2);
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
                _navigateAndDisplaySelection(context, 2);
              },
              child: const Text('Aggiungi dottore'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Familiari associati",
              style: TextStyle(fontSize: 15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 60,
              child: SingleChildScrollView(
                child: Column(
                  children: lista_familiari.map((data) {
                    return Card(
                      child: ListTile(
                        title: Text(data["cognome"]! + ' ' + data["nome"]!),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.blue),
                          child: const Icon(Icons.delete),
                          onPressed: () {
                            //delete action for this button
                            lista_familiari.removeWhere((element) {
                              if (element["cod_fiscale"] ==
                                  data["cod_fiscale"]) {
                                RimuoviAssociazione(element['cod_fiscale'], 4);
                              }
                              return element["cod_fiscale"] ==
                                  data["cod_fiscale"];
                            }); //go through the loop and match content to delete from list
                            setState(() {
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
                _navigateAndDisplaySelection(context, 4);
              },
              child: const Text('Aggiungi familiare'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Tipologia Chat",
              style: TextStyle(fontSize: 15),
            ),
          ),
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
                        builder: (context) => ProfiloPaziente(cod_fiscale),
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
