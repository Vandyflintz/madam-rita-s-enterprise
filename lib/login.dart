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

import 'Utils/customfunctions.dart';
import 'shopspage.dart';

void main() => runApp(LoginPage());

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainLoginPage(),
    );
  }
}

class MainLoginPage extends StatefulWidget {
  @override
  State createState() => new LoginPageState();
}

class LoginPageState extends State<MainLoginPage>
    with TickerProviderStateMixin {
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

  void loginuser(String? user, String? password) async {
    sharedpref = await SharedPreferences.getInstance();
    var url =
        '$hostUrl/Madam_Rita_s_Enterprise/connection.php';
    int timeout = 15;
    try {
      http.Response response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));

      setState(() {
        _visibility = !_visibility;
      });
      enableButton();
      if (response.statusCode == 200) {
        //connected, validate email address and contact
        var url =
            "$hostUrl/Madam_Rita_s_Enterprise/authenticate.php";
        var data = {"user": user, "pw": password};

        var response = await http.post(Uri.parse(url), body: data);
        if (jsonDecode(response.body) == "-2") {
          showsnackbar(
              "Error processing request, please try again later", "Close", context);

        } else if (jsonDecode(response.body) == "-1") {
          showsnackbar("Credentials do not exist!", "Close", context);

        } else {
          showsnackbar("User logged in successfully", "Close", context);
          print(response.body);
          var parsedjson =
              jsonDecode(response.body).toString().replaceAll("\"", "");

          print(parsedjson);
          final split = parsedjson.split(',');
          Map<int, String> finalval = {
            for (int i = 0; i < split.length; i++) i: split[i]
          };
          String? name = finalval[0];
          String? id = finalval[1];
          print('$name' + '\n' + '$id');
          setState(() {
            sharedpref!.setString('user', "$name");
            sharedpref!.setString('userid', "$id");
          });
          Future.delayed(Duration(seconds: 1)).then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MyShopPage()));
          });

          //showsnackbar(name + " " + id, "Close");

          /* String? regex = "\\[|\\]", secondregex = "\\{|\\}";
          var parsedjson = jsonDecode(response.body).toString();
          var filtered = parsedjson.replaceAll(new RegExp(regex), '');
          var fname = filtered.replaceAll(new RegExp(secondregex), '');
          final split = fname.split(':');
         */
        }
      } else {
        showsnackbar("Error connecting to server...", "Close", context);
        setState(() {
          _visibility = !_visibility;
        });
        enableButton();
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      Future.delayed(Duration(seconds: 3)).then((value) {
        showsnackbar("Connection to server timed out!", "Close", context);

        setState(() {
          _visibility = !_visibility;
        });
        enableButton();
      });
    } on SocketException catch (e) {
      print('Socket Error: $e');
    } on Error catch (e) {
      Future.delayed(Duration(seconds: 3)).then((value) {
        showsnackbar("Error connecting to server : $e", "Close", context);
      });
      setState(() {
        _visibility = !_visibility;
      });
      enableButton();
    }
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
                                  new Image.asset(
                                    'assets/images/madam_rita.png',
                                    width: _iconanim!.value * 100,
                                    height: _iconanim!.value * 100,
                                  ),
                                  new Padding(
                                      padding: const EdgeInsets.only(top: 60)),
                                  new TextFormField(
                                    decoration: new InputDecoration(
                                      labelText: "Email Address",
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'This field is required';
                                      } else if (value.length < 10) {
                                        return 'Email address or phone number cannot be less than 10 characters';
                                      } else {
                                        return null;
                                      }
                                    },
                                    onSaved: (newValue) {
                                      setState(() {
                                        user = newValue;
                                      });
                                    },
                                    keyboardType: TextInputType.text,
                                  ),
                                  new Padding(
                                      padding: const EdgeInsets.only(top: 10)),
                                  new TextFormField(
                                    decoration: new InputDecoration(
                                      labelText: "Password",
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
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          side: BorderSide(
                                            color: Color.fromRGBO(0, 0, 0, 0.09),
                                            width: 3,
                                          ),
                                        ),
                                        backgroundColor: primarycolor, // Updated button background color
                                      ),
                                      child: Text(
                                        "Sign In",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white, // Text color using TextStyle
                                        ),
                                      ),
                                      onPressed: () {
                                        if (isButtonEnabled) {
                                          final form = _formkey.currentState;
                                          if (form!.validate()) {
                                            form.save();
                                            message = 'Please wait, user is being signed in...';
                                            loginuser(user, password);
                                            showsnackbar(message, "", context);
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
                                  new Padding(
                                      padding: const EdgeInsets.only(top: 35)),
                                  Visibility(
                                    visible: !_visibility,
                                    child: new Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        new Text(
                                          "Not having an account?",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'serif',
                                            fontWeight: FontWeight.w500,
                                            color: Color.fromRGBO(
                                                255, 255, 255, 1),
                                          ),
                                        ),
                                        new Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10)),
                                        new GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        RegistrationPage()));
                                          },
                                          child: new Text(
                                            "Sign Up",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'serif',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: !_visibility,
                                    child: new Padding(
                                        padding:
                                            const EdgeInsets.only(top: 35)),
                                  ),
                                  Visibility(
                                    visible: !_visibility,
                                    child: new Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        new Text(
                                          "Forgotten Password?",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'serif',
                                            fontWeight: FontWeight.w500,
                                            color: Color.fromRGBO(
                                                255, 255, 255, 1),
                                          ),
                                        ),
                                        new Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10)),
                                        new GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ResetPasswordPage()));
                                          },
                                          child: new Text(
                                            "Reset Password",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'serif',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.lime,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
