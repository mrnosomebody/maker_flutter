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
    final accessToken = prefs.getString('jwtAccessToken');
    print('jwtOrEmpty()');
    print(accessToken);
    if (accessToken != null) {
      if (jwtIsValid(accessToken)) {
        return accessToken;
      } else {
        final bool isRefreshed = await refreshJWT();
        print(isRefreshed);
        if (isRefreshed) return prefs.getString('jwtAccessToken');
      }
    }
    return '';
  }

  bool jwtIsValid(accessToken) {
    // print('jwtIsValid()');
    final accessTokenExpireTime = json.decode(utf8.decode(base64.decode(
        base64.normalize(accessToken.toString().split('.')[1]))))['exp'];
    // print(accessTokenExpireTime);
    return DateTime.fromMillisecondsSinceEpoch(accessTokenExpireTime * 1000)
        .isAfter(DateTime.now());
  }

  Future refreshJWT() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('jwtAccessToken');
    final refreshToken = prefs.getString('jwtRefreshToken');

    print('\n===========================================');
    final response = await http.post(Uri.parse(services.JWT_REFRESH_PATH),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; chatset=UTF-8'
        },
        body: json.encode({'refresh': refreshToken}));
    // print(prefs.getString('accessToken'));
    // print(prefs.getString('refreshToken'));
    if (response.statusCode == 200) {
      final accessToken = json.decode(response.body)['access'];
      print(accessToken);
      prefs.setString('jwtAccessToken', accessToken);
      return true;
    } else {
      prefs.clear();
      print(prefs.getString('jwtAccessToken'));
      print(prefs.getString('jwtRefreshToken'));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WTG',
      theme: ThemeData(primarySwatch: Colors.green),
      home: FutureBuilder(
        future: jwtOrEmpty,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage(snapshot.data.toString());
          }
          return AuthPage();
        },
      ),
    );
  }
}
