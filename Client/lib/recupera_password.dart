import 'package:flutter/material.dart' hide Key;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:crypt/crypt.dart';
import 'package:test_emad/dottore/main_dottore.dart';
import 'package:test_emad/patient/home.dart';
import 'package:test_emad/admin/adminHome.dart';

import 'costanti.dart';


class RecuperaPassword extends StatefulWidget {
  @override
  _RecuperaPassword createState() => _RecuperaPassword();

}



class _RecuperaPassword extends State<RecuperaPassword> {
  TextEditingController _cod_fiscaleC = TextEditingController();

  Future<String> recuperaPassword(cod_fiscale) async {

    var uri = Uri.parse(urlServer + 'recupera_password');
    
    print(uri);

    Map<String, String> message = {
      "cod_fiscale": cod_fiscale,
    };
    var body = json.encode(message);
    print("\nBODY:: " + body);
    final data = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: body);
    print('Response status: ${data.statusCode}');
    print('Response body: ${data.body}');
    return data.body;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, colors: [
          Colors.lightBlue.shade200,
          Colors.lightBlue.shade100,
          Colors.lightBlue.shade200
        ])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Text("Login", style: TextStyle(color: Colors.white, fontSize: 40),),
                  // SizedBox(height: 10,)
                  Center(child: Image.asset('assets/images/SHT.png'))
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60))),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(109, 193, 255, .3),
                                    blurRadius: 20,
                                    offset: Offset(0, 10))
                              ]),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.shade200))),
                                child: TextField(
                                  controller: _cod_fiscaleC,
                                  decoration: InputDecoration(
                                      hintText: "Codice fiscale",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                            height: 50,
                            margin: EdgeInsets.symmetric(horizontal: 50),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(90),
                                color: Colors.lightBlue.shade700),
                            child: ElevatedButton(
                              onPressed: () {
                                var cod_fiscale = _cod_fiscaleC.text;

                                recuperaPassword(cod_fiscale).then((data) {
                                    print(data);
                                    ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(content: Text('Utente non esistente')));
                                    Navigator.pop(context);
                                })
                                .catchError((error) => {
                                  ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(content: Text('Utente non esistente'))),
                                          print(error)
                                });
                              },
                              child: Center(
                                  child: Text(
                                "Recupera password",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(90)),
                                  primary: Colors.lightBlue.shade700),
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        const Divider(
                            height: 20,
                            thickness: 1,
                            indent: 10,
                            endIndent: 30),
                            SizedBox(height: 20, ),
                          Container(
                            height: 50,
                            margin: EdgeInsets.symmetric(horizontal: 50),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.lightBlue.shade600
                                
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                               Navigator.pop(context);
                              },
                              child: Center(
                                  child: Text(
                                "Ritorna al Login",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(90)),
                                  primary: Colors.lightBlue.shade900),
                            )
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
