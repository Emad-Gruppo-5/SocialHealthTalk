import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatoAttivitaPazienti extends StatefulWidget {
  @override
  BodyLayout createState() => BodyLayout();
}

class BodyLayout extends State<StatoAttivitaPazienti> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stato attività pazienti',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: new AppBar(
          title: const Text('Stato attività pazienti'),
          leading: new IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
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
                    return Center(
                      child: ListTile(
                        title: Text(patient['nome'] + " " + patient['cognome']),
                        subtitle: Text(patient['status'] == 'online'
                            ? 'online'
                            : 'ultimo accesso: ' + patient['ultimo_accesso']),
                        trailing: Icon(
                          Icons.circle,
                          color: patient['status'] == 'online'
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
        ),
      ),
    );
  }
}
