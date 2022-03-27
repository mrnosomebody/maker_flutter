import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api.dart' as services;

bool _emailIsValid(var email) => RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
    .hasMatch(email);

void _displayDialog(BuildContext context, String title, String text) =>
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: [
              OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'))
            ],
          );
        });

Future _tryLogin(String email, String password) async {
  var response = await http.post(Uri.parse(services.LOGIN_PATH),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; chatset=UTF-8'
      },
      body: json.encode({'email': email, 'password': password}));
  if (response.statusCode == 200) {
    return response.body;
  }
  return null;
}

Future _trySignup(String email, String password) async {
  var response = await http.post(Uri.parse(services.REGISTER_PATH),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; chatset=UTF-8'
      },
      body: json.encode({'email': email, 'password': password}));
  return response.statusCode;
}

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPage();
}

class _AuthPage extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 100, 151, 147),
          title: const Center(child: Text('Login')),
        ),
        body: const SingleChildScrollView(
          child: _AuthForm(),
        ));
  }
}

class _AuthForm extends StatefulWidget {
  const _AuthForm({
    Key? key,
  }) : super(key: key);

  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _loginTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  String error = '';

  void _authentication() async {
    final email = _loginTextController.text;
    final password = _passwordTextController.text;

    if (_emailIsValid(email) && password.length >= 8) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      error = '';
      var jwtTokens = await _tryLogin(email, password);
      if (jwtTokens != null) {
        await prefs.setString(
            'jwtAccessToken', json.decode(jwtTokens)['access']);
        await prefs.setString(
            'jwtRefreshToken', json.decode(jwtTokens)['refresh']);
        print('${prefs.getString('jwtAccessToken')} aaccc');
        print(prefs.getString('jwtRefreshToken'));
      } else {
        _displayDialog(context, "Error", "User not found");
      }
    } else {
      error = 'Incorrect email or password';
    }
    setState(() {});
  }

  void _register() async {
    final email = _loginTextController.text;
    final password = _passwordTextController.text;

    if (_emailIsValid(email) && password.length >= 8) {
      error = '';
      var response = await _trySignup(email, password);
      if (response == 201) {
        _displayDialog(context, 'Success', 'Acount created');
      } else if (response == 409) {
        _displayDialog(context, "Error", "This email already exists");
      } else {
        _displayDialog(context, "Error", "Some error");
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ////////////////////////////////////////// START constants for styling
    const mainColor = Color(0xff494a4b);
    const textStyle =
        TextStyle(fontSize: 16, color: mainColor, fontWeight: FontWeight.w600);
    const textFieldDecoration = InputDecoration(
        border: OutlineInputBorder(),
        isCollapsed: true,
        contentPadding: EdgeInsets.all(10));
    final border = BoxDecoration(
        border: Border.all(width: 2, color: mainColor),
        borderRadius: const BorderRadius.all(Radius.circular(10)));
    ////////////////////////////////////////// END constants for styling
    ///
    return Padding(
      padding: EdgeInsets.only(
          left: 16, right: 16, top: MediaQuery.of(context).size.height / 4),
      child: Container(
        width: double.infinity,
        decoration: border,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _AuthFormFields(
              textStyle: textStyle,
              textFieldDecoration: textFieldDecoration,
              loginTextController: _loginTextController,
              passwordTextController: _passwordTextController,
              error: error,
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AuthButton(
                      text: const Text('Login', style: textStyle),
                      onClick: _authentication),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AuthButton(
                      text: const Text('Signup', style: textStyle),
                      onClick: _register),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _AuthFormFields extends StatelessWidget {
  _AuthFormFields(
      {Key? key,
      required this.textStyle,
      required this.textFieldDecoration,
      required this.loginTextController,
      required this.passwordTextController,
      required this.error})
      : super(key: key);

  final TextStyle textStyle;
  final InputDecoration textFieldDecoration;
  final TextEditingController loginTextController;
  final TextEditingController passwordTextController;
  String error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (error != '') ...[
          Text(
            error,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 15)
        ],
        Text('Email', style: textStyle),
        const SizedBox(height: 5),
        TextFormField(
          decoration: textFieldDecoration,
          controller: loginTextController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (input) =>
              _emailIsValid(input) ? null : "Enter a valid email",
        ),
        const SizedBox(height: 25),
        Text('Password', style: textStyle),
        const SizedBox(height: 5),
        TextField(
          decoration: textFieldDecoration,
          obscureText: true,
          controller: passwordTextController,
        ),
      ],
    );
  }
}

class AuthButton extends StatelessWidget {
  final Text text;
  final onClick;
  const AuthButton({Key? key, required this.text, required this.onClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onClick,
      child: text,
    );
  }
}


// Тени с разных сторон

// border: Border(
//               right: BorderSide(
//                 color: mainColor,
//                 width: 2.5,
//               ),
//               left: BorderSide(
//                 color: mainColor,
//                 width: 2,
//               ),
//               top: BorderSide(
//                 color: mainColor,
//                 width: 2.5,
//               ),
//               bottom: BorderSide(
//                 color: mainColor,
//                 width: 2.5,
//               ),
//             ),