import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api.dart' as services;

class HomePage extends StatelessWidget {
  final String jwt;
  final Map<String, dynamic> jwtDecoded;
  HomePage(this.jwt, this.jwtDecoded);

  factory HomePage.fromBase64(String jwt) => HomePage(
        jwt,
        json.decode(utf8.decode(base64.decode(base64.normalize(jwt)))),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: FutureBuilder(
            future: http.read(Uri.parse(services.TEST),
                headers: {'Accept': 'application/json','Authorization': 'Bearer ${json.decode(jwt)['access']}'}),
            builder: (context, snapshot) => snapshot.hasData
                ? Column(
                    children: [
                      Text(snapshot.data.toString()),
                      OutlinedButton(
                          onPressed: () {
                            print(jwtDecoded);
                            print(jwt);
                          },
                          child: Text('sad'))
                    ],
                  )
                : snapshot.hasError
                    ? Text('Error kakoi-to')
                    : CircularProgressIndicator()),
      ),
    );
  }
}
