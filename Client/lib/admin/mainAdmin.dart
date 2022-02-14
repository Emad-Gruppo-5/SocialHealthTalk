import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:test_emad/admin/lista_pazienti.dart';
import 'package:test_emad/admin/lista_dottori.dart';
import 'package:test_emad/admin/lista_familiari.dart';
import 'package:test_emad/admin/notifications.dart';
import 'package:test_emad/admin/stato_attivita_pazienti.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_emad/main.dart';

class MainAdmin extends StatefulWidget {
  @override
  MyMainAdmin createState() => MyMainAdmin();
}

class MyMainAdmin extends State<MainAdmin> {
  int key = 0;

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    int online, offline, _notificationsLength;

    final Stream<QuerySnapshot> _notifications = FirebaseFirestore.instance
        .collection('notifications')
        .where('letto', isEqualTo: false)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => LoginPage(),
                  ),
                );
              },
              tooltip: "Logout",
            );
          },
        ),
        title: const Text("Admin"),
        actions: [
          StreamBuilder<QuerySnapshot>(
              stream: _notifications,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                _notificationsLength = snapshot.data!.docs.length;

                bool showBadge = true;
                if (_notificationsLength == 0) showBadge = false;

                return Badge(
                  badgeContent: Text('$_notificationsLength'),
                  child: IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => Notifications(),
                        ),
                      );
                    },
                    tooltip: "Notifiche",
                  ),
                  position: BadgePosition.topEnd(top: 0, end: 0),
                  showBadge: showBadge,
                );
              }),
        ],
      ),
      body: Center(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("patients")
                .where('status', isEqualTo: 'online')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
                // return Center(
                //     child: Image.asset(
                //   'assets/images/loading.gif',
                // )
                // );
              }
              online = snapshot.data!.docs.length;

              return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("patients")
                      .where('status', isEqualTo: 'offline')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    offline = snapshot.data!.docs.length;

                    return MaterialApp(
                        debugShowCheckedModeBanner: false,
                        title: 'Stato attività pazienti',
                        home: Scaffold(
                          body: SingleChildScrollView(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SfCircularChart(
                                      title: ChartTitle(
                                          text: "Stato Attività pazienti"),
                                      legend: Legend(
                                          isVisible: true,
                                          overflowMode:
                                              LegendItemOverflowMode.wrap),
                                      series: <CircularSeries>[
                                        PieSeries<ChartData, String>(
                                            dataSource: [
                                              ChartData('Online', online,
                                                  const Color(0xff0984e3)),
                                              ChartData('Offline', offline,
                                                  const Color(0xfffdcb6e)),
                                            ],
                                            xValueMapper: (ChartData data, _) =>
                                                data.x,
                                            yValueMapper: (ChartData data, _) =>
                                                data.y,
                                            pointColorMapper:
                                                (ChartData data, _) =>
                                                    data.color,
                                            dataLabelSettings:
                                                const DataLabelSettings(
                                                    isVisible: true),
                                            // Radius of pie
                                            radius: '100%')
                                      ],
                                      onChartTouchInteractionDown: (tapArgs) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                StatoAttivitaPazienti(),
                                          ),
                                        );
                                      }),
                                ),
                              ])),

                          // Theme(
                          //   data: Theme.of(context).copyWith(
                          //       // sets the background color of the `BottomNavigationBar`
                          //       canvasColor: Colors.blue,
                          //       // sets the active color of the `BottomNavigationBar` if `Brightness` is light
                          //       primaryColor: Colors.white,
                          //       textTheme: Theme.of(context)
                          //           .textTheme
                          //           .copyWith(
                          //               caption: new TextStyle(
                          //                   color: Colors.white))),
                          //   // sets the inactive color of the `BottomNavigationBar`
                          //   child: BottomNavigationBar(
                          //     type: BottomNavigationBarType.fixed,
                          //     selectedItemColor: Colors.white,
                          //     selectedLabelStyle: const TextStyle(
                          //         fontWeight: FontWeight.bold),
                          //     items: const <BottomNavigationBarItem>[
                          //       BottomNavigationBarItem(
                          //         icon: Icon(Icons.home_outlined),
                          //         label: 'Home',
                          //       ),
                          //       BottomNavigationBarItem(
                          //         icon: Icon(
                          //             Icons.supervised_user_circle_outlined),
                          //         label: 'Pazienti',
                          //       ),
                          //       BottomNavigationBarItem(
                          //         icon: Icon(Icons.local_hospital),
                          //         label: 'Dottori',
                          //       ),
                          //       BottomNavigationBarItem(
                          //         icon: Icon(Icons.wc_outlined),
                          //         label: 'Familiari',
                          //       ),
                          //       BottomNavigationBarItem(
                          //         icon: Icon(Icons.attribution_outlined),
                          //         label: 'Volontari',
                          //       ),
                          //     ],
                          //     currentIndex: _selectedIndex,
                          //     //New
                          //     onTap: _onItemTapped,
                          //     //selectedItemColor: Colors.blue,
                          //   ),
                          // )
                        ));
                  });
            }),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);

  final String x;
  final int y;
  final Color? color;
}

Future<Map<String, String>> getstatus() async {
  var snapshot = await FirebaseFirestore.instance
      .collection('patients')
      .where('status', isEqualTo: 'online')
      .get();
  var online = snapshot.docs.length;

  snapshot = await FirebaseFirestore.instance
      .collection('patients')
      .where('status', isEqualTo: 'offline')
      .get();
  var offline = snapshot.docs.length;

  Map<String, String> status;
  if (online == null || offline == null)
    status = {'online': '0', 'offline': '0'};
  else
    status = {'online': online.toString(), 'offline': offline.toString()};

  return status;
}
