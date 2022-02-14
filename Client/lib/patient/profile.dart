import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_emad/patient/home.dart';
import '../main.dart';
import 'modify_profile.dart';
import '../costanti.dart';

/// This is the main application widget.
class Profile extends StatefulWidget {
  final String nome;
  final String cognome;
  final String email;
  final String num_cellulare;
  final int tipologia_chat;
  final String cod_fiscale;
  final String token;

  const Profile(
      {required this.cod_fiscale,
      required this.nome,
      required this.cognome,
      required this.email,
      required this.num_cellulare,
      required this.tipologia_chat,
      required this.token});

  @override
  _Profile createState() => _Profile();
}

enum SingingCharacter { text, video_call, voice_call }

class _Profile extends State<Profile> {
  late String nome;
  late String cognome;
  late String email;
  late String num_cellulare;
  late int tipologia_chat;
  late String cod_fiscale;
  late String token;
  late String ultimo_accesso;
  @override
  void initState() {
    nome = widget.nome;
    cognome = widget.cognome;
    email = widget.email;
    num_cellulare = widget.num_cellulare;
    tipologia_chat = widget.tipologia_chat;
    cod_fiscale = widget.cod_fiscale;
    token = widget.token;
    super.initState();
    switch (tipologia_chat) {
      case 0:
        _character = SingingCharacter.text;
        break;
      case 1:
        _character = SingingCharacter.video_call;
        break;
      case 2:
        _character = SingingCharacter.voice_call;
        break;
    }
  }

  Duration alert_duration = Duration(seconds: alert_dur);
  Duration online_duration = Duration(seconds: online_dur);
  late Timer timer;
  late Timer timer_alert;
  String timerText = "Start";
  SingingCharacter? _character;

  Widget _iconButtonPush(IconData icon, String tooltip) {
    if (tooltip != 'Logout') {
      return IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: () {
          timer.cancel();
          timer_alert.cancel();
          print("UPDATE FIRESTORE");
          FirebaseFirestore.instance
              .collection('patients')
              .doc(cod_fiscale)
              .update({'status': 'online'});

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ModifyProfile(
                    cod_fiscale: cod_fiscale,
                    nome: nome,
                    cognome: cognome,
                    email: email,
                    num_cellulare: num_cellulare,
                    tipologia_chat: tipologia_chat,
                    token: token)),
          );
        },
      );
    } else {
      return IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: () {
          timer.cancel();
          DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
          ultimo_accesso = dateFormat.format(DateTime.now());
          FirebaseFirestore.instance
              .collection('patients')
              .doc(cod_fiscale)
              .update({'status': 'offline', 'ultimo_accesso': ultimo_accesso});

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        },
      );
    }
  }

  Widget _iconButtonPop(IconData icon, String tooltip) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () {
        timer.cancel();
        timer_alert.cancel();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Patient_Home(
                cod_fiscale: cod_fiscale,
                nome: nome,
                cognome: cognome,
                email: email,
                num_cellulare: num_cellulare,
                tipologia_chat: tipologia_chat,
                token: token),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    timer = Timer(online_duration, handleTimeout);
    timer_alert = Timer(alert_duration, callback);
    return MaterialApp(
      home: GestureDetector(
        child: Scaffold(
          appBar: AppBar(
            leading: _iconButtonPop(Icons.arrow_back_ios, 'Indietro'),
            title: const Text("Profilo"),
            actions: [
              _iconButtonPush(Icons.edit, 'Modifica'),
              _iconButtonPush(Icons.logout, 'Logout'),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(
          height: 10,
        ),
        const SizedBox(
          height: 10,
        ),
              Text(
                "$nome $cognome",
                style: TextStyle(fontSize: 30),
              ),
              const SizedBox(
          height: 10,
        ),
              _card("$cod_fiscale", Icons.person),
              _card("$num_cellulare", Icons.smartphone),
              _card("$email", Icons.email),
              const SizedBox(height: 10),
              Text('Tipologia chat'),
              _radioListTile("Solo testo", SingingCharacter.text),
              _radioListTile("Videochiamata", SingingCharacter.video_call),
              _radioListTile("Chiamata vocale", SingingCharacter.voice_call),
            ],
          ),
        ),
        onTap: () {
          print("TAP UTENTE");
          FirebaseFirestore.instance
              .collection('patients')
              .doc(cod_fiscale)
              .update({'status': 'online'});
          timer.cancel();
          timer_alert.cancel();
          timer = Timer(online_duration, handleTimeout);
          timer_alert = Timer(alert_duration, callback);
        },
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

  Widget _radioListTile(String text, SingingCharacter value) {
    return RadioListTile<SingingCharacter>(
      title: Text(text),
      value: value,
      groupValue: _character,
      onChanged: null,
    );
  }

  void handleTimeout() {
    print("TIMEOUT\nCod_fiscale: " + cod_fiscale);
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
    ultimo_accesso = dateFormat.format(DateTime.now());
    FirebaseFirestore.instance
        .collection('patients')
        .doc(cod_fiscale)
        .update({'status': 'offline', 'ultimo_accesso': ultimo_accesso});
  }

  Future<void> callback() async {
    print("ALERT\nCod_fiscale: " + cod_fiscale);

    var status;

    await FirebaseFirestore.instance
        .collection('patients')
        .doc(cod_fiscale)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        status = doc.data();
        print(status);
        print(status["status"].toString().compareTo("2022/01/08 16:50"));
        if (status["status"].toString().compareTo("online") == 0 ||
            (status["status"].toString().compareTo("offline") == 0 &&
                status["ultimo_accesso"].toString().compareTo(ultimo_accesso) ==
                    1))
          timer_alert.cancel();
        else
          FirebaseFirestore.instance.collection('notifications').add({
            'alert': true,
            'letto': false,
            'cod_fiscale': cod_fiscale,
            'nome': nome,
            'cognome': cognome,
            'ultimo_accesso': ultimo_accesso
          });
      }
    });
  }
}
