import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:store_stock/stock.dart';
import 'package:path_provider/path_provider.dart';
import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:math' show pi;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'DatabaseHelper.dart';
import 'dart:async';
import 'Utils/customfunctions.dart';
import 'products_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(Shoppage());
}

class Shoppage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Madam Rita\'s Enterprise',
      home: MyShopPage(title: 'Madam Rita\'s Enterprise'),
    );
  }
}

class MyShopPage extends StatefulWidget {
  MyShopPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyShopPageState createState() => _MyShopPageState();
}

class _MyShopPageState extends State<MyShopPage> with TickerProviderStateMixin {
  AnimationController? animationController;
  Animation? animation;
  ScrollController? scrollController;
  bool dialVisible = true;
  AnimationController? _iconanimcontroller;
  Animation<double>? _iconanim;
  Future<List<Shops>>? _future;
  SharedPreferences? sharedpref;
  @override
  void initState() {
    super.initState();
    initializesharedpref();
    _iconanimcontroller = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 1000));

    _iconanim =
        new CurvedAnimation(parent: _iconanimcontroller!, curve: Curves.easeOut);
    _iconanim!.addListener(() => this.setState(() {}));
    _iconanimcontroller!.forward();
    scrollController = ScrollController()
      ..addListener(() {
        setDialVisible(scrollController!.position.userScrollDirection ==
            ScrollDirection.forward);
      });

    Future.delayed(Duration(seconds: 1)).then((value) {
      _future!.then((value) {
        if (value.isNotEmpty) {
          Future.delayed(Duration(seconds: 0)).then((value) {
            setState(() {
              _prodvisible = false;
            });
          });
        } else {
          Future.delayed(Duration(seconds: 0)).then((value) {
            setState(() {
              _prodvisible = true;
            });
          });
        }
      });
    });

    setState(() {
      _future = DBProvider().fetchShops();
    });

    _createFolder("MyStockImages");

    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 5),
    );
    animation =
        Tween<double>(begin: 0, end: 2 * 3.14).animate(animationController!);
    animationController!.repeat();
  }

  String? _compname = '';
  String? _complocation = '';
  String? _uploadurl =
      '$hostUrl/Madam_Rita_s_Enterprise/connection.php';
  double _endval = 2 * pi;
  double _endvalone = 2 * pi;
  bool _prodvisible = false;
  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  SnackBar? snackBar;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  void showsnackbar(String? _message, String? _command) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    snackBar = SnackBar(
      duration: const Duration(minutes: 5),
      content: Text(_message!),
      action: SnackBarAction(
        label: _command!,
        onPressed: () {
          if (_command.contains("Close")) {
          } else if (_command.contains("Retry")) {}
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar!);
  }

  initializesharedpref() async {
    sharedpref = await SharedPreferences.getInstance();
  }

  _showlogoutdialog(BuildContext context) {
    Widget cancelbtn = TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text("Cancel"),
    );
    Widget continuebtn = TextButton(
      onPressed: () {
        sharedpref!.remove('user');
        sharedpref!.remove('userid');
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false);
      },
      child: Text("Continue"),
    );

    AlertDialog alert = AlertDialog(
      title: Text("Warning"),
      content: Text("Sure about logging out?"),
      actions: [cancelbtn, continuebtn],
    );

    return showDialog(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  _showdeletedialog(
      BuildContext context, String? name, String? location, String? shopid) {
    Widget cancelbtn = TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text("Cancel"),
    );
    Widget continuebtn = TextButton(
      onPressed: () {
        showsnackbar("Please wait, shop data is being removed","");

        _deleterecords(name, location, shopid);
      },
      child: Text("Continue"),
    );

    AlertDialog alert = AlertDialog(
      title: Text("Warning"),
      content: Text("Sure about deleting: " +
          name! +
          "\n" +
          "\n" +
          "located: " +
          location! +
          "?" +
          "\n" +
          "\n" +
          "This action cannot be reversed"),
      actions: [cancelbtn, continuebtn],
    );

    return showDialog(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  _deleterecords(String? shopname, String? shoplocation, String? shopid) async {
    int timeout = 15;
    try {
      http.Response response =
          await http.get(Uri.parse(_uploadurl!)).timeout(Duration(seconds: timeout));

      if (response.statusCode == 200) {
        //connected, validate email address and contact
        var urlone =
            "http://$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php";
        var url =
            "$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php";
        var data = {
          "shopname": shopname,
          "location": shoplocation,
          "shop_id": shopid,
          "deletedetails": "request"
        };

        //await http.post(Uri.parse(url)one, body: data);
        var response = await http.post(Uri.parse(url), body: data);
        print(response.body);
        if (jsonDecode(response.body) == "-1") {
          showsnackbar(
              "Error processing request, please try again later", "Close");
        } else {
          var dbhelper = DBProvider();
          dbhelper.deleteWorkerbyshop(shopname, shoplocation);
          dbhelper.deleteshop(shopname, shoplocation);
          Future.delayed(Duration(seconds: 1)).then((value) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyShopPage()),
                (Route<dynamic> route) => false);

            showsnackbar("Data uploaded successfully", "Close");

            refreshpage();
          });
          Future.delayed(Duration(seconds: 1)).then((value) {});
        }
      } else {
        showsnackbar("Error connecting to server...", "Retry");
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      Future.delayed(Duration(seconds: 3)).then((value) {
        showsnackbar("Connection to server timed out!", "Close");
      });
    } on SocketException catch (e) {
      print('Socket Error: $e');
    } on Error catch (e) {
      Future.delayed(Duration(seconds: 3)).then((value) {
        showsnackbar("Error connecting to server : $e", "Close");
      });
    }
  }

  @override
  dispose() {
    animationController!.dispose(); // you need this
    super.dispose();
  }

  _createFolder(String? _foldername) async {
    final Directory _appDir = await getApplicationDocumentsDirectory();
    final Directory _appDirFolder = Directory('${_appDir.path}/$_foldername/');
    if (await _appDirFolder.exists()) {
      return _appDirFolder.path;
    } else {
      final Directory _appDirNewFolder =
          await _appDirFolder.create(recursive: true);

      return _appDirNewFolder.path;
    }
  }

  void _saveshopdetails(
      String? compname, String? complocation, BuildContext context) async {
    int timeout = 15;
    try {
      http.Response response =
          await http.get(Uri.parse(_uploadurl!)).timeout(Duration(seconds: timeout));

      if (response.statusCode == 200) {
        //connected, validate email address and contact
        var urlone =
            "http://$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php";
        var url =
            "$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php";
        String? randomchars = "sp" +
            DateFormat('yyyyMMddHHmmss').format(DateTime.now()).toString();
        var data = {
          "shopname": compname,
          "location": complocation,
          "shop_id": randomchars,
          "shopdetails": "request"
        };

        //await http.post(Uri.parse(url)one, body: data);
        var response = await http.post(Uri.parse(url), body: data);

        if (jsonDecode(response.body) == "-1") {
          showsnackbar(
              "Error processing request, please try again later", "Close");
        } else {
          String? randomchars = "sp" +
              DateFormat('yyyyMMddHHmmss').format(DateTime.now()).toString();
          var prodname = Shops(compname, complocation, randomchars);
          var dbhelper = DBProvider();
          dbhelper.newShopName(prodname);
          showsnackbar("Data uploaded successfully", "Close");


          Future.delayed(Duration(seconds: 1)).then((value) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyShopPage()),
                (Route<dynamic> route) => false);
            // showsnackbar("Data uploaded successfully", "Close");

            refreshpage();
          });
          Future.delayed(Duration(seconds: 1)).then((value) {});
        }
      } else {
        showsnackbar("Error connecting to server...", "Retry");
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      Future.delayed(Duration(seconds: 3)).then((value) {
        showsnackbar("Connection to server timed out!", "Close");
      });
    } on SocketException catch (e) {
      print('Socket Error: $e');
    } on Error catch (e) {
      Future.delayed(Duration(seconds: 3)).then((value) {
        showsnackbar("Error connecting to server : $e", "Close");
      });
    }
  }

  refreshpage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MyShopPage()));
  }

  final _formkey = GlobalKey<FormState>();
  Color primarycolor = Colors.pink[900]!;

  displaywindow(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          body: Builder(builder: (context) {
            return Dialog(
              insetPadding: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
              backgroundColor: Colors.black.withOpacity(.6),
              child: Container(
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                  image: new ExactAssetImage('assets/images/bg.png'),
                  fit: BoxFit.fill,
                )),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white.withOpacity(.05), width: 5),
                      color: Colors.black.withOpacity(.62),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14)),
                    ),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(20.0),
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
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Padding(
                              padding: EdgeInsets.only(bottom: bottom),
                              child: new Stack(children: <Widget>[
                                new Form(
                                  key: _formkey,
                                  child: Center(
                                    child:
                                        ListView(shrinkWrap: true, children: <
                                            Widget>[
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10)),
                                      new Image.asset(
                                        'assets/images/madam_rita.png',
                                        width: _iconanim!.value * 100,
                                        height: _iconanim!.value * 100,
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 25)),
                                      new TextFormField(
                                        decoration: new InputDecoration(
                                          labelText: "Name of Shop",
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
                                            _compname = newValue;
                                          });
                                        },
                                        keyboardType: TextInputType.text,
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 35)),
                                      new Text(
                                        "Shop Location",
                                        style: new TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.white),
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10)),
                                      Container(
                                        padding: EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(.6),
                                              width: 1),
                                          color: Colors.black.withOpacity(.25),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: TextFormField(
                                          maxLines: 4,
                                          decoration: new InputDecoration(
                                            hintText: "location",
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
                                              _complocation = newValue;
                                            });
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 35)),
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
                                            backgroundColor: primarycolor, // Replace `color` with `backgroundColor`
                                            foregroundColor: Colors.white, // Replace `textColor` with `foregroundColor`
                                          ),
                                          child: Text(
                                            "+Add",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                          onPressed: () {
                                            final form = _formkey.currentState;
                                            if (form!.validate()) {
                                              form.save();
                                              String? message = 'Please wait, store account is being created';

                                              // showsnackbar(message, "");
                                              showsnackbar(message, "");
                                              _saveshopdetails(_compname, _complocation, context);
                                              setState(() {});
                                            }
                                          },
                                        )
                                        ,
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 35)),
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
                                            backgroundColor: primarycolor, // Replace `color` with `backgroundColor`
                                            foregroundColor: Colors.white, // Replace `textColor` with `foregroundColor`
                                          ),
                                          child: Text(
                                            "Close",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                        ,
                                      ),
                                    ]),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  _executeoperations(String? tabtoquery) async {
    int timeout = 15;
    try {
      http.Response response =
          await http.get(Uri.parse(_uploadurl!)).timeout(Duration(seconds: timeout));

      if (response.statusCode == 200) {
        //connected, validate email address and contact
        var urlone =
            "http://$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php";
        var url =
            "$hostUrl/Madam_Rita_s_Enterprise/datasync.php?datamode=" +
                tabtoquery!;

        //await http.post(Uri.parse(url)one, body: data);
        var response = await http.get(Uri.parse(url));
        print(response.body);
        if (jsonDecode(response.body) == "-1") {
          showsnackbar("No data available to download","Close");
          Navigator.of(context).pop();

        } else {
          downloadshopdata(response.body.toString());
        }
      } else {
        showsnackbar("Error connecting to server...","Close");

      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      Future.delayed(Duration(seconds: 0)).then((value) {
        showsnackbar("Connection to server timed out!","Close");

      });
    } on SocketException catch (e) {
      print('Socket Error: $e');
    } on Error catch (e) {
      showsnackbar("Error connecting to server...","Close");
      print('Server Error: $e');

    }
  }

  /*Future<List<Shops>> downloadshopdata(String? res) async {
    var dbhelper = DBProvider();

    return (json.decode(res) as List).map((e) {
      dbhelper.downloadshopsdata(ModifiedShops.fromJson(e)).then((result) {
        Future.delayed(Duration(seconds: 1)).then((value) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MyShopPage()),
              (Route<dynamic> route) => false);

          // showsnackbar("Data uploaded successfully", "Close");
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Data downloaded successfully"),
            action: SnackBarAction(
              label: "Close",
              onPressed: () {},
            ),
          ));
          refreshpage();
        });
      }).catchError((error) {
        Navigator.of(context, rootNavigator: true).pop();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(error.toString()),
          action: SnackBarAction(
            label: "Close",
            onPressed: () {},
          ),
        ));
      });
    }).toList();
  }*/

  Future<List<Shops>> downloadshopdata(String? res) async {
    var dbhelper = DBProvider();

    // Decode the JSON response into a list of dynamic
    List<dynamic> decodedList = json.decode(res!);

    // Create a list to hold the Future results
    List<Future<Shops>> futureList = decodedList.map<Future<Shops>>((e) {
      // Create a ModifiedShops object and pass it to the dbhelper
      return dbhelper.downloadshopsdata(ModifiedShops.fromJson(e));
    }).toList();

    // Wait for all the Futures to complete
    List<Shops> results = await Future.wait(futureList);

    // Navigate and show Snackbar after all data is downloaded
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyShopPage()),
          (Route<dynamic> route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Data downloaded successfully"),
      action: SnackBarAction(
        label: "Close",
        onPressed: () {},
      ),
    ));

    refreshpage();

    return results; // Return the list of Shops
  }


  _displayalertforupdate() {
    _executeoperations("getshopdata");

    final loader = Center(
        child: Padding(
            padding: EdgeInsets.all(15.0),
            child: CircularProgressIndicator(
              strokeWidth: 5,
              backgroundColor: Colors.blueGrey,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
            )));

    AlertDialog alert = AlertDialog(
      insetPadding: EdgeInsets.all(50),
      title: Text(""),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
              child: Container(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Text(
                  'Please wait',
                  textAlign: TextAlign.center,
                ),
                loader
              ],
            ),
          )),
        ],
      ),
      actions: null,
    );

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: Colors.pink[100]!.withOpacity(.75),
      overlayColor: Colors.black.withOpacity(.2),
      animatedIconTheme: IconThemeData(size: 22.0),
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.download_rounded, color: Colors.white),
          backgroundColor: Colors.pink[900],
          onTap: () {
            _displayalertforupdate();
          },
          label: 'Download shop data',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.pink[100]!.withOpacity(.6),
        ),
        SpeedDialChild(
          child: Icon(Icons.logout, color: Colors.white),
          backgroundColor: Colors.pink[900],
          onTap: () {
            _showlogoutdialog(context);
          },
          label: 'Log Out',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.pink[100]!.withOpacity(.6),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: Container(
            width: MediaQuery.of(context).size.width * 1,
            decoration: new BoxDecoration(
                image: new DecorationImage(
              image: new ExactAssetImage('assets/images/bg.png'),
              fit: BoxFit.fill,
            )),
            child: new BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(
                decoration:
                    new BoxDecoration(color: Colors.black.withOpacity(.0)),
              ),
            ),
          ),
        ),
        title: Text(
          'Madam Rita\'s Enterprise',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.pink[900]!.withOpacity(.65),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 1,
          padding: const EdgeInsets.only(bottom: 0),
          decoration: new BoxDecoration(
              image: new DecorationImage(
            image: new ExactAssetImage('assets/images/bg.png'),
            fit: BoxFit.fill,
          )),
          child: new BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.height * 1,
              decoration:
                  new BoxDecoration(color: Colors.black.withOpacity(0.68)),
              child: Stack(
                children: <Widget>[
                  Center(
                    child: new Container(
                      padding: EdgeInsets.only(
                          top: 10.0, left: 10, right: 10, bottom: 35),
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 180,
                            margin: EdgeInsets.only(bottom: 23, top: 15),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.23),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                  width: 1,
                                  color: Colors.white.withOpacity(.8)),
                            ),
                            child: Center(
                              child: Stack(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.business_rounded,
                                      color: Colors.white.withOpacity(0.85),
                                      size: 175,
                                    ),
                                  ),
                                  Container(
                                    transform: Matrix4.translationValues(
                                        -19, -56.0, 0),
                                    margin: EdgeInsets.only(top: 30),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Image.asset(
                                        'assets/images/madam_rita.png',
                                        width: 140,
                                        height: 140,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.white.withOpacity(.6),
                            height: 3,
                            thickness: 2,
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 2, bottom: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new Text(
                                  "Shops",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: 'serif',
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                  ),
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(left: 10)),
                                RawMaterialButton(
                                  onPressed: () {
                                    displaywindow(context);
                                  },
                                  elevation: 5.0,
                                  fillColor: Colors.pink[900]!.withOpacity(.4),
                                  child: Icon(
                                    Icons.add_business_rounded,
                                    size: 15.0,
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                  ),
                                  padding: EdgeInsets.all(6.0),
                                  shape: CircleBorder(
                                    side: BorderSide(
                                        color: Colors.white.withOpacity(.4),
                                        width: 2),
                                  ),
                                  constraints: BoxConstraints.expand(
                                      width: 35, height: 35),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.white.withOpacity(.6),
                            height: 3,
                            thickness: 2,
                          ),
                          Expanded(
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  child: new FutureBuilder<List<Shops>>(
                                    future: _future,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<List<Shops>> snapshot) {
                                      Widget newsListSliver;
                                      if (snapshot.hasData) {
                                        newsListSliver = ListView.builder(
                                          itemCount: snapshot.data!.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            Shops item = snapshot.data![index];
                                            return Container(
                                              padding:
                                                  EdgeInsets.only(bottom: 15),
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        left: 5,
                                                        top: 9,
                                                        bottom: 9),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          sharedpref!.setString(
                                                              'shopname',
                                                              item.name
                                                                  .toString());
                                                        });
                                                        Future.delayed(Duration(
                                                                seconds: 1))
                                                            .then((value) {
                                                          Navigator
                                                              .pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          MyHomePage(
                                                                            shopname:
                                                                                item.name,
                                                                            location:
                                                                                item.location,
                                                                          )));
                                                        });
                                                      },
                                                      child: Row(
                                                        children: <Widget>[
                                                          Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        .23),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            9),
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            .8)),
                                                              ),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(3.0),
                                                              child: Icon(
                                                                Icons.home_work,
                                                                color: Colors
                                                                    .white,
                                                                size: 15,
                                                              )),
                                                          Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          5)),
                                                          Text(
                                                            item.name!,
                                                            style: TextStyle(
                                                              fontSize: 17,
                                                              fontFamily:
                                                                  'serif',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      1),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 5,
                                                                top: 9,
                                                                bottom: 9),
                                                        child: GestureDetector(
                                                          onTap: () {},
                                                          child: Row(
                                                            children: <Widget>[
                                                              Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            .23),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(9),
                                                                    border: Border.all(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .pink[100]!
                                                                            .withOpacity(.8)),
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              3.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .location_pin,
                                                                    color: Colors
                                                                        .pink[
                                                                            100]!
                                                                        .withOpacity(
                                                                            .8),
                                                                    size: 15,
                                                                  )),
                                                              Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              5)),
                                                              Text(
                                                                item.location!,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 17,
                                                                  fontFamily:
                                                                      'serif',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          _showdeletedialog(
                                                              context,
                                                              item.name,
                                                              item.location,
                                                              item.shop_id);
                                                        },
                                                        child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      .23),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          9),
                                                              border: Border.all(
                                                                  width: 1,
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          .8)),
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    3.0),
                                                            child: Icon(
                                                              Icons
                                                                  .delete_forever,
                                                              color:
                                                                  Colors.white,
                                                              size: 15,
                                                            )),
                                                      ),
                                                    ],
                                                  ),
                                                  Divider(
                                                    color: Colors.white
                                                        .withOpacity(.6),
                                                    height: 3,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        newsListSliver = Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      return newsListSliver;
                                    },
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Visibility(
                                    visible: _prodvisible,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 30,
                                      padding: EdgeInsets.all(5.0),
                                      color: Colors.black.withOpacity(.6),
                                      child: Text(
                                        'No shop data available.',
                                        textAlign: TextAlign.center,
                                        style: new TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: buildSpeedDial(),
    );
  }
}
