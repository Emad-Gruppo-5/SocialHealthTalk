import 'package:flutter/material.dart';
import 'package:test_emad/costanti.dart';
import 'package:test_emad/main.dart';
import 'main_dottore.dart';
import 'patient_list_item.dart';
import 'detail_patient.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
class List_page extends StatelessWidget {
  final String token;
  final String cod_fiscale;
  final String nome;
  final String cognome;
  final String email;
  final String num_cellulare;
  final String specializzazione;
  List_page({
    required this.cod_fiscale,
    required this.token,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.num_cellulare,
    required this.specializzazione,
  });

  late List<dynamic> lista_pazienti = [];

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
    print("RESP?????? " + resp.toString());
    lista_pazienti.clear();

    lista_pazienti = json.decode(json.encode(resp["pazienti"]));

    return resp;
  }

  @override
  Widget build(BuildContext context) {
    // lo faccio due volte, per aggiungere un po' di delay...
    updateProfileData();
    updateProfileData();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pazienti"),
        actions: [
          _iconButton(context, Icons.logout, 'Logout', LoginPage()),
        ],
      ),
      body: Center(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("patients")
                .orderBy("cognome")
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              return ListView(
                children: snapshot.data!.docs.map((patient) {
                  for (int i = 0; i < lista_pazienti.length; i++) {
                    if (patient.id == lista_pazienti[i]["cod_fiscale"]) {
                      return Center(
                        child: ListTile(
                          title:
                              Text(patient['nome'] + " " + patient['cognome']),
                          subtitle: Text(patient['status'] == 'online'
                              ? 'online'
                              : 'ultimo accesso: ' + patient['ultimo_accesso']),
                          trailing: Icon(
                            Icons.circle,
                            color: patient['status'] == 'online'
                                ? Colors.greenAccent
                                : Colors.redAccent,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailPatient(
                                        cod_fiscale: cod_fiscale,
                                        token: token,
                                        nome: nome,
                                        cognome: cognome,
                                        email: email,
                                        specializzazione: specializzazione,
                                        num_cellulare: num_cellulare,
                                        paz_cod_fiscale: patient.id,
                                      )),
                            );
                          },
                        ),
                      );
                    }
                  }
                  if (lista_pazienti.isEmpty) {
                    return const SizedBox(width: 0, height: 0);
                  }
                  return const SizedBox(width: 0, height: 0);
                }).toList(),
              );
            }),
      ),
    );
  }

  Widget _iconButton(BuildContext context, IconData icon, String tooltip,
      StatefulWidget statelessWidget) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => statelessWidget),
        );
      },
    );
  }
}
