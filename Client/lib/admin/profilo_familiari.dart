import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:test_emad/admin/adminHome.dart';
import 'package:test_emad/admin/lista_pazienti.dart';
import 'package:test_emad/admin/profilo_familiari_modifica.dart';
import 'package:test_emad/familiare.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_emad/costanti.dart';

/// This is the main application widget.
class ProfiloFamiliare extends StatefulWidget {
  final String cod_fiscale;

  ProfiloFamiliare(this.cod_fiscale, {Key? key}) : super(key: key);

  @override
  _Profilofamiliari createState() => _Profilofamiliari();
}

// This is the stateless widget that the main application instantiates.
class _Profilofamiliari extends State<ProfiloFamiliare> {
  late String cod_fiscale;
  CollectionReference doctors =
      FirebaseFirestore.instance.collection('doctors');
  //late Future<Map<String, dynamic>> datiprofilo;

  @override
  void initState() {
    print("initState");

    cod_fiscale = widget.cod_fiscale;
    super.initState();
  }

  Future<Map<String, dynamic>> getprofiledata() async {
    print("Inizio funzione");
    var uri = Uri.parse(urlServer + 'dati_profilo');
    print(uri);
    var message = {"role": 4, "cod_fiscale": cod_fiscale};

    var body = json.encode(message);

    var dati_profilo = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: body);

    uri = Uri.parse(urlServer + 'attori_associati');

    var attori_associati = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: body);

    Map<String, dynamic> resp = {'familiari': json.decode(dati_profilo.body)};
    resp['pazienti'] = json.decode(attori_associati.body)["pazienti"];

    return resp;
  }

  Future<int> eliminaUtente() async {
    var uri = Uri.parse(urlServer + 'elimina_utente');
    print(uri);
    var message = {"role": 4, "cod_fiscale": cod_fiscale};

    var body = json.encode(message);

    var data = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: body);
    return data.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    var profilo;
    List<dynamic> pazienti = [];

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
          title: Text("Profilo"),
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              tooltip: "Modifica",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfiloFamiliareModifica(
                      nome: profilo["nome"],
                      cognome: profilo["cognome"],
                      cod_fiscale: profilo["cod_fiscale"],
                      email: profilo["email"],
                      num_cellulare: profilo["num_cellulare"],
                      lista_pazienti: pazienti,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              tooltip: "Rimuovvi",
              onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('ATTENZIONE!'),
                    content: const Text('Rimuovere il familiari?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          eliminaUtente().then((value) {
                            if (value == 200) {
                              doctors.doc(cod_fiscale).delete().then((value) {
                                print("Patient Deleted");
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdminHome(),
                                  ),
                                );
                              }).catchError((error) {
                                print("Failed to delete patient: $error");
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Errore nella rimozione del familiari")));
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Errore nella rimozione del familiari")));
                            }
                          }).catchError((err) => {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Errore nella rimozione del familiari"))),
                              });
                        },
                        child: const Text('Si'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, 'No');

                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("familiari non rimosso")));
                        },
                        child: const Text('No'),
                      ),
                    ],
                  ),
                );
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ListaPazienti(),
                //   ),
                // );
              },
            ),
          ],
        ),
        body: Center(
          child: FutureBuilder(
            future: getprofiledata(),
            builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data);

                Map<String, dynamic> data = Map.from(snapshot.data!);
                pazienti =
                    json.decode(json.encode(data["pazienti"]).toString());
                profilo =
                    json.decode(json.encode(data["familiari"]).toString());

                print("Familiari\n" +
                    pazienti.toString() +
                    profilo.toString() +
                    profilo["nome"]);
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        profilo["nome"] + " " + profilo["cognome"],
                        style: const TextStyle(fontSize: 30),
                      ),
                      _card(profilo["cod_fiscale"], Icons.person),
                      _card(profilo["num_cellulare"].toString(),
                          Icons.smartphone),
                      _card(profilo["email"], Icons.email),
                      const Text(
                        "pazienti associati",
                        style: TextStyle(fontSize: 20),
                      ),
                      for (int i = 0; i < pazienti.length; i++)
                        _card(
                            pazienti[i]["cognome"] + " " + pazienti[i]["nome"],
                            Icons.people_alt),
                    ],
                  ),
                );
                // return Center(child: Text("NON FUNZIONA"));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _card(String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
      ),
    );
  }

  Widget _card2(String title, String text) {
    return Card(
      child: ListTile(
        leading: Text(text),
        title: Text(title),
      ),
    );
  }

  Widget _checkboxListTile(String text, bool value) {
    return CheckboxListTile(
      title: Text(text),
      contentPadding: const EdgeInsets.symmetric(horizontal: 100),
      value: value,
      onChanged: null,
    );
  }
}
