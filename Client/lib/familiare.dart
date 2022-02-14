import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';




class Familiare extends StatelessWidget {


    const Familiare({Key? key, required this.token}) : super(key: key);

    final String token;
    

    @override
    Widget build(BuildContext context) {
      print("\nSONO IN FAMILIARE, TOKEN: ${token}");
        return Scaffold(
            appBar: AppBar(title: Text('Familiare'), ),
            
        );
    }
}


