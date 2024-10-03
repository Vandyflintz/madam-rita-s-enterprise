import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

//import 'package:dropdown_date_picker/dropdown_date_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:progress_dialog/progress_dialog.dart';
import 'Utils/customfunctions.dart';
import 'login.dart';

import 'package:http/http.dart' as http;

//ProgressDialog pr;
void main() => runApp(RegistrationPage());

class RegistrationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainRegistrationPage(),
    );
  }
}

class MainRegistrationPage extends StatefulWidget {
  @override
  State createState() => new RegistrationPageState();
}

class DateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text.length >= newValue.text.length) {
      return newValue;
    }

    var dateText = _addSeparators(newValue.text, '-');
    return newValue.copyWith(
        text: dateText, selection: updateCursorPosition(dateText));
  }

  String _addSeparators(String value, String separator) {
    value = value.replaceAll('-', '');
    var newString = '';
    for (int i = 0; i < value.length; i++) {
      newString += value[i];
      if (i == 1) {
        newString += separator;
      }
      if (i == 3) {
        newString += separator;
      }
    }
    return newString;
  }

  TextSelection updateCursorPosition(String? text) {
    return TextSelection.fromPosition(TextPosition(offset: text!.length));
  }
}

class RegistrationPageState extends State<MainRegistrationPage>
    with TickerProviderStateMixin {
  String? _platformVersion = 'Unknown';
  AnimationController? _iconanimcontroller;
  Animation<double>? _iconanim;
  DateTime selectedDate = DateTime.now();
  SnackBar? snackBar;

  bool isButtonEnabled = true;
  bool isVisible = true;
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

  @override
  void initState() {
    super.initState();
    //getData();

    _obscuretext = false;

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
    if (value == null || value.isEmpty) {
      return 'This field is required';
    } else {
      String pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = RegExp(pattern);

      if (!regex.hasMatch(value)) {
        return 'Email is invalid';
      } else {
        return null; // Returning null when validation passes
      }
    }
  }
  void showsnackbar(String? _message, String? _command) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    snackBar = SnackBar(
      duration: const Duration(minutes: 5),
      content: Text(_message!),
      action: SnackBarAction(
        label: _command!,
        onPressed: () {
          if (_command.contains("Retry")) {
            _signupuser(_firstname, _lastname, _emailaddress, _fpassword);
            showsnackbar(_message, "");
            disableButton();
            hidecon();
            showsnackbar("Please wait, connecting to server...", "");
          }
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar!);
  }

  final _formkey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  bool pressed = false, _obscuretext = false, _visibility = false;
  TextEditingController _textEditingController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _fpassword = '',
      _cpassword = '',
      _message = '',
      _firstname = '',
      _lastname = '',
      _emailaddress = '',
      _dob = '',
      _contact = '',
      _sex = '',
      _response = '',
      _command = '';
  String? platformVersion = '';

  //method to signup user
  void _signupuser(String? firstname, String? lastname, String? emailaddress,
      String? fpassword) async {
    var url =
        '$hostUrl/Madam_Rita_s_Enterprise/connection.php';
    int timeout = 15;
    try {
      http.Response response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));

      print("First Response : ${response.body}");
      if (response.statusCode == 200) {
        if (!response.body.contains("error")) {
        var url =
            "$hostUrl/Madam_Rita_s_Enterprise/register.php";
        var data = {
          "firstname": firstname,
          "lastname": lastname,
          "emailaddress": emailaddress,
          "password": fpassword,
        };

        var response = await http.post(Uri.parse(url), body: data);
        print("Response : ${response.body}");
        if (jsonDecode(response.body) == "-1") {
          enableButton();
          showCon();
          showsnackbar("Contact already exists!", "Close");
        } else if (jsonDecode(response.body) == "-2") {
          enableButton();
          showCon();
          showsnackbar("Email address already exists!", "Close");
        } else {
          Future.delayed(Duration(seconds: 1)).then((value) {
            disableButton();
            showsnackbar("Account created successfully", "Close");
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          });
        }
      }else{
          showsnackbar("An unknown error occurred", "Close");
          showCon();
          enableButton();
      }
      } else {
        showsnackbar("Error connecting to server...", "Retry");
        showCon();
        enableButton();
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      Future.delayed(Duration(seconds: 1)).then((value) {
        showsnackbar("Connection to server timed out", "Retry");
        showCon();
        enableButton();
      });
    } on SocketException catch (e) {
      print('Socket Error: $e');
    } on Error catch (e) {
      Future.delayed(Duration(seconds: 3)).then((value) {
        showsnackbar("Error connecting to server : $e ", "Close");
      });
      showCon();
      enableButton();
    }
  }

  void showCon() {
    setState(() {
      isVisible = isVisible;
    });
  }

  void hidecon() {
    setState(() {
      isVisible = !isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final now = DateTime.now();

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
                    child: new Stack(
                      children: <Widget>[
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
                                    labelText: "Firstname",
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This field is required';
                                    } else if (value.trimLeft().length < 3 &&
                                        value.trimRight().length < 3) {
                                      return 'Firstname cannot be less than 3 characters';
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (newValue) {
                                    setState(() {
                                      _firstname = newValue;
                                    });
                                  },
                                  keyboardType: TextInputType.text,
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 10)),
                                new TextFormField(
                                  decoration: new InputDecoration(
                                    labelText: "Lastname",
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This field is required';
                                    } else if (value.trimLeft().length < 3 &&
                                        value.trimRight().length < 3) {
                                      return 'Lastname cannot be less than 3 characters';
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (newValue) {
                                    setState(() {
                                      _lastname = newValue;
                                    });
                                  },
                                  keyboardType: TextInputType.text,
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 10)),
                                new TextFormField(
                                  decoration: new InputDecoration(
                                    labelText: "Email Address",
                                    helperText: "user@example.com",
                                    hintStyle: TextStyle(
                                        color:
                                            Color.fromRGBO(255, 255, 255, 0.5)),
                                  ),
                                  onSaved: (newValue) {
                                    setState(() {
                                      _emailaddress = newValue;
                                    });
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 10)),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 10)),
                                new TextFormField(
                                  decoration: new InputDecoration(
                                    labelText: "Password",
                                    helperText:
                                        'Password cannot be less than 5 characters',
                                    suffixIcon: IconButton(
                                      icon: Padding(
                                        padding: EdgeInsets.all(3),
                                        child: pressed == true
                                            ? Icon(Icons.visibility_off_rounded)
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
                                      _fpassword = newValue;
                                    });
                                  },
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This field is required';
                                    } else if (value.length < 5) {
                                      return 'Password should be more than 4 characters';
                                    } else {
                                      return null;
                                    }
                                  },
                                  obscureText: !_obscuretext,
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 10)),
                                new TextFormField(
                                  decoration: new InputDecoration(
                                    labelText: "Confirm Password",
                                    helperText:
                                        'Password cannot be less than 5 characters',
                                    suffixIcon: IconButton(
                                      icon: Padding(
                                        padding: EdgeInsets.all(3),
                                        child: pressed == true
                                            ? Icon(Icons.visibility_off_rounded)
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
                                  keyboardType: TextInputType.text,
                                  onSaved: (newValue) {
                                    setState(() {
                                      _cpassword = newValue;
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
                                  obscureText: !_obscuretext,
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 42)),
                                FractionallySizedBox(
                                  widthFactor: 0.45,
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
                                      "Sign Up",
                                      style: TextStyle(fontSize: 15, color: Colors.white,),
                                    ),
                                    onPressed: () {
                                      if (isButtonEnabled) {
                                        final form = _formkey.currentState;
                                        if (form!.validate()) {
                                          form.save();
                                          if (!(_cpassword == _fpassword)) {
                                            _message = "Passwords don't match !";
                                          } else {
                                            if (_response!.contains("error")) {
                                              _message = "Error connecting to server...";
                                              showsnackbar(_message, "Retry");
                                            } else {
                                              print(_response);
                                              _message = "Please wait, account is being created...";
                                              _signupuser(_firstname, _lastname, _emailaddress, _fpassword);
                                            }
                                            showsnackbar(_message, "");
                                            disableButton();
                                            hidecon();
                                          }
                                        }
                                      }
                                    },
                                  )
                                  ,
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 35)),
                                Visibility(
                                  visible: isVisible,
                                  child: new Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new Text(
                                        "Already have an account?",
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
                                            color: Colors.amberAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
