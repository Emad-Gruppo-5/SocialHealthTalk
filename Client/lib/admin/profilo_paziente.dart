import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:test_emad/admin/adminHome.dart';
import 'package:test_emad/admin/lista_pazienti.dart';
import 'package:test_emad/admin/profilo_paziente_modifica.dart';
import 'package:test_emad/familiare.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_emad/costanti.dart';

/// This is the main application widget.
class ProfiloPaziente extends StatefulWidget {
  final String cod_fiscale;

  ProfiloPaziente(this.cod_fiscale, {Key? key}) : super(key: key);

  @override
  _ProfiloPaziente createState() => _ProfiloPaziente();
}

// This is the stateless widget that the main application instantiates.
class _ProfiloPaziente extends State<ProfiloPaziente> {
  late String cod_fiscale;
  CollectionReference patients =
      FirebaseFirestore.instance.collection('patients');
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
    var message = {"role": 1, "cod_fiscale": cod_fiscale};

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

    Map<String, dynamic> resp = {'paziente': json.decode(dati_profilo.body)};
    resp['familiari'] = json.decode(attori_associati.body)["familiari"];
    resp['dottori'] = json.decode(attori_associati.body)["dottori"];

    return resp;
  }

  Future<int> eliminaUtente() async {
    var uri = Uri.parse(urlServer + 'elimina_utente');
    print(uri);
    var message = {"role": 1, "cod_fiscale": cod_fiscale};

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
    List<dynamic> familiari = [];
    List<dynamic> dottori = [];

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
                    builder: (context) => ProfiloPazienteModifica(
                      nome: profilo["nome"],
                      cognome: profilo["cognome"],
                      cod_fiscale: profilo["cod_fiscale"],
                      email: profilo["email"],
                      num_cellulare: profilo["num_cellulare"],
                      tipologia_chat: profilo["tipologia_chat"],
                      lista_dottori: dottori,
                      lista_familiari: familiari,
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
                    content: const Text('Rimuovere il paziente?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          eliminaUtente().then((value) {
                            if (value == 200) {
                              patients.doc(cod_fiscale).delete().then((value) {
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
                                            "Errore nella rimozione del paziente")));
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Errore nella rimozione del paziente")));
                            }
                          }).catchError((err) => {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Errore nella rimozione del paziente"))),
                              });
                        },
                        child: const Text('Si'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, 'No');

                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Paziente non rimosso")));
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
                profilo = json.decode(json.encode(data["paziente"]).toString());
                familiari =
                    json.decode(json.encode(data["familiari"]).toString());
                dottori = json.decode(json.encode(data["dottori"]).toString());

                print("DOTTORI\n" + dottori.toString());
                print("FAMILIARI\n" + familiari.toString());
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
                      _card2(profilo["eta"], 'Età:'),
                      _card2(
                          profilo["sesso"] == null ? "null" : profilo["sesso"],
                          "sesso:"),
                      _card2(profilo["titolo_studio"], "Titolo di studio:"),
                      const Text("\nTipologia chat"),
                      _checkboxListTile("Solo testo",
                          profilo["tipologia_chat"] == 0 ? true : false),
                      _checkboxListTile("Videochiamata",
                          profilo["tipologia_chat"] == 1 ? true : false),
                      _checkboxListTile("Chiamata vocale",
                          profilo["tipologia_chat"] == 2 ? true : false),
                      const Text(
                        "Dottori associati",
                        style: TextStyle(fontSize: 20),
                      ),
                      for (int i = 0; i < dottori.length; i++)
                        _card(dottori[i]["cognome"] + " " + dottori[i]["nome"],
                            Icons.medical_services_outlined),
                      const Text(
                        "Familiari associati",
                        style: TextStyle(fontSize: 20),
                      ),
                      for (int i = 0; i < familiari.length; i++)
                        _card(
                            familiari[i]["cognome"] +
                                " " +
                                familiari[i]["nome"],
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
