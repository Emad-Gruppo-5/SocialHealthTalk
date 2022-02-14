import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import '../costanti.dart';
import '../main.dart';
import 'profile.dart';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_emad/costanti.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart' as ap;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:flash/flash.dart';

/// This is the main application widget.
class Patient_Home extends StatelessWidget {
  final String token;
  final String cod_fiscale;
  final String nome;
  final String cognome;
  final String email;
  final String num_cellulare;
  final int tipologia_chat;

  Patient_Home({
    required this.cod_fiscale,
    required this.token,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.num_cellulare,
    required this.tipologia_chat,
  });

  static const String _title = 'Social Health Talk';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatefulWidget(
          nome: nome,
          cognome: cognome,
          email: email,
          num_cellulare: num_cellulare,
          tipologia_chat: tipologia_chat,
          token: token,
          cod_fiscale: cod_fiscale),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  final String token;
  final String cod_fiscale;
  final String nome;
  final String cognome;
  final String email;
  final String num_cellulare;
  final int tipologia_chat;

  MyStatefulWidget({
    required this.cod_fiscale,
    required this.token,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.num_cellulare,
    required this.tipologia_chat,
  });

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  // final String cod_fiscale;
  late String nome;
  late String cognome;
  late String email;
  late String num_cellulare;
  late int tipologia_chat;
  late String token;
  late String cod_fiscale;

  Duration online_duration = Duration(seconds: online_dur);
  Duration alert_duration = Duration(seconds: alert_dur);
  Duration question_duration = Duration(seconds: question_dur);
  late Timer timer;
  late Timer timer_alert;
  String timerText = "Start";
  late String ultimo_accesso;

  CollectionReference _notificationsReference =
      FirebaseFirestore.instance.collection('questions_to_answer');

  Widget _iconButtonPush(BuildContext context, IconData icon, String tooltip) {
    print("cod_fiscale: " + cod_fiscale);
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () {
        timer.cancel();
        timer_alert.cancel();
        print("TAP UTENTE");
        FirebaseFirestore.instance
            .collection('patients')
            .doc(cod_fiscale)
            .update({'status': 'online'});

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Profile(
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
  }

  Widget _iconButtonPop(BuildContext context, IconData icon, String tooltip) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    timer = Timer(online_duration, handleTimeout);
    timer_alert = Timer(alert_duration, callback);

    FirebaseFirestore.instance
        .collection('patients')
        .doc(cod_fiscale)
        .update({'status': 'online'});
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
    print(dateFormat.format(DateTime.now()));
    return MaterialApp(
      home: GestureDetector(
        child: Scaffold(
          appBar: AppBar(
            leading: _iconButtonPush(
              context,
              Icons.account_circle,
              'Profilo',
            ),
            title: const Text("Promemoria giornalieri"),
            actions: [
              _iconButtonPop(context, Icons.logout, 'Logout'),
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: _notificationsReference
                .where('cod_fiscale_paziente', isEqualTo: cod_fiscale)
                .orderBy("data_domanda", descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.docs.isEmpty) {
                return Center(
                    child: Image.asset('assets/images/promemoria.png'));
              } else
                // ignore: curly_braces_in_flow_control_structures
                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    String subtitle = "";
                    Icon trailing;
                    print(data.toString());
                    Timer timer_question = Timer(question_duration, (){
                                                          print("ELIMINATO? " + document.id.toString());
                                                          document.reference.delete();
                                                        } );
                    return Center(
                      child: Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Visibility(
                                    child: const Icon(Icons.circle,
                                        color: Colors.blue, size: 15),
                                    visible: !data['letto'],
                                  ),
                                ],
                              ),
                              title: Text(data['testo_domanda']),
                              subtitle: Text("Inviata da: " +
                                  data["nome"] +
                                  " " +
                                  data["cognome"] +
                                  "\n" +
                                  data["data_domanda"]),
                              onTap: () {
                                _notificationsReference
                                    .doc(document.id)
                                    .update({'letto': true})
                                    .then((value) =>
                                        print("Notification Updated"))
                                    .catchError((error) => print(
                                        "Failed to update notifications: $error"));
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    String contentText = "Content of Dialog";
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          title: Text(data['testo_domanda']),
                                          content: TextField(
                                            enabled: !isAudio,
                                            onChanged: (value) {
                                              risposta = value;
                                            },
                                            controller: _textFieldController,
                                            decoration: const InputDecoration(
                                                hintText: "Risposta testuale"),
                                          ),
                                          actions: <Widget>[
                                            IconButton(
                                              onPressed: () {
                                                if (_isRecording == false) {
                                                  setState(() {
                                                    _isRecording = true;
                                                  });
                                                  _start();
                                                } else {
                                                  setState(() {
                                                    _isRecording = false;
                                                    isAudio = true;
                                                  });
                                                  _stop(data, document);
                                                }
                                              },
                                              icon: _icon(),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                if (_isRecording == false) {
                                                  if (risposta != " " ||
                                                      isAudio) {
                                                    sendRispostaToDatabase(data,
                                                        document, isAudio, timer_question);
                                                    Navigator.pop(context);
                                                  } else {
                                                    _showBasicsFlash(
                                                        "É necessario registare o scrivere qualcosa prima di inviare una risposta");
                                                  }
                                                  isAudio = false;
                                                } else {
                                                  _showBasicsFlash(
                                                      'Impossibile inviare messaggi mentre si sta registrando');
                                                }
                                              },
                                              child: _text(),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            // row,
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
            },
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

  Widget _card(String title, String subtitle) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  void handleTimeout() {
    print("TIMEOUT\nCod_fiscale: " + cod_fiscale);
    DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm");
    ultimo_accesso = dateFormat.format(DateTime.now());
    FirebaseFirestore.instance
        .collection('patients')
        .doc(cod_fiscale)
        .update({'status': 'offline', 'ultimo_accesso': ultimo_accesso});
  }

  void questionTimeout() {
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

  bool _isRecording = false;
  final _audioRecorder = Record();
  var _textFieldController;
  String risposta = " ";
  bool isAudio = false;

  @override
  void initState() {
    _isRecording = false;
    cod_fiscale = widget.cod_fiscale;
    token = widget.token;
    nome = widget.nome;
    cognome = widget.cognome;
    email = widget.email;
    num_cellulare = widget.num_cellulare;
    tipologia_chat = widget.tipologia_chat;
    super.initState();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        if (kIsWeb) {
          String appDocPath = "/assets/record";
          await _audioRecorder.start(
            encoder: AudioEncoder.AAC, // by default
            bitRate: 128000,
          );
          bool isRecording = await _audioRecorder.isRecording();
        } else {
          Directory? appDocDir = await getExternalStorageDirectory();
          String? appDocPath = appDocDir?.path;
          await _audioRecorder.start(
            path: '$appDocPath/myFile.wav',
            encoder: AudioEncoder.AAC, // by default
            bitRate: 128000,
          );
          bool isRecording = await _audioRecorder.isRecording();

          setState(() {
            _isRecording = isRecording;
          });
        }
        _showBasicsFlash("Registazione iniziata");
      }
    } catch (e) {
      print(e);
    }
  }

  late String path2;

  _stop(Map data, DocumentSnapshot<Object?> document) async {
    final path = await _audioRecorder.stop();
    ap.AudioSource? audioSource;
    audioSource = ap.AudioSource.uri(Uri.parse(path!));
    print(path);
    path2 = path;
    _showBasicsFlash("Registrazione salvata con successo");
  }

  _icon() {
    if (_isRecording == false) {
      return const Icon(Icons.mic_none_sharp, color: Colors.blue);
    } else {
      return const Icon(Icons.stop, color: Colors.blue);
    }
  }

  _text() {
    if (isAudio == false) {
      return const Text("Invio testo");
    } else {
      return const Text("Invia registrazione");
    }
  }

  sendRispostaToDatabase(
      Map fireData, DocumentSnapshot<Object?> document, bool isAudio, Timer timer) async {
    try {
      String base64String;
      String downloadUrl;
      if (isAudio) {
        DateFormat data_risposta_format = DateFormat("yyyy-MM-dd HH:mm");
        DateFormat data_query_format = DateFormat("yyyy-MM-dd");
        Random random = new Random();
        int randomNumber = random.nextInt(10000);

        String namefile = cod_fiscale + data_query_format.format(DateTime.now()).toString() + DateFormat.Hm().format(DateTime.now()).toString() + randomNumber.toString();
        print(namefile);

        File file = File(path2);
        risposta = "null";
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref =
            storage.ref().child(namefile);
        UploadTask uploadTask = ref.putFile(file);
        uploadTask.whenComplete(() async {
          downloadUrl = await ref.getDownloadURL();
          print(downloadUrl);
          var uri;
          // if (kIsWeb) {
          uri = Uri.parse(urlServer + 'aggiungi_domanda');
          // } else
          //   uri = Uri.parse('http://10.0.2.2:5000/aggiungi_domanda');

          Map<String, String> message = {
            "audio_risposta": namefile,
            "data_risposta": data_risposta_format.format(DateTime.now()),
            "cod_fiscale_paziente": cod_fiscale,
            "data_domanda": fireData["data_domanda"],
            "testo_domanda": fireData["testo_domanda"],
            "cod_fiscale_dottore": fireData["cod_fiscale_dottore"],
            "testo_risposta": risposta,
            "data_query": data_query_format.format(DateTime.now()),
            "url_audio": downloadUrl
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
          if (data.statusCode != 200) {
            print("ERRORE LATO POSTGRESQL: err: ");
            _showBasicsFlash("Risposta non inserita");
          } else {
            timer.cancel();
            _showBasicsFlash('Risposta inviata con successo');
            document.reference.delete();
          }
          return data.statusCode;
        }).catchError((onError) {
          print(onError);
        });
      } else {
        var uri;
        // if (kIsWeb) {
        uri = Uri.parse('http://' + urlServer + ':5000/aggiungi_domanda');
        // } else
        //   uri = Uri.parse('http://10.0.2.2:5000/aggiungi_domanda');

        DateFormat data_risposta_format = DateFormat("yyyy-MM-dd HH:mm");
        DateFormat data_query_format = DateFormat("yyyy-MM-dd");

        Map<String, String> message = {
          "audio_risposta": "null",
          "data_risposta": data_risposta_format.format(DateTime.now()),
          "cod_fiscale_paziente": cod_fiscale,
          "data_domanda": fireData["data_domanda"],
          "testo_domanda": fireData["testo_domanda"],
          "cod_fiscale_dottore": fireData["cod_fiscale_dottore"],
          "testo_risposta": risposta,
          "data_query": data_query_format.format(DateTime.now()),
          "url_audio": "null"
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
        if (data.statusCode != 200) {
          print("ERRORE LATO POSTGRESQL: err: ");
          _showBasicsFlash("Risposta non inserita");
        } else {
          timer.cancel();
          _showBasicsFlash('Risposta inviata con successo');
          document.reference.delete();
        }
        return data.statusCode;
      }
    } catch (e) {
      print(e.toString());

      return null;
    }
  }

  void _showBasicsFlash(String text) {
    Duration duration = const Duration(seconds: 3);
    showFlash(
      context: context,
      duration: duration,
      builder: (context, controller) {
        var flashStyle = FlashBehavior.floating;
        return Flash(
          controller: controller,
          behavior: flashStyle,
          position: FlashPosition.bottom,
          boxShadows: kElevationToShadow[4],
          backgroundColor: Colors.black87,
          horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          child: FlashBar(
            content: Text(
              text,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
