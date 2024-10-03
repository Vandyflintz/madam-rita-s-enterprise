import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:io' as Io;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Utils/customfunctions.dart';
import 'settingshome.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'products_model.dart';
import 'DatabaseHelper.dart';

//ProgressDialog pr;
/*
void main() => runApp(RegistrationPage());

class RegistrationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WorkerRegistrationPage(),
    );
  }
}
*/
class WorkerRegistrationPage extends StatefulWidget {
  WorkerRegistrationPage({required Key key, required this.title, required this.shopname, required this.location})
      : super(key: key);
  final String title, shopname, location;
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

  TextSelection updateCursorPosition(String text) {
    return TextSelection.fromPosition(TextPosition(offset: text.length));
  }
}

enum AppState {
  free,
  picked,
  cropped,
}

class RegistrationPageState extends State<WorkerRegistrationPage>
    with TickerProviderStateMixin {
  String _platformVersion = 'Unknown';
  AnimationController? _iconanimcontroller;
  Animation<double>? _iconanim;
  DateTime selectedDate = DateTime.now();
  SnackBar? snackBar;
  final ImagePicker _picker = ImagePicker();
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

  File? galleryfile, camerafile;
  String _imgfile = '', _finalfile = '', _shopname = '';
  bool _autovalidatename = false;
  String base64image = '';
  TextEditingController? tec;
  TextEditingController? firstnametec;
  TextEditingController? lastnametec;
  TextEditingController? useridtec;
  AppState? appstate;
  @override
  void initState() {
    super.initState();
    //getData();
    appstate = AppState.free;
    _obscuretext = false;
    tec = new TextEditingController();
    firstnametec = new TextEditingController();
    lastnametec = new TextEditingController();
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

    String randomchars =
        DateFormat('yyyyMMHHmmss').format(DateTime.now()).toString();

    setState(() {
      tec!.text = "mre" + randomchars;
    });
  }

  void _showfilepicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                  leading: new Icon(Icons.photo_library),
                  title: new Text('Gallery'),
                  onTap: () {
                    galleryimage();
                    Navigator.of(context).pop();
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text('Camera'),
                  onTap: () {
                    cameraimage();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  cameraimage() async {
    // ignore: deprecated_member_use
    XFile? gfile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (gfile != null) {
      galleryfile = File(gfile.path);
      final bytes = Io.File(galleryfile!.path).readAsBytesSync();
      _imgfile = galleryfile.toString().split('/').last.split('r').last;
      base64image = base64Encode(bytes);
      _finalfile = _imgfile.substring(0, _imgfile.indexOf('\''));
      setState(() {
        appstate = AppState.picked;
      });
      Future.delayed(Duration(seconds: 0)).then((value) {
        cropimage();
      });
    }
  }

  galleryimage() async {
    // ignore: deprecated_member_use
    XFile? gfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (gfile != null) {
      galleryfile = File(gfile.path);
      final bytes = Io.File(galleryfile!.path).readAsBytesSync();
      _imgfile = galleryfile.toString().split('/').last.split('r').last;
      base64image = base64Encode(bytes);
      _finalfile = _imgfile.substring(0, _imgfile.indexOf('\''));
      setState(() {
        appstate = AppState.picked;
      });
      Future.delayed(Duration(seconds: 0)).then((value) {
        cropimage();
      });
    }
  }

  cropimage() async {
    ImageCropper imageCropper = ImageCropper();
    CroppedFile? ocroppedfile = await imageCropper.cropImage(
        sourcePath: galleryfile!.path,

        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Image Cropper',
              toolbarColor: Colors.pink[800],
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Image Cropper',
          ),
          WebUiSettings(
            context: context,
          ),
        ]
    );

    File? croppedfile = File(ocroppedfile!.path);

    if (croppedfile != null) {
      setState(() {
        galleryfile = croppedfile;
        final bytes = Io.File(galleryfile!.path).readAsBytesSync();
        _imgfile = galleryfile.toString().split('/').last.split('r').last;
        base64image = base64Encode(bytes);
        _finalfile = _imgfile.substring(0, _imgfile.indexOf('\''));
        appstate = AppState.cropped;
      });
    }
  }

  void clearimage() {
    galleryfile = null;
    setState(() {
      appstate = AppState.free;
    });
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate != null
            ? _selectedDate
            : DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day),
        firstDate: DateTime(1960, 1),
        lastDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day));

    if (newSelectedDate != null && newSelectedDate != _selectedDate)
      setState(() {
        _selectedDate = newSelectedDate;
        var month = '', day = '';
        if (newSelectedDate.month.toString().length < 2) {
          month = "0" + newSelectedDate.month.toString();
        } else {
          month = newSelectedDate.month.toString();
        }
        if (newSelectedDate.day.toString().length < 2) {
          day = "0" + newSelectedDate.day.toString();
        } else {
          day = newSelectedDate.day.toString();
        }
        var formatteddate = "${newSelectedDate.year}-${month}-${day}";
        _textEditingController.value =
            TextEditingValue(text: formatteddate.toString());
      });
  }

  /*String _validateEmail(String value) {
    if (value.isEmpty) {
      return 'This field is required';
    } else {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      //return () ? false : true;

      if (!regex.hasMatch(value)) {
        return 'Email is invalid';
      } else {
        return null;
      }
    }
  }*/

  void showsnackbar(String _message, String _command) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    snackBar = SnackBar(
      duration: const Duration(minutes: 5),
      content: Text(_message),
      action: SnackBarAction(
        label: _command,
        onPressed: () {
          if (_command.contains("Retry")) {
            _signupworker(
                _firstname,
                _lastname,
                _userid,
                _role,
                _fpassword,
                _dateemployed,
                _salary,
                _contact,
                _address,
                _imgfile,
                widget.shopname,
                widget.location);
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
  String _fpassword = '',
      _cpassword = '',
      _message = '',
      _firstname = '',
      _lastname = '',
      _userid = '',
      _dob = '',
      _contact = '',
      _sex = '',
      _response = '',
      _command = '',
      _role = '',
      _dateemployed = '',
      _salary = '',
      _address = '',
      message = '';
  String platformVersion = '';

  //method to signup user
  void _signupworker(
      String firstname,
      String lastname,
      String userid,
      String role,
      String fpassword,
      String dateemployed,
      String salary,
      String contact,
      String address,
      String image,
      String shopname,
      String location) async {
    String _foldername = "MyStockImages";

    final Directory _appDir = await getApplicationDocumentsDirectory();
    final Directory _appDirFolder = Directory('${_appDir.path}/$_foldername/');
    if (galleryfile != null && await galleryfile!.exists()) {
      message = 'Please wait, data is being uploaded...';

      String newPath = path.join(_appDirFolder.path, tec!.text + '.jpg');
      galleryfile!.copy(newPath).then((value) async {
        var url =
            '$hostUrl/Madam_Rita_s_Enterprise/connection.php';
        int timeout = 15;
        try {
          http.Response response =
              await http.get(Uri.parse(url)).timeout(Duration(seconds: timeout));

          if (response.statusCode == 200) {
            String img = userid + '.jpg';
            var url =
                "$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php";
            var data = {
              "firstname": firstnametec!.text,
              "lastname": lastnametec!.text,
              "userid": tec!.text,
              "role": role,
              "password": fpassword,
              "dateemployed": dateemployed,
              "salary": salary,
              "contact": contact,
              "address": address,
              "profimg": base64image,
              "shopname": shopname,
              "location": location,
              "workerinsert": "request",
            };

            var response = await http.post(Uri.parse(url), body: data);

            print(response.body);
            if (jsonDecode(response.body) == "-1") {
              enableButton();
              showCon();
              showsnackbar("Contact already exists!", "Close");
            } else if (jsonDecode(response.body) == "-2") {
              enableButton();
              showCon();
              showsnackbar("Email address already exists!", "Close");
            } else {
              var prodname = Workers(
                  firstnametec!.text,
                  lastnametec!.text,
                  fpassword,
                  tec!.text + ".jpg",
                  role,
                  dateemployed,
                  salary,
                  salary,
                  contact,
                  address,
                  "",
                  shopname,
                  tec!.text,
                  location);
              var dbhelper = DBProvider();
              dbhelper.newWorker(prodname);
              Future.delayed(Duration(seconds: 1)).then((value) {
                disableButton();
                showsnackbar("Worker added successfully", "Close");
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsPage(
                              shopname: widget.shopname,
                              location: widget.location, key: _scaffoldKey,
                          title: widget.title,

                            )));
              });
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
      });
    } else {
      message = 'Please select an image';
      showsnackbar(message, "Close");
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

  displayslectedfile(File galleryfile) {
    return new SizedBox(
      height: 150.0,
      width: 150.0,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.only(left: 0),
          child: galleryfile == null
              ? new Image.asset(
                  'assets/images/pic.png',
                  height: 150.0,
                  width: 150.0,
                )
              : new Image.file(
                  galleryfile,
                  height: 150.0,
                  width: 150.0,
                ),
        ),
      ),
    );
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
                  padding: const EdgeInsets.only(
                      left: 30.0, right: 30, bottom: 15, top: 10),
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
                                    padding: const EdgeInsets.only(top: 15)),
                                new TextFormField(
                                  controller: firstnametec,
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
                                      _firstname = newValue!;
                                    });
                                  },
                                  keyboardType: TextInputType.text,
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
                                new TextFormField(
                                  controller: lastnametec,
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
                                      _lastname = newValue!;
                                    });
                                  },
                                  keyboardType: TextInputType.text,
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
                                new TextFormField(
                                  controller: tec,
                                  readOnly: true,
                                  decoration: new InputDecoration(
                                    labelText: "User ID",
                                    helperText: "worker's login ID",
                                    hintStyle: TextStyle(
                                        color:
                                            Color.fromRGBO(255, 255, 255, 0.5)),
                                  ),
                                  onSaved: (newValue) {
                                    setState(() {
                                      _userid = newValue!;
                                    });
                                  },
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This field is required';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
                                new DropdownButtonFormField(
                                    value: _role,
                                    decoration: new InputDecoration(
                                      labelText: "Worker's Role",
                                    ),
                                    items: <String>['', 'Clerk', 'SalesPerson']
                                        .map((String value) {
                                      return new DropdownMenuItem<String>(
                                          value: value, child: new Text(value));
                                    }).toList(),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'This field is required';
                                      }
                                    },
                                    onSaved: (newValue) {
                                      setState(() {
                                        _role = newValue!;
                                      });
                                    },
                                    onChanged: (newValue) {
                                      setState(() {
                                        _role = newValue!;
                                      });
                                    }),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
                                Text(
                                  'Worker\'s Image',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'serif',
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
                                Center(
                                  child: displayslectedfile(galleryfile!),
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 5)),
                                RawMaterialButton(
                                  onPressed: () {
                                    _showfilepicker(context);
                                  },
                                  elevation: 5.0,
                                  fillColor: Colors.pink[900]!.withOpacity(.5),
                                  child: Icon(
                                    Icons.attach_file_rounded,
                                    size: 15.0,
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                  ),
                                  padding: EdgeInsets.all(6.0),
                                  shape: CircleBorder(
                                    side: BorderSide(
                                        color: Colors.white, width: 2),
                                  ),
                                  constraints: BoxConstraints.expand(
                                      width: 35, height: 35),
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
                                new TextFormField(
                                  decoration: new InputDecoration(
                                    labelText: "Worker's Salary",
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This field is required';
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (newValue) {
                                    setState(() {
                                      _salary = newValue!;
                                    });
                                  },
                                  keyboardType: TextInputType.text,
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
                                InkWell(
                                  onTap: () => _selectDate(context),
                                  child: IgnorePointer(
                                    child: TextFormField(
                                      controller: _textEditingController,
                                      decoration: InputDecoration(
                                        labelText: 'Date of Employment',
                                        helperText: 'dd-mm-yyyy',
                                      ),
                                      readOnly: true,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'This field is required';
                                        } else {
                                          return null;
                                        }
                                      },
                                      onSaved: (newValue) {
                                        setState(() {
                                          _dateemployed = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
                                new TextFormField(
                                  decoration: new InputDecoration(
                                    labelText: "Contact No",
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This field is required';
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (newValue) {
                                    setState(() {
                                      _contact = newValue!;
                                    });
                                  },
                                  keyboardType: TextInputType.phone,
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 25)),
                                new Text(
                                  "Worker's Address",
                                  style: new TextStyle(
                                      fontSize: 14.0, color: Colors.white),
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 5)),
                                Container(
                                  padding: EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white.withOpacity(.6),
                                        width: 1),
                                    color: Colors.black.withOpacity(.25),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: TextFormField(
                                    maxLines: 4,
                                    decoration: new InputDecoration(
                                      hintText: "Address Info",
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'This field is required';
                                      } else {
                                        return null;
                                      }
                                    },
                                    onSaved: (newValue) {
                                      setState(() {
                                        _address = newValue!;
                                      });
                                    },
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
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
                                      _fpassword = newValue!;
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
                                      _cpassword = newValue!;
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
                                      foregroundColor: Colors.white, shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide(
                                          color: Color.fromRGBO(0, 0, 0, 0.09),
                                          width: 3,
                                        ),
                                      ),
                                      backgroundColor: primarycolor,
                                      textStyle: TextStyle(fontSize: 15),
                                    ),
                                    child: Text("Add Worker"),
                                    onPressed: () {
                                      if (isButtonEnabled) {
                                        final form = _formkey.currentState;
                                        if (form!.validate()) {
                                          form.save();

                                          if (!(_cpassword == _fpassword)) {
                                            _message = "Passwords don't match !";
                                          } else {
                                            if (_response.contains("error")) {
                                              _message = "Error connecting to server...";
                                              showsnackbar(_message, "Retry");
                                            } else {
                                              print(_response);
                                              _message = "Please wait, account is being created...";

                                              _signupworker(
                                                _firstname,
                                                _lastname,
                                                _userid,
                                                _role,
                                                _fpassword,
                                                _dateemployed,
                                                _salary,
                                                _contact,
                                                _address,
                                                _imgfile,
                                                widget.shopname,
                                                widget.location,
                                              );
                                            }
                                            showsnackbar(_message, "");
                                            disableButton();
                                            hidecon();
                                            //_showCustomdialog(context);
                                          }
                                        }
                                      } else {}
                                    },
                                  )
                                  ,
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 35)),
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
