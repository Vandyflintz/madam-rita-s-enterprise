import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:store_stock/resetpassword.dart';
import 'package:store_stock/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

void main() => runApp(PinPage());

class PinPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PinPPage(),
    );
  }
}

class PinPPage extends StatefulWidget {
  @override
  State createState() => new PinPageState();
}

class PinPageState extends State<PinPPage> with TickerProviderStateMixin {
  AnimationController? _iconanimcontroller;
  Animation<double>? _iconanim;

  @override
  void initState() {
    super.initState();
    _iconanimcontroller = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 1000));

    _iconanim =
        new CurvedAnimation(parent: _iconanimcontroller!, curve: Curves.easeOut);
    _iconanim!.addListener(() => this.setState(() {}));
    _iconanimcontroller!.forward();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  SharedPreferences? sharedpref;
  bool isButtonEnabled = true;
  String? user = '', password = '', message = '';

  Color primarycolor = Colors.pink[900]!;
  enableButton() {
    setState(() {
      isButtonEnabled = true;
      primarycolor = Colors.pink[900]!;
    });
  }

  disableButton() {
    setState(() {
      isButtonEnabled = false;
      primarycolor = Colors.grey;
    });
  }

  String? _serveresponse = '';
  final _formkey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool pressed = false, _obscuretext = false, _visibility = false;

  SnackBar? snackBar;

  void showsnackbar(String? _message, String? _command) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    snackBar = SnackBar(
      duration: const Duration(minutes: 5),
      content: Text(_message!),
      action: SnackBarAction(
        label: _command!,
        onPressed: () {
          if (_command!.contains("Close")) {
          } else if (_command.contains("Retry")) {}
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar!);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return new Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Center(
            child: new Container(
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.height * 1,
              padding: const EdgeInsets.only(bottom: 0),
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                image: new ExactAssetImage('assets/images/bg.png'),
                fit: BoxFit.fill,
              )),
              child: new BackdropFilter(
                filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: new Container(
                  width: MediaQuery.of(context).size.width * 1,
                  height: MediaQuery.of(context).size.height * 1,
                  decoration:
                      new BoxDecoration(color: Colors.black.withOpacity(0.4)),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottom),
                      child: new Stack(children: <Widget>[
                        new Form(
                          key: _formkey,
                          child: Theme(
                              data: new ThemeData(
                                brightness: Brightness.dark,
                                primarySwatch: Colors.pink,
                                inputDecorationTheme: new InputDecorationTheme(
                                  labelStyle: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: ListView(shrinkWrap: true, children: <
                                    Widget>[
                                  new Padding(
                                      padding: const EdgeInsets.only(top: 10)),
                                  new TextFormField(
                                    decoration: new InputDecoration(
                                      hintText: "Password",
                                      suffixIcon: IconButton(
                                        icon: Padding(
                                          padding: EdgeInsets.all(3),
                                          child: pressed == true
                                              ? Icon(
                                                  Icons.visibility_off_rounded)
                                              : Icon(Icons.visibility_rounded),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            pressed = !pressed;
                                            _obscuretext = !_obscuretext;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'This field is required';
                                      } else if (value.length < 5) {
                                        return 'Password cannot be less than 5 characters';
                                      } else {
                                        return null;
                                      }
                                    },
                                    onSaved: (newValue) {
                                      setState(() {
                                        password = newValue;
                                      });
                                    },
                                    keyboardType: TextInputType.text,
                                    obscureText: !_obscuretext,
                                  ),
                                  new Padding(
                                      padding: const EdgeInsets.only(top: 42)),
                                  FractionallySizedBox(
                                    widthFactor: 0.40,
                                    child: new ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primarycolor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          side: BorderSide(
                                            color: Color.fromRGBO(0, 0, 0, 0.09),
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Sign In",
                                        style: TextStyle(fontSize: 15, color: Colors.white),
                                      ),
                                      onPressed: () {
                                        if (isButtonEnabled) {
                                          final form = _formkey.currentState;
                                          if (form!.validate()) {
                                            form.save();
                                            message = 'Please wait, user is being signed in...';

                                            showsnackbar(message, "");
                                            disableButton();
                                            setState(() {
                                              _visibility = _visibility;
                                            });
                                          }
                                        }
                                      },
                                    )
                                    ,
                                  ),
                                ]),
                              )),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
