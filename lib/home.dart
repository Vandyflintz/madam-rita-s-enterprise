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
import 'Utils/customfunctions.dart';
import 'shoppingCart.dart';
import 'addproduct.dart';
import 'saleschart.dart';
import 'noteshome.dart';
import 'settingshome.dart';
import 'shopspage.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(Homepage());
}

class Homepage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Madam Rita\'s Enterprise',
      home: MyHomePage(title: 'Madam Rita\'s Enterprise'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title, this.shopname, this.location})
      : super(key: key);

  final String? title;
  final String? shopname;
  final String? location;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController? animationController;
  Animation? animation;
  ScrollController? scrollController;
  bool dialVisible = true;
  SharedPreferences? sharedpref;
  String? _user = '', _shopname = '';
  @override
  void initState() {
    super.initState();

    scrollController = ScrollController()
      ..addListener(() {
        setDialVisible(scrollController!.position.userScrollDirection ==
            ScrollDirection.forward);
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

  initializesharedpref() async {
    sharedpref = await SharedPreferences.getInstance();
    _user = sharedpref!.getString('user');
    _shopname = sharedpref!.getString('shopname');
  }

  double _endval = 2 * pi;
  double _endvalone = 2 * pi;

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
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

  _showlocation(BuildContext context, String? location) {
    Widget cancelbtn = TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text("Cancel"),
    );
    Widget continuebtn = TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text("Close"),
    );

    AlertDialog alert = AlertDialog(
      title: Text("Shop's Location"),
      content: Text("Located: " + location!),
      actions: [continuebtn],
    );

    return showDialog(
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
          child: Icon(Icons.settings, color: Colors.black),
          backgroundColor: Colors.pink[100],
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsPage(
                          shopname: widget.shopname,
                          location: widget.location, key: scaffoldKey, title: widget.title,
                        )));
          },
          label: 'Settings',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
          labelBackgroundColor: Colors.pink[100]!.withOpacity(.6),
        ),
        SpeedDialChild(
          child: Icon(Icons.book, color: Colors.black),
          backgroundColor: Colors.pink[100],
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => NotesContainer(
                          shopname: widget.shopname,
                          location: widget.location,
                        )));
          },
          label: 'Notes',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
          labelBackgroundColor: Colors.pink[100]!.withOpacity(.6),
        ),
        SpeedDialChild(
          child: Icon(Icons.home, color: Colors.black),
          backgroundColor: Colors.pink[100],
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MyShopPage()));
          },
          label: 'Shops Home',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
          labelBackgroundColor: Colors.pink[100]!.withOpacity(.6),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    initializesharedpref();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: <Widget>[
          new IconButton(
            icon: Icon(
              Icons.location_pin,
              color: Colors.white,
            ),
            onPressed: () {
              _showlocation(context, widget.location);
            },
          )
        ],
        centerTitle: true,
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: Container(
            width: MediaQuery.of(context).size.width * 1,
            decoration: new BoxDecoration(
                color: Colors.pink[100]?.withOpacity(0.75),
             ),
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
          widget.shopname!,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.pink[900]!.withOpacity(.35),
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
                  new BoxDecoration(color: Colors.black.withOpacity(0.4)),
              child: Center(
                child: new Container(
                  height: MediaQuery.of(context).size.height * 0.50,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductsPage(
                                        text: "pname",
                                        shopname: widget.shopname!,
                                        location: widget.location!, key: scaffoldKey, title: '',
                                      )));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: MediaQuery.of(context).size.height * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.3),
                            border: Border.all(
                              color: Colors.white.withOpacity(.3),
                              width: 7,
                            ),
                            borderRadius:
                                BorderRadius.only(topLeft: Radius.circular(60)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new Icon(
                                Icons.add_to_queue_outlined,
                                color: Colors.pink[100]!.withOpacity(.75),
                                size: MediaQuery.of(context).size.width * 0.2,
                              ),
                              new Padding(
                                  padding: const EdgeInsets.only(top: 5)),
                              new Text(
                                " Add Product",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StockList(
                                        shopname: widget.shopname,
                                        location: widget.location,
                                      )));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: MediaQuery.of(context).size.height * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.3),
                            border: Border.all(
                              color: Colors.white.withOpacity(.3),
                              width: 7,
                            ),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(60)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TweenAnimationBuilder<double>(
                                duration: const Duration(seconds: 7),
                                onEnd: () {
                                  setState(() {
                                    _endvalone = _endvalone == 2 * pi ? 0 : 2 * pi;
                                  });
                                },
                                tween: Tween<double>(begin: 0, end: _endvalone),
                                builder: (BuildContext context, double value, Widget? child) {  // Use Widget? child to handle nullability
                                  return Transform(
                                    transform: Matrix4.rotationY(value),
                                    alignment: Alignment.center,
                                    child: child,
                                  );
                                },
                                child: Icon(
                                  Icons.table_chart_outlined,
                                  color: Colors.pink[100]?.withOpacity(0.75), // Use ?. to safely access the color
                                  size: MediaQuery.of(context).size.width * 0.2,
                                ),
                              )
                              ,
                              new Padding(
                                  padding: const EdgeInsets.only(top: 5)),
                              new Text(
                                " View Stock",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyShoppingPage(
                                        shopname: widget.shopname,
                                        location: widget.location,
                                      )));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: MediaQuery.of(context).size.height * 0.45,
                          padding: EdgeInsets.only(top: 5, bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.3),
                            border: Border.all(
                              color: Colors.white.withOpacity(.3),
                              width: 7,
                            ),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(60)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TweenAnimationBuilder<double>(
                                duration: const Duration(seconds: 7),
                                onEnd: () {
                                  setState(() {
                                    _endval = _endval == 2 * pi ? 0 : 2 * pi;
                                  });
                                },
                                tween: Tween<double>(begin: 0, end: _endval),
                                builder: (BuildContext context, double value, Widget? child) {  // Use Widget? child to handle null safety
                                  return Transform(
                                    transform: Matrix4.rotationY(value),
                                    alignment: Alignment.center,
                                    child: child,
                                  );
                                },
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.pink[100]?.withOpacity(0.75), // Use ?. to safely access the color
                                  size: MediaQuery.of(context).size.width * 0.2,
                                ),
                              )
                              ,
                              new Padding(
                                  padding: const EdgeInsets.only(top: 5)),
                              new Text(
                                " Process shopped items",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChartList(
                                        shopname: widget.shopname,
                                        location: widget.location,
                                      )));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: MediaQuery.of(context).size.height * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.3),
                            border: Border.all(
                              color: Colors.white.withOpacity(.3),
                              width: 7,
                            ),
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(60)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new Icon(
                                Icons.bar_chart_rounded,
                                color: Colors.pink[100]!.withOpacity(.75),
                                size: MediaQuery.of(context).size.width * 0.23,
                              ),
                              new Padding(
                                  padding: const EdgeInsets.only(top: 5)),
                              new Text(
                                " Sales Chart",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
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
        ),
      ),
      floatingActionButton:
          buildSpeedDial(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
