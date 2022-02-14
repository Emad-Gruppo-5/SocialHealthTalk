// ignore_for_file: unnecessary_const

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:test_emad/main.dart';
import 'main_dottore.dart';
import 'profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// This is the main application widget.
class NewQuestion extends StatefulWidget {
  final String paz_cod_fiscale;
  final String token;
  final String cod_fiscale;
  final String nome;
  final String cognome;
  final String email;
  final String num_cellulare;
  final String specializzazione;

  NewQuestion({
    required this.paz_cod_fiscale,
    required this.cod_fiscale,
    required this.token,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.num_cellulare,
    required this.specializzazione,
  });

  @override
  NewQuestionState createState() => NewQuestionState();
}

class NewQuestionState extends State<NewQuestion> {
  late String paz_cod_fiscale;
  late String token;
  late String cod_fiscale;
  late String nome;
  late String cognome;
  late String email;
  late String num_cellulare;
  late String specializzazione;

  @override
  void initState() {
    print("initState");
    cod_fiscale = widget.cod_fiscale;
    token = widget.token;
    nome = widget.nome;
    cognome = widget.cognome;
    email = widget.email;
    num_cellulare = widget.num_cellulare;
    specializzazione = widget.specializzazione;
    paz_cod_fiscale = widget.paz_cod_fiscale;
    super.initState();
  }

  String _testo_domanda = " ";
  TextEditingController _data_domanda_DA = TextEditingController();
  TextEditingController _data_domanda_A = TextEditingController();
  TextEditingController _ora_domanda = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<bool> isChecked = [false, true, false];
  String dropdownValue = 'Una volta';
  bool _repeat = false;

  Widget _iconButton(BuildContext context, IconData icon, String tooltip,
      StatelessWidget statelessWidget) {
    IconButton iconButton;

    if (tooltip != "Logout") {
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
      );
    }

    return iconButton;
  }

  Widget _iconButton2(BuildContext context, IconData icon, String tooltip,
      StatefulWidget statelessWidget) {
    IconButton iconButton;

    iconButton = IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => statelessWidget),
        );
      },
    );

    return iconButton;
  }

  Widget _form() {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.help_center_rounded),
                    labelText: "Inserisci domanda",
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ricordati di inserire la domanda";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _testo_domanda = value;
                  },
                )),
            Visibility(
                visible: !_repeat,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DateTimePicker(
                    controller: _data_domanda_DA,
                    type: DateTimePickerType.dateTimeSeparate,
                    dateMask: 'd MMM, yyyy',
                    locale: const Locale("it", "IT"),
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(Duration(days: 0)),
                    lastDate: DateTime(2100),
                    icon: const Icon(Icons.event),
                    dateLabelText: 'Data',
                    timeLabelText: "Ora",
                    selectableDayPredicate: (date) {
                      _textFormField(
                          Icons.help_center_rounded,
                          "Inserisci data",
                          "Ricordati di inserire la data",
                          _data_domanda_DA);
                      return true;
                    },
                    onChanged: (val) {
                      print(val);
                      _textFormField(
                          Icons.help_center_rounded,
                          "Inserisci data",
                          "Ricordati di inserire la data",
                          _data_domanda_DA);
                    },
                  ),
                )),
            Visibility(
              visible: _repeat,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DateTimePicker(
                      controller: _data_domanda_DA,
                      type: DateTimePickerType.date,
                      dateMask: 'd MMM, yyyy',
                      locale: const Locale("it", "IT"),
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 0)),
                      lastDate: DateTime(2100),
                      icon: const Icon(Icons.event),
                      dateLabelText: 'Da',
                      selectableDayPredicate: (date) {
                        _textFormField(
                            Icons.help_center_rounded,
                            "Inserisci data",
                            "Ricordati di inserire la data",
                            _data_domanda_DA);
                        return true;
                      },
                      onChanged: (val) {
                        print(val);
                        _textFormField(
                            Icons.help_center_rounded,
                            "Inserisci data",
                            "Ricordati di inserire la data",
                            _data_domanda_DA);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DateTimePicker(
                      controller: _data_domanda_A,
                      type: DateTimePickerType.date,
                      dateMask: 'd MMM, yyyy',
                      locale: const Locale("it", "IT"),
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 0)),
                      lastDate: DateTime(2100),
                      icon: const Icon(Icons.event),
                      dateLabelText: 'A',
                      selectableDayPredicate: (date) {
                        _textFormField(
                            Icons.help_center_rounded,
                            "Inserisci data",
                            "Ricordati di inserire la data",
                            _data_domanda_A);
                        return true;
                      },
                      onChanged: (val) {
                        print(val);
                        _textFormField(
                            Icons.help_center_rounded,
                            "Inserisci data",
                            "Ricordati di inserire la data",
                            _data_domanda_A);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DateTimePicker(
                      controller: _ora_domanda,
                      type: DateTimePickerType.time,
                      locale: const Locale("it", "IT"),
                      icon: const Icon(Icons.access_time),
                      timeLabelText: "Ora",
                      selectableDayPredicate: (date) {
                        _textFormField(
                            Icons.help_center_rounded,
                            "Inserisci ora",
                            "Ricordati di inserire l'ora'",
                            _ora_domanda);
                        return true;
                      },
                      onChanged: (val) {
                        print(val);
                        _textFormField(
                            Icons.help_center_rounded,
                            "Inserisci ora",
                            "Ricordati di inserire l'ora",
                            _ora_domanda);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              title: const Text('Ripeti'),
              value: _repeat,
              onChanged: (bool value) {
                setState(() {
                  _repeat = value;
                  _data_domanda_DA.clear();
                  _data_domanda_A.clear();
                  _ora_domanda.clear();
                });
              },
              secondary: const Icon(Icons.repeat),
              contentPadding: const EdgeInsets.symmetric(horizontal: 100),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
                    print(_repeat);
                    print(_data_domanda_DA.text);
                    print(_data_domanda_A.text);
                    print(_ora_domanda);
                    var dif;
                    if (_repeat == true) {
                      dif = DateTime.parse(_data_domanda_DA.text)
                          .difference(DateTime.parse(_data_domanda_A.text))
                          .inDays
                          .abs();
                      print("DIFFERENZA: " + dif.toString());
                    }

                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      DateFormat data_query_format = DateFormat("yyyy-MM-dd");
                      CollectionReference questions =
                          FirebaseFirestore.instance.collection('questions_to_answer');
                      questions.add({
                        'cod_fiscale_dottore': cod_fiscale,
                        'cod_fiscale_paziente': paz_cod_fiscale,
                        'cognome': cognome,
                        'nome': nome,
                        'letto': false,
                        'data_domanda': _repeat == true
                            ? _data_domanda_DA.text + " " + _ora_domanda.text
                            : _data_domanda_DA.text,
                        'ripeti': _repeat == true ? dif : 0,
                        'testo_domanda': _testo_domanda
                      });
                      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
                          .showSnackBar(const SnackBar(
                              content: Text("Domanda inviata con successo")));
                    }
                  },
                  child: const Text('Invia'),
                ),
              ),
            ),
          ],
        ));
  }

  StatefulWidget _textFormField(IconData icon, String labelText,
      String validator, TextEditingController _con) {
    return TextFormField(
      controller: _con,
      decoration: InputDecoration(
        icon: Icon(icon),
        labelText: labelText,
      ),
      // The validator receives the text that the user has entered.
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validator;
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: [const Locale('it')],
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: _iconButton(
              context,
              Icons.arrow_back_ios,
              'Indietro',
              Profile(
                  nome: nome,
                  cognome: cognome,
                  email: email,
                  num_cellulare: num_cellulare,
                  specializzazione: specializzazione,
                  cod_fiscale: cod_fiscale,
                  token: token)),
          title: Text("Invio nuova domanda"),
          actions: [
            _iconButton2(context, Icons.logout, 'Logout', LoginPage()),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
          child: Column(
            children: [
              SizedBox(height: 10,),
              SizedBox(height: 10,),
              _form(),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
