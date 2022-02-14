import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart' as ap;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class Popup extends StatelessWidget {
  Popup({Key? key}) : super(key: key);

  Widget _iconButtonPush(BuildContext context, IconData icon, String tooltip,
      StatelessWidget statelessWidget) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      iconSize: 40,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => statelessWidget),
        );
      },
    );
  }

  Widget _iconButtonPop(BuildContext context, IconData icon, String tooltip) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      iconSize: 40,
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: MyPopup(),
        ),
      ),
    );
  }
}

/// This is the stateless widget that the main application instantiates.
class MyPopup extends StatefulWidget {
  MyPopupState createState() => MyPopupState();
}

class MyPopupState extends State<MyPopup> {
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  final _audioRecorder = Record();
  Amplitude? _amplitude;
  var _textFieldController;

  @override
  void initState() {
    _isRecording = false;
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

          setState(() {
            _isRecording = isRecording;
          });
        } else {
          Directory? appDocDir = await getExternalStorageDirectory();
          String? appDocPath = appDocDir?.path;
          await _audioRecorder.start(
            path: '$appDocPath/myFile.mp3',
            encoder: AudioEncoder.AAC, // by default
            bitRate: 128000,
          );
          bool isRecording = await _audioRecorder.isRecording();

          setState(() {
            _isRecording = isRecording;
          });
        }
        final snackBar = SnackBar(
          content: const Text('Registrazione iniziata'),
        );
        // Find the ScaffoldMessenger in the widget tree
        // and use it to show a SnackBar.
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print(e);
    }
  }

  late String path2;

  Future<void> _stop() async {
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
    });
    ap.AudioSource? audioSource;
    audioSource = ap.AudioSource.uri(Uri.parse(path!));
    print(path);
    path2 = path;
    final snackBar = SnackBar(
      content: const Text('Registrazione inviata con successo'),
    );
    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    sendFile();
  }

  _icon() {
    if (_isRecording == false) {
      return const Icon(Icons.mic_none_sharp, color: Colors.blue);
    } else {
      return const Icon(Icons.stop, color: Colors.blue);
    }
  }

  Stopwatch watch = Stopwatch();

  bool startStop = true;

  String elapsedTime = '';

  updateTime(Timer timer) {
    if (watch.isRunning) {
      setState(() {
        print("startstop Inside=$startStop");
        elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
      });
    }
  }

  startOrStop() {
    if (startStop) {
      startWatch();
    } else {
      stopWatch();
    }
  }

  startWatch() {
    setState(() {
      startStop = false;
      watch.start();
      Timer timer = Timer.periodic(Duration(milliseconds: 100), updateTime);
    });
  }

  stopWatch() {
    setState(() {
      startStop = true;
      watch.stop();
      setTime();
    });
  }

  setTime() {
    var timeSoFar = watch.elapsedMilliseconds;
    setState(() {
      elapsedTime = transformMilliSeconds(timeSoFar);
    });
  }

  transformMilliSeconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  sendFile() async {
    try {
      File file = File(path2);
      file.openRead();
      List<int> fileBytes = await file.readAsBytes();
      String base64String = base64Encode(fileBytes);
      final fileString = 'data:audio/mp3;base64,$base64String';
      var uri = Uri.parse('http://10.0.2.2:5000/audiofile');

      Map<String, String> message = {
        "audio": fileString,
        "id": 2.toString(),//TODO id_domanda
        "date": DateTime.now().toString()
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

    } catch (e) {
      print(e.toString());

      return null;
    }

  }

  Future<void> sendText() async {
    var uri = Uri.parse('http://10.0.2.2:5000/textrisposta');
    print(uri);
    int role = 1;

    Map<String, dynamic> message = {
      "risposta": _textFieldController,
      "id": 2.toString(),//TODO id_domanda
      "date": DateTime.now().toString()
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
      final snackBar = SnackBar(
        content: const Text('Domanda inserita con successo'),
      );
      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print("ERRORE LATO POSTGRESQL: err: ");
      const snackBar = const SnackBar(
        content: Text('Domanda non inserita'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showDialog(
        context: context,
        builder: (context) {
          String contentText = "Content of Dialog";
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Hai preso la pillola?'),
                content: TextField(
                  onChanged: (value) {},
                  controller: _textFieldController,
                  decoration: InputDecoration(hintText: "Risposta testuale"),
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
                        });
                        _stop();
                        Navigator.pop(context, 'Cancel');
                      }
                      startOrStop();
                    },
                    icon: _icon(),
                  ),
                  TextButton(
                    onPressed: () {
                      if(_isRecording==false){
                        sendText();
                        Navigator.pop(context, 'Cancel');}
                      else {
                        final snackBar = SnackBar(
                          content: const Text(
                              'Impossibile inviare testo mentre si sta registrando'),
                        );
                        // Find the ScaffoldMessenger in the widget tree
                        // and use it to show a SnackBar.
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }

                    },
                    child: const Text('Invio'),
                  ),
                ],
              );
            },
          );
        },
      ),
      child: const Text('Mostra prova notifica'),
    );
  }
}
