import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:store_stock/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'Utils/customfunctions.dart';
import 'login.dart';

void main() => runApp(ResetPasswordPage());

class ResetPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainResetPage(),
    );
  }
}

class MainResetPage extends StatefulWidget {
  @override
  State createState() => new ResetPageState();
}

class ResetPageState extends State<MainResetPage>
    with TickerProviderStateMixin {
  String? emailaddr = '',
      contact = '',
      password = '',
      cpassword = '',
      message = '';
  bool pressed = false, _obscuretext = false, btnvisibility = true;

  final _formkey = GlobalKey<FormState>();
  Animation<double>? _iconanim;
  AnimationController? _iconanimcontroller;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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

  String? _validateEmail(String? value) {
    if (value!.isEmpty) {
      return 'This field is required';
    } else {
      String pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      //return () ? false : true;

      if (!regex.hasMatch(value)) {
        return 'Email is invalid';
      } else {
        return null;
      }
    }
  }

  bool isButtonEnabled = true;

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

  void resetpassword(String? emailaddr, String? password) async {
    var url =
        '$hostUrl/Madam_Rita_s_Enterprise/connection.php';
    int timeout = 15;
    try {
      http.Response response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));

      if (response.statusCode == 200) {
        //connected, validate email address and contact
        var url =
            "$hostUrl/Madam_Rita_s_Enterprise/resetpassword.php";
        var data = {"emailaddr": emailaddr, "pw": password};

        var response = await http.post(Uri.parse(url), body: data);
        if (jsonDecode(response.body) == "-1") {
          showsnackbar(
              "Error processing request, please try again later", "Close");
          setState(() {
            _btmvisible = !_btmvisible;
          });
          enableButton();
        } else {
          Future.delayed(Duration(seconds: 1)).then((value) {
            showsnackbar("Password has been reset successfully", "Close");
          });
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        }
      } else {
        showsnackbar("Error connecting to server...", "Retry");
        setState(() {
          _btmvisible = !_btmvisible;
        });
        enableButton();
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      Future.delayed(Duration(seconds: 3)).then((value) {
        showsnackbar("Connection to server timed out!", "Close");
        setState(() {
          _btmvisible = !_btmvisible;
        });
        enableButton();
      });
    } on SocketException catch (e) {
      print('Socket Error: $e');
    } on Error catch (e) {
      Future.delayed(Duration(seconds: 3)).then((value) {
        showsnackbar("Error connecting to server : $e", "Close");
      });
      setState(() {
        _btmvisible = !_btmvisible;
      });
      enableButton();
    }
  }

  void showpassword(String? emailaddr, String? contact) async {
    var url = '$hostUrl/Daybel_Comp/connection.php';
    int timeout = 15;
    try {
      http.Response response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));

      if (response.statusCode == 200) {
        //connected, validate email address and contact
        var url = "$hostUrl/Daybel_Comp/verify.php";
        var data = {"emailaddr": emailaddr, "contact": contact};

        var response = await http.post(Uri.parse(url), body: data);
        if (jsonDecode(response.body) == "-1") {
          showsnackbar("Credentials don't exist!", "Close");
        } else {
          setState(() {
            convisibility = !convisibility;
            btnvisibility = !btnvisibility;
          });
        }
      } else {
        showsnackbar("Error connecting to server...", "Retry");
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      showsnackbar("Connection to server timed out!", "Close");
    } on SocketException catch (e) {
      print('Socket Error: $e');
    } on Error catch (e) {
      showsnackbar("Error connecting to server : $e", "Close");
    }
  }

  SnackBar? snackBar;
  bool convisibility = false, _btmvisible = false;

  void showsnackbar(String? _message, String? _command) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    snackBar = SnackBar(
      duration: const Duration(minutes: 5),
      content: Text(_message!),
      action: SnackBarAction(
        label: _command!,
        onPressed: () {
          if (_command.contains("Close")) {
          } else if (_command.contains("Retry")) {
            showpassword(emailaddr, contact);
          }
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
                              primarySwatch: Colors.teal,
                              inputDecorationTheme: new InputDecorationTheme(
                                labelStyle: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            child: Center(
                              child:
                                  ListView(shrinkWrap: true, children: <Widget>[
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
                                  validator: _validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  onSaved: (newValue) {
                                    setState(() {
                                      emailaddr = newValue;
                                    });
                                  },
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 10)),
                                Visibility(
                                  visible: btnvisibility,
                                  child: new FractionallySizedBox(
                                    alignment: Alignment.center,
                                    widthFactor: 0.30,
                                    child:ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          side: BorderSide(
                                            color: Color.fromRGBO(0, 0, 0, 0.09),
                                            width: 3,
                                          ),
                                        ),
                                        backgroundColor: primarycolor, // Replace `color` with `backgroundColor`
                                        foregroundColor: Colors.white, // Replace `textColor` with `foregroundColor`
                                      ),
                                      child: Text(
                                        "Next",
                                        style: TextStyle(fontSize: 15, color: Colors.white,),
                                      ),
                                      onPressed: () {
                                        final form = _formkey.currentState;
                                        if (form!.validate()) {
                                          form.save();
                                          showpassword(emailaddr, contact);
                                        }
                                      },
                                    )

                                    ,
                                  ),
                                ),
                                Visibility(
                                  visible: convisibility,
                                  child: new TextFormField(
                                    decoration: new InputDecoration(
                                      labelText: "New Password",
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
                                    onSaved: (newValue) {
                                      setState(() {
                                        password = newValue;
                                      });
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'This field is required';
                                      } else if (value.length < 5) {
                                        return 'Password should be more than 4 characters';
                                      } else {
                                        return null;
                                      }
                                    },
                                    keyboardType: TextInputType.text,
                                    obscureText: true,
                                  ),
                                ),
                                Visibility(
                                  visible: convisibility,
                                  child: new Padding(
                                      padding: const EdgeInsets.only(top: 10)),
                                ),
                                Visibility(
                                  visible: convisibility,
                                  child: new TextFormField(
                                    decoration: new InputDecoration(
                                      labelText: "Confirm Password",
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
                                    onSaved: (newValue) {
                                      setState(() {
                                        cpassword = newValue;
                                      });
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'This field is required';
                                      } else if (value.length < 5) {
                                        return 'Password should be more than 4 characters';
                                      } else {
                                        return null;
                                      }
                                    },
                                    keyboardType: TextInputType.text,
                                    obscureText: !_obscuretext,
                                  ),
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 42)),
                                Visibility(
                                  visible: convisibility,
                                  child: new FractionallySizedBox(
                                    widthFactor: 0.50,
                                    child: new ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          side: BorderSide(
                                            color: Color.fromRGBO(0, 0, 0, 0.09),
                                            width: 3,
                                          ),
                                        ),
                                        backgroundColor: primarycolor, // Replace `color` with `backgroundColor`
                                        foregroundColor: Colors.white, // Replace `textColor` with `foregroundColor`
                                      ),
                                      child: Text(
                                        "Reset Password",
                                        style: TextStyle(fontSize: 15, color: Colors.white,),
                                      ),
                                      onPressed: () {
                                        if (isButtonEnabled) {
                                          final form = _formkey.currentState;
                                          if (form!.validate()) {
                                            form.save();
                                            if (!(cpassword == password)) {
                                              message =
                                              "Passwords don't match !";
                                            } else {
                                              message =
                                              "Please wait, resetting password...";
                                              resetpassword(
                                                  emailaddr, password);
                                            }
                                            showsnackbar(message, "");
                                            disableButton();
                                            setState(() {
                                              _btmvisible = !_btmvisible;
                                            });
                                          }
                                        }
                                      },
                                    )

                                    ,
                                  ),
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 35)),
                                Visibility(
                                  visible: !_btmvisible,
                                  child: new Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new Text(
                                        "Remember Password?",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'serif',
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Color.fromRGBO(255, 255, 255, 1),
                                        ),
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10)),
                                      new GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginPage()));
                                        },
                                        child: new Text(
                                          "Sign In",
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
                                new Padding(
                                    padding: const EdgeInsets.only(top: 35)),
                                Visibility(
                                  visible: !_btmvisible,
                                  child: new Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new Text(
                                        "Don't have an account?",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'serif',
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Color.fromRGBO(255, 255, 255, 1),
                                        ),
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10)),
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
        ));
  }
}
