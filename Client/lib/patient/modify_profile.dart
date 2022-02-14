import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_emad/patient/profile.dart';
import '../main.dart';
import '../costanti.dart';

class ModifyProfile extends StatefulWidget {
  final String nome;
  final String cognome;
  final String email;
  final String num_cellulare;
  final int tipologia_chat;
  final String cod_fiscale;
  final String token;

  const ModifyProfile(
      {required this.cod_fiscale,
      required this.nome,
      required this.cognome,
      required this.email,
      required this.num_cellulare,
      required this.tipologia_chat,
      required this.token});

  @override
  _ModifyProfile createState() => _ModifyProfile();
}

enum SingingCharacter { testo, videochiamata, chiamata }

/// This is the main application widget.
class _ModifyProfile extends State<ModifyProfile> {
  late String nome;
  late String cognome;
  late String email;
  late String num_cellulare;
  late int tipologia_chat;
  late String cod_fiscale;
  late String token;
  late String ultimo_accesso;
  SingingCharacter? _character;
  late TextEditingController _email;
  late TextEditingController _num_cell;
  CollectionReference notifications = FirebaseFirestore.instance.collection('notifications');
  @override
  void initState() {
    nome = widget.nome;
    cognome = widget.cognome;
    email = widget.email;
    num_cellulare = widget.num_cellulare;
    tipologia_chat = widget.tipologia_chat;
    cod_fiscale = widget.cod_fiscale;
    token = widget.token;
    switch (tipologia_chat) {
      case 0: _character = SingingCharacter.testo;
        break;
      case 1: _character = SingingCharacter.videochiamata;
        break;
      case 2: _character = SingingCharacter.chiamata;
        break;
    }
    _num_cell = TextEditingController(text: num_cellulare);
    _email = TextEditingController(text: email);
    super.initState();
  }
  
  Duration alert_duration = Duration(seconds: alert_dur);
  Duration online_duration = Duration(seconds: online_dur);
  late Timer timer;
  late Timer timer_alert;
  String timerText = "Start";
  // bool _visible = false;

  Widget _iconButtonPush(
      BuildContext context, IconData icon, String tooltip) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () {
        timer.cancel();
        timer_alert.cancel();
        DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm");
        String ultimo_accesso = dateFormat.format(DateTime.now());
        FirebaseFirestore.instance
            .collection('patients')
            .doc(cod_fiscale)
            .update({'status': 'offline', 'ultimo_accesso': ultimo_accesso});

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
    );
  }

  Widget _iconButtonPop(BuildContext context, IconData icon, String tooltip) {
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
                    builder: (BuildContext context) => Profile(
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    timer = Timer(online_duration, handleTimeout);
    timer_alert = Timer(alert_duration, callback);
    return MaterialApp(
      home: GestureDetector(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            leading: _iconButtonPop(context, Icons.arrow_back_ios, 'Indietro'),
            title: const Center(
              child: Text("Modifica dati"),
            ),
            actions: [
              _iconButtonPush(context, Icons.logout, 'Logout'),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
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
                _form(),
                const Text("\nTipologia chat"),
                  ListTile(
                    title: const Text('Solo testo'),
                    leading: Radio<SingingCharacter>(
                      value: SingingCharacter.testo,
                      groupValue: _character,
                      onChanged: (SingingCharacter? value) {
                        setState(() {
                          _character = value;
                        });
                        timer.cancel();
                        timer_alert.cancel();
                        print("UPDATE FIRESTORE");
                        FirebaseFirestore.instance
                            .collection('patients')
                            .doc(cod_fiscale)
                            .update({'status': 'online'});
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Videochiamata'),
                    leading: Radio<SingingCharacter>(
                      value: SingingCharacter.videochiamata,
                      groupValue: _character,
                      onChanged: (SingingCharacter? value) {
                        setState(() {
                          _character = value;
                        });
                        timer.cancel();
                        timer_alert.cancel();
                        print("UPDATE FIRESTORE");
                        FirebaseFirestore.instance
                            .collection('patients')
                            .doc(cod_fiscale)
                            .update({'status': 'online'});
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Chiamata vocale'),
                    leading: Radio<SingingCharacter>(
                      value: SingingCharacter.chiamata,
                      groupValue: _character,
                      onChanged: (SingingCharacter? value) {
                        setState(() {
                          _character = value;
                        });
                        timer.cancel();
                        timer_alert.cancel();
                        print("UPDATE FIRESTORE");
                        FirebaseFirestore.instance
                            .collection('patients')
                            .doc(cod_fiscale)
                            .update({'status': 'online'});
                      },
                    ),
                  ),
                _submitButton(),
              ],
            ),
          ),
        ),
        onTap: () {
          print("UPDATE FIRESTORE");
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

  void handleTimeout() {
    print("TIMEOUT\nCod_fiscale: " + cod_fiscale);
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
    ultimo_accesso = dateFormat.format(DateTime.now());
    FirebaseFirestore.instance
        .collection('patients')
        .doc(cod_fiscale)
        .update({'status': 'offline', 'ultimo_accesso': ultimo_accesso});
  }

  void callback() {
    print("ALERT\nCod_fiscale: " + cod_fiscale);
    FirebaseFirestore.instance
        .collection('notifications')
        .add({
              'alert': true,
              'letto': false,
              'cod_fiscale': cod_fiscale,
              'nome': nome,
              'cognome': cognome,
              'ultimo_accesso': ultimo_accesso
        });
  }

  Widget _submitButton() {
     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () {
         bool flag;
         Duration flash_duration = const Duration(seconds: 3);
          print("UPDATE FIRESTORE");
          FirebaseFirestore.instance
              .collection('patients')
              .doc(cod_fiscale)
              .update({'status': 'online'});
          timer.cancel();
          timer_alert.cancel();
          timer = Timer(online_duration, handleTimeout);
          timer_alert = Timer(alert_duration, callback);

          // Validate returns true if the form is valid, or false otherwise.
          if (_formKey.currentState!.validate()) {
            DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm");
            String data_notifica = dateFormat.format(DateTime.now());
            notifications.add({
              'alert': false,
              'cod_fiscale': cod_fiscale,
              'letto': false,
              'nome': nome,
              'cognome': cognome,
              'data': data_notifica,
              'email': _email.text,
              'num_cellulare': _num_cell.text,
              'tipologia_chat': _character!.index
            })
            .then((value) {
                  print("Notifica aggiunta\ncod_fiscale: $cod_fiscale, email: " 
                                  + _email.text + ", num_cellulare: " + _num_cell.text 
                                  + ", tipologia_chat: " + _character!.index.toString());
                  flag = true;
                  _showBasicsFlash(flag, online_duration);
            })
            .catchError((error) {
                print("Errore nell'aggiunta della notifica: $error");
                flag = false;
                _showBasicsFlash(flag, online_duration);
            });
            
          }
          
        },
        child: const Text('Salva'),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _num_cell,
              decoration: InputDecoration(
                icon: Icon(Icons.smartphone),
                labelText: "Numero di cellulare",
              ),
              // initialValue: "$num_cellulare",
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Inserisci numero di cellulare";
                }

                return null;
              },
              onTap: () {
                print("UPDATE FIRESTORE");
                FirebaseFirestore.instance
                    .collection('patients')
                    .doc(cod_fiscale)
                    .update({'status': 'online'});
                timer.cancel();
                timer_alert.cancel();
                timer = Timer(online_duration, handleTimeout);
                timer_alert = Timer(alert_duration, callback);
              },
              onChanged: (value) {
                print("UPDATE FIRESTORE");
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
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                controller: _email,
                decoration: InputDecoration(
                  icon: Icon(Icons.email),
                  labelText: "E-mail",
                ),
                // initialValue: "$email",
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Inserisci e-mail";
                  }
                  return null;
                },
                onTap: () {
                  print("UPDATE FIRESTORE");
                  FirebaseFirestore.instance
                      .collection('patients')
                      .doc(cod_fiscale)
                      .update({'status': 'online'});
                  timer.cancel();
                  timer_alert.cancel();
                  timer = Timer(online_duration, handleTimeout);
                  timer_alert = Timer(alert_duration, callback);
                },
                onChanged: (value) {
                  print("UPDATE FIRESTORE");
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
          ),
        ],
      ),
    );
  }

  void _showBasicsFlash(bool flag, Duration duration ) {
    showFlash(
      context: context,
      duration: duration,
      builder: (context, controller) {
        String text = flag ? "Richiesta inviata con successo" : "Errore, richiesta non inviata";
        var flashStyle = FlashBehavior.floating;
        return Flash(
          controller: controller,
          behavior: flashStyle,
          position: FlashPosition.bottom,
          boxShadows: kElevationToShadow[4],
          backgroundColor: Colors.black87,
          horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          child: FlashBar(
            content: Text(text, style: const TextStyle(
              color: Colors.white,
            ),),
          ),
        );
      },
    );
  }

}
