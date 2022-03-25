import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api/api.dart' as services;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:where_to_go/widgets/home.dart';

import 'widgets/auth/auth.dart';

void main() {
  runApp(const WTG());
}

class WTG extends StatelessWidget {
  const WTG({Key? key}) : super(key: key);

  Future get jwtOrEmpty async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString('jwt');
    if (jwt == null) return '';
    return jwt;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WTG',
      theme: ThemeData(primarySwatch: Colors.green),
      home: FutureBuilder(
        future: jwtOrEmpty,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          if (snapshot.data != '') {
            var snapData = snapshot.data;
            var jwt = snapData.toString().split('.');
            if (jwt.length != 5) {
              return AuthPage();
            } else {
              // var response = http.post(Uri.parse(services.JWT_VERIFY_PATH))
              // print(snapData);
              
              var jwtDecoded = json
                  .decode(utf8.decode(base64.decode(base64.normalize(jwt[3]))));
              if (DateTime.fromMillisecondsSinceEpoch(jwtDecoded['exp'] * 1000)
                  .isAfter(DateTime.now())) {
                return 
                HomePage(
                    snapData.toString(), jwtDecoded);
              } else {
                return AuthPage();
              }
            }
          } else {
            return AuthPage();
          }
        },
      ),
    );
  }
}
