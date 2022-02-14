import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:test_emad/main.dart';
import 'main_dottore.dart';
import 'modify_profile.dart';
import 'package:http/http.dart' as http;

/// This is the main application widget.
class Profile extends StatelessWidget {
  final String token;
  final String cod_fiscale;
  final String nome;
  final String cognome;
  final String email;
  final String num_cellulare;
  final String specializzazione;

  Profile({
    required this.cod_fiscale,
    required this.token,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.num_cellulare,
    required this.specializzazione,
  });

  Widget _iconButton(BuildContext context, IconData icon, String tooltip,
      StatelessWidget statefulWidget) {
    IconButton iconButton;

    if (tooltip != "Modifica") {
      iconButton = IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: () {
          Navigator.pop(context);
        },
      );
    } else {
      iconButton = IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => statefulWidget),
          );
        },
      );
    }

    return iconButton;
  }

  Widget _iconButton2(BuildContext context, IconData icon, String tooltip,
      StatefulWidget statefulWidget) {
    IconButton iconButton;
    iconButton = IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => statefulWidget),
        );
      },
    );

    return iconButton;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: _iconButton(
              context,
              Icons.edit,
              'Modifica',
              ModifyProfile(
                  nome: nome,
                  cognome: cognome,
                  email: email,
                  num_cellulare: num_cellulare,
                  specializzazione: specializzazione,
                  token: token,
                  cod_fiscale: cod_fiscale)),
          title: const Text("Profilo"),
          actions: [
            _iconButton2(context, Icons.logout, 'Logout', LoginPage()),
          ],
        ),
        body: Center(
          child: MyProfile(
              nome: nome,
              cognome: cognome,
              email: email,
              num_cellulare: num_cellulare,
              specializzazione: specializzazione,
              token: token,
              cod_fiscale: cod_fiscale),
        ),
      ),
    );
  }
}

class MyProfile extends StatefulWidget {
  final String token;
  final String cod_fiscale;
  final String nome;
  final String cognome;
  final String email;
  final String num_cellulare;
  final String specializzazione;

  MyProfile({
    required this.cod_fiscale,
    required this.token,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.num_cellulare,
    required this.specializzazione,
  });

  MyProfileState createState() => MyProfileState();
}

// This is the stateless widget that the main application instantiates.
class MyProfileState extends State<MyProfile> {
  late String token;
  late String cod_fiscale;
  late String nome;
  late String cognome;
  late String email;
  late String num_cellulare;
  late String specializzazione;

  @override
  @protected
  @mustCallSuper
  void initState() {
    token = widget.token;
    cod_fiscale = widget.cod_fiscale;
    nome = widget.nome;
    cognome = widget.cognome;
    email = widget.email;
    num_cellulare = widget.num_cellulare;
    specializzazione = widget.specializzazione;
  }

  Widget _card(String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          nome + " " + cognome,
          style: const TextStyle(fontSize: 30),
        ),
        const SizedBox(
          height: 10,
        ),
        _card(cod_fiscale, Icons.person),
        _card(num_cellulare, Icons.smartphone),
        _card(email, Icons.email),
        _card(specializzazione, Icons.medical_services), //TODO
      ],
    );
  }
}
