import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home.dart';
import 'monthlysalesrecord.dart';
import 'keep_page_alive.dart';
import 'ViewControllers/HomePage.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madam Rita\'s Enterprise',
      home: NotesContainer(),
    );
  }
}

final _scaffoldKey = GlobalKey<ScaffoldState>();
bool pressed = false, _obscuretext = false, _visibility = false;
SnackBar? snackBar;

class NotesContainer extends StatefulWidget {
  NotesContainer({Key? key, this.title, this.shopname, this.location})
      : super(key: key);
  final String? title, shopname, location;
  @override
  _MyShoppingPageState createState() => _MyShoppingPageState();
}

class _MyShoppingPageState extends State<NotesContainer>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Container(
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
              padding: EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.height * 1,
              decoration:
                  new BoxDecoration(color: Colors.black.withOpacity(0.4)),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottom),
                child: Theme(
                    data: new ThemeData(
                      textTheme: TextTheme().apply(bodyColor: Colors.black),
                      iconTheme: IconThemeData(color: Colors.black),

                    ),
                    child: HomePage()),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.pink[100]!.withOpacity(.75),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MyHomePage(
                          shopname: widget.shopname,
                          location: widget.location,
                        )));
          },
          tooltip: 'Return to homepage',
          child: const Icon(Icons.home_rounded),
        ));
  }
}
