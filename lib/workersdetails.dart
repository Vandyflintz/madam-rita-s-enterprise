import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'DatabaseHelper.dart';
import 'dart:async';
import 'Utils/customfunctions.dart';
import 'products_model.dart';
import 'home.dart';
import 'dart:io';
import 'dart:io' as Io;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyWorkersRecords());
}

class MyWorkersRecords extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Madam Rita\'s Enterprise',
      home: WorkersRecords(title: 'Madam Rita\'s Enterprise'),
    );
  }
}

double totalprice = 0;

Future<List<Products>> fetchavailableproducts() async {
  var dbhelper = DBProvider();
  Future<List<Products>> products = dbhelper.fetchAllProducts();
  return products;
}

class WorkersRecords extends StatefulWidget {
  WorkersRecords({Key? key, this.title, this.shopname, this.location})
      : super(key: key);
  final String? title, shopname, location;

  @override
  _MyChartState createState() => _MyChartState();
}

class _MyChartState extends State<WorkersRecords>
    with TickerProviderStateMixin {
  String? directory;
  var finaldir;
  List files = [];
  String? imgdir;
  String? searchdate = '', dateinwords = '';
  ScrollController? _controller;
  String? calculatedprice = '';
  Future<List<Workers>>? _future;
  final formattedval = new NumberFormat("#,##0.00", "en_US");
  TextEditingController? txtcon;
  bool _prodvisible = false, _pricevisible = false;
  Icon _searchIcon = new Icon(Icons.search);
  Icon _clearIcon = new Icon(Icons.clear_all);
  Widget _appBarTitle = new Text('Search for products here');
  String? totalnumberofworkers = '';
  Color primarycolor = Colors.pink[900]!;
  final _formkey = GlobalKey<FormState>();
  AnimationController? _iconanimcontroller;
  Animation<double>? _iconanim;
  @override
  void initState() {
    super.initState();
    _iconanimcontroller = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 1000));
    txtcon = new TextEditingController();
    _iconanim =
        new CurvedAnimation(parent: _iconanimcontroller!, curve: Curves.easeOut);
    _iconanim!.addListener(() => this.setState(() {}));
    _iconanimcontroller!.forward();
    loadfile();
    _future = DBProvider().fetchallworkers(widget.shopname, widget.location);

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

    _showcalcprice();
    if (searchdate?.isEmpty ?? true) {
      searchdate = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();

      setState(() {
        _textEditingController.text = searchdate!;
        dateinwords =
            DateFormat('EEEE , MMMM d, yyyy').format(DateTime.now()).toString();
      });
    }
    _controller = ScrollController();
    _controller!.addListener(_scrollListener);
  }


  _displayprofile(
      String? fullname,
      String? password,
      String? picture,
      String? role,
      String? date_added,
      String? initial_salary,
      String? current_salary,
      String? contact,
      String? address,
      String? salary_raise_date,
      String? worker_id) {
    String? sdate = "", wdate = "", fdate = "";
    if (salary_raise_date!.isEmpty ||
        salary_raise_date == null ||
        salary_raise_date.contains("null")) {
      sdate = "Not yet";
    } else {
      sdate = DateFormat('EEEE , MMMM d, yyyy')
          .format(DateTime.tryParse(salary_raise_date!)!)
          .toString();
    }

    fdate = DateFormat('yyyy-MM-dd')
        .format(DateTime.tryParse(date_added!)!)
        .toString();

    wdate = DateFormat('EEEE , MMMM d, yyyy')
        .format(DateTime.parse(date_added))
        .toString();
    Widget cancelbtn = TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text("Close"),
    );

    Dialog alert = Dialog(
      insetPadding: EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
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
              border:
                  Border.all(color: Colors.white.withOpacity(.05), width: 5),
              color: Colors.black.withOpacity(.62),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14)),
            ),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                new Padding(padding: const EdgeInsets.only(top: 10)),
                Container(
                  width: 98,
                  height: 98,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 3, color: Colors.white.withOpacity(1)),
                      image: DecorationImage(
                          fit: BoxFit.fill, image: getfile(imgdir, worker_id))),
                ),
                new Padding(padding: const EdgeInsets.only(top: 25)),
                Row(
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.23),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                              width: 1, color: Colors.white.withOpacity(.8)),
                        ),
                        padding: EdgeInsets.all(3.0),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 15,
                        )),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Text(
                      "Full Name : " + fullname!,
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    )
                  ],
                ),
                new Padding(padding: const EdgeInsets.only(top: 20)),
                Divider(
                  color: Colors.white.withOpacity(.6),
                  height: 1,
                ),
                new Padding(padding: const EdgeInsets.only(top: 10)),
                Row(
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.23),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                              width: 1, color: Colors.white.withOpacity(.8)),
                        ),
                        padding: EdgeInsets.all(3.0),
                        child: Icon(
                          Icons.security,
                          color: Colors.white,
                          size: 15,
                        )),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Text(
                      "Password : " + password!,
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    )
                  ],
                ),
                new Padding(padding: const EdgeInsets.only(top: 20)),
                Divider(
                  color: Colors.white.withOpacity(.6),
                  height: 1,
                ),
                new Padding(padding: const EdgeInsets.only(top: 10)),
                Row(
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.23),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                              width: 1, color: Colors.white.withOpacity(.8)),
                        ),
                        padding: EdgeInsets.all(3.0),
                        child: Icon(
                          Icons.account_circle,
                          color: Colors.white,
                          size: 15,
                        )),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Expanded(
                      child: Text(
                        "Role : " + role!,
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                      ),
                    )
                  ],
                ),
                new Padding(padding: const EdgeInsets.only(top: 20)),
                Divider(
                  color: Colors.white.withOpacity(.6),
                  height: 1,
                ),
                new Padding(padding: const EdgeInsets.only(top: 10)),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Row(
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.23),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                                width: 1, color: Colors.white.withOpacity(.8)),
                          ),
                          padding: EdgeInsets.all(3.0),
                          child: Icon(
                            Icons.calendar_view_day,
                            color: Colors.white,
                            size: 15,
                          )),
                      Padding(padding: EdgeInsets.only(right: 5)),
                      Expanded(
                        child: Text(
                          "Date Employed : " + wdate,
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'serif',
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(255, 255, 255, 1),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                new Padding(padding: const EdgeInsets.only(top: 20)),
                Divider(
                  color: Colors.white.withOpacity(.6),
                  height: 1,
                ),
                new Padding(padding: const EdgeInsets.only(top: 10)),
                Row(
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.23),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                              width: 1, color: Colors.white.withOpacity(.8)),
                        ),
                        padding: EdgeInsets.all(3.0),
                        child: Icon(
                          Icons.money,
                          color: Colors.white,
                          size: 15,
                        )),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Text(
                      "Initial Salary : Gh¢ " +
                          formattedval
                              .format(double.tryParse(initial_salary!))
                              .toString(),
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    )
                  ],
                ),
                new Padding(padding: const EdgeInsets.only(top: 20)),
                Divider(
                  color: Colors.white.withOpacity(.6),
                  height: 1,
                ),
                new Padding(padding: const EdgeInsets.only(top: 10)),
                Row(
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.23),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                              width: 1, color: Colors.white.withOpacity(.8)),
                        ),
                        padding: EdgeInsets.all(3.0),
                        child: Icon(
                          Icons.money,
                          color: Colors.white,
                          size: 15,
                        )),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Text(
                      "Current Salary : Gh¢ " +
                          formattedval
                              .format(double.tryParse(current_salary!))
                              .toString(),
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    )
                  ],
                ),
                new Padding(padding: const EdgeInsets.only(top: 20)),
                Divider(
                  color: Colors.white.withOpacity(.6),
                  height: 1,
                ),
                new Padding(padding: const EdgeInsets.only(top: 10)),
                Row(
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.23),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                              width: 1, color: Colors.white.withOpacity(.8)),
                        ),
                        padding: EdgeInsets.all(3.0),
                        child: Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 15,
                        )),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Text(
                      contact!,
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    )
                  ],
                ),
                new Padding(padding: const EdgeInsets.only(top: 20)),
                Divider(
                  color: Colors.white.withOpacity(.6),
                  height: 1,
                ),
                new Padding(padding: const EdgeInsets.only(top: 10)),
                Row(
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.23),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                              width: 1, color: Colors.white.withOpacity(.8)),
                        ),
                        padding: EdgeInsets.all(3.0),
                        child: Icon(
                          Icons.contact_page,
                          color: Colors.white,
                          size: 15,
                        )),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Expanded(
                      child: Text(
                        "Address : " + address!,
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                      ),
                    )
                  ],
                ),
                new Padding(padding: const EdgeInsets.only(top: 20)),
                Divider(
                  color: Colors.white.withOpacity(.6),
                  height: 1,
                ),
                new Padding(padding: const EdgeInsets.only(top: 10)),
                Row(
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.23),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                              width: 1, color: Colors.white.withOpacity(.8)),
                        ),
                        padding: EdgeInsets.all(3.0),
                        child: Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 15,
                        )),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Expanded(
                      child: Text(
                        "Salary Raise Date : " + sdate,
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                      ),
                    )
                  ],
                ),
                new Padding(padding: const EdgeInsets.only(top: 20)),
                Divider(
                  color: Colors.white.withOpacity(.6),
                  height: 1,
                ),
                new Padding(padding: const EdgeInsets.only(top: 10)),
                Row(
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.23),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                              width: 1, color: Colors.white.withOpacity(.8)),
                        ),
                        padding: EdgeInsets.all(3.0),
                        child: Icon(
                          Icons.person_pin,
                          color: Colors.white,
                          size: 15,
                        )),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Expanded(
                      child: Text(
                        "Worker's ID : " + worker_id!,
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                      ),
                    )
                  ],
                ),
                new Padding(padding: const EdgeInsets.only(top: 30)),
                Divider(
                  color: Colors.white.withOpacity(.6),
                  height: 1,
                ),
                new Padding(padding: const EdgeInsets.only(top: 10)),
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
                      Navigator.of(context).pop();
                    },
                  )

                ,
                )
              ],
            ),
          ),
        ),
      ),
    );

    return showDialog(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  _displayalertforworkerremoval(String? name, String? workerid) {
    Widget cancelbtn = TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text("Cancel"),
    );
    Widget continuebtn = TextButton(
      onPressed: () {
        _deleteworkerdetails(workerid);
      },
      child: Text("Continue"),
    );

    AlertDialog alert = AlertDialog(
      title: Text("Warning"),
      content: Text("Sure about deleting worker's account?"),
      actions: [cancelbtn, continuebtn],
    );

    return showDialog(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  String? _uploadurl =
      "$hostUrl/Madam_Rita_s_Enterprise/connection.php";
  _updatesalarydetails(String? workerid, String? salary, String? date) async {
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
          "date": searchdate,
          "salary": txtcon!.text,
          "workerid": workerid,
          "shopname": widget.shopname,
          "location": widget.location,
          "updatesalary": "request"
        };

        //await http.post(Uri.parse(url)one, body: data);
        var response = await http.post(Uri.parse(url), body: data);
        print(jsonDecode(response.body).toString());
        if (jsonDecode(response.body) == "-1") {
          showsnackbar("Error processing request, please try again later","Close", context);
        } else {
          var dbhelper = DBProvider();
          dbhelper.updatesalary(workerid, txtcon!.text, widget.shopname,
              widget.location, searchdate);
          showsnackbar("Salary updated successfully", "Close", context);
          Future.delayed(Duration(seconds: 1)).then((value) {
            Navigator.of(context).pop();
            setState(() {
              txtcon!.text = '';
              _future = DBProvider()
                  .fetchallworkers(widget.shopname, widget.location);
            });
          });
          Future.delayed(Duration(seconds: 1)).then((value) {});
        }
      } else {
       showsnackbar("Error connecting to server...","Close", context);
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      Future.delayed(Duration(seconds: 3)).then((value) {
        showsnackbar("Connection to server timed out!", "Close", context);
      });
    } on SocketException catch (e) {
      print('Socket Error: $e');
    } on Error catch (e) {
      Future.delayed(Duration(seconds: 3)).then((value) {
       showsnackbar("Error connecting to server : $e", "Close", context);
      });
    }
  }

  _deleteworkerdetails(String? workerid) async {
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
        var data = {"workerid": workerid, "deleteworker": "request"};

        //await http.post(Uri.parse(url)one, body: data);
        var response = await http.post(Uri.parse(url), body: data);
        print(jsonDecode(response.body).toString());
        if (jsonDecode(response.body) == "-1") {
        showsnackbar("Error processing request, please try again later", "Close", context);
        } else {
          var dbhelper = DBProvider();
          dbhelper.deleteWorkerbyid(workerid);
          showsnackbar("Worker has been deleted","Close", context);
          Future.delayed(Duration(seconds: 1)).then((value) {
            Navigator.of(context).pop();
            setState(() {
              _future = DBProvider()
                  .fetchallworkers(widget.shopname, widget.location);
            });
          });
          Future.delayed(Duration(seconds: 1)).then((value) {});
        }
      } else {
        showsnackbar("Error connecting to server...","Close",context);
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      Future.delayed(Duration(seconds: 3)).then((value) {
      showsnackbar("Connection to server timed out!", "Close", context);
      });
    } on SocketException catch (e) {
      print('Socket Error: $e');
    } on Error catch (e) {
      Future.delayed(Duration(seconds: 3)).then((value) {
        showsnackbar("Error connecting to server : $e", "Close", context);
      });
    }
  }

  _displaydialogforsalaryincrease(
      String? name, String? salary, String? workerid, String? image) {
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
                width: MediaQuery.of(context).size.width,
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
                            padding: const EdgeInsets.all(10.0),
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
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 50,
                                        padding: EdgeInsets.only(top: 15),
                                        color: Colors.black.withOpacity(0.85),
                                        child: Text(
                                          'Increase Salary For : ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontFamily: 'serif',
                                            fontWeight: FontWeight.w500,
                                            color: Color.fromRGBO(
                                                255, 255, 255, 1),
                                          ),
                                        ),
                                      ), //
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 40)),
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: getfile(imgdir, image))),
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 35)),
                                      Row(
                                        children: <Widget>[
                                          Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(.23),
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.white
                                                        .withOpacity(.8)),
                                              ),
                                              padding: EdgeInsets.all(3.0),
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 15,
                                              )),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(right: 5)),
                                          Text(
                                            name!,
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontFamily: 'serif',
                                              fontWeight: FontWeight.w500,
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1),
                                            ),
                                          )
                                        ],
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 35)),
                                      Row(
                                        children: <Widget>[
                                          Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(.23),
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.white
                                                        .withOpacity(.8)),
                                              ),
                                              padding: EdgeInsets.all(3.0),
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 15,
                                              )),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(right: 5)),
                                          Text(
                                            workerid!,
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontFamily: 'serif',
                                              fontWeight: FontWeight.w500,
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1),
                                            ),
                                          )
                                        ],
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 25)),
                                      Row(
                                        children: <Widget>[
                                          Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(.23),
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.white
                                                        .withOpacity(.8)),
                                              ),
                                              padding: EdgeInsets.all(3.0),
                                              child: Icon(
                                                Icons.money,
                                                color: Colors.white,
                                                size: 15,
                                              )),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(right: 5)),
                                          Text(
                                            "Gh¢ " +
                                                formattedval.format(salary),
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontFamily: 'serif',
                                              fontWeight: FontWeight.w500,
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1),
                                            ),
                                          )
                                        ],
                                      ),
                                      new TextFormField(
                                        controller: txtcon,
                                        decoration: new InputDecoration(
                                          labelText: "Enter new salary",
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'This field is required';
                                          } else {
                                            return null;
                                          }
                                        },
                                        onSaved: (newValue) {
                                          setState(() {});
                                        },
                                        keyboardType: TextInputType.text,
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 35)),
                                      FractionallySizedBox(
                                        widthFactor: 0.50,
                                        child: new

                                        ElevatedButton(
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
                                            final form =
                                                _formkey.currentState;
                                            if (form!.validate()) {
                                              form.save();
                                              String? message =
                                                  'Please wait, worker\'s salary is being updated';
                                              String? date =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(DateTime.now())
                                                  .toString();
                                              showsnackbar(message, "", context);

                                              _updatesalarydetails(workerid,
                                                  txtcon!.text, date);
                                              setState(() {});
                                            }
                                          },
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
                                            Navigator.of(context).pop();
                                          },
                                        ),
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

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = Theme(
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
          child: new TextField(
            onSubmitted: (value) {
              setState(() {});
              Future.delayed(Duration(seconds: 0)).then((value) {
                _future!.then((value) {
                  if (value.isNotEmpty) {
                    Future.delayed(Duration(seconds: 0)).then((value) {
                      setState(() {
                        _pricevisible = true;
                        _prodvisible = false;
                      });
                    });
                  } else {
                    Future.delayed(Duration(seconds: 0)).then((value) {
                      setState(() {
                        _prodvisible = true;
                        _pricevisible = false;
                      });
                    });
                  }
                });
              });
            },
            textInputAction: TextInputAction.search,
            decoration: new InputDecoration(
                prefixIcon: new Icon(Icons.search), hintText: 'Search...'),
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Search for products here');
      }
    });
  }

  TextEditingController _textEditingController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  DateTime? _selectedDate;


  SoldProducts? soldProducts;

  loadfile() async {
    final dir = await (getApplicationDocumentsDirectory());
    imgdir = dir.path + "/MyStockImages/";
  }

  void _fileslist() async {
    directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      files = Io.Directory("$directory/MyStockImages/").listSync();
    });
  }

  int gridsize = 0;

  @override
  Widget build(BuildContext context) {
    //no of years served
    //salary percentage
    //total salary
    //average sales
    double devicewidth = MediaQuery.of(context).size.width,
        deviceheight = MediaQuery.of(context).size.height,
        navwidth;

    if (devicewidth > 600) {
      // gridsize = 3;
    } else {
      // gridsize = 2;
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              child: Stack(
                children: <Widget>[
                  Center(
                    child: new Container(
                      padding: EdgeInsets.only(
                          top: 10.0, left: 10, right: 10, bottom: 35),
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            padding: EdgeInsets.only(top: 15.0),
                            color: Colors.black.withOpacity(.6),
                            child: Text(
                              'Total number of workers : ' +
                                  totalnumberofworkers!,
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.0,
                                  color: Colors.white),
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  child: new FutureBuilder<List<Workers>>(
                                    future: _future,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<List<Workers>> snapshot) {
                                      Widget newsListSliver;
                                      if (snapshot.hasData) {
                                        newsListSliver = ListView.builder(
                                          itemCount: snapshot.data!.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            Workers item = snapshot.data![index];
                                            Future.delayed(Duration(seconds: 1))
                                                .then((value) {
                                              if (mounted) {
                                                setState(() {
                                                  totalnumberofworkers =
                                                      snapshot.data!.length
                                                          .toString();
                                                });
                                              }
                                            });

                                            return Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              padding:
                                                  EdgeInsets.only(bottom: 15),
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        left: 5,
                                                        top: 9,
                                                        bottom: 9),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Container(
                                                          width: 60,
                                                          height: 60,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          70),
                                                              border: Border.all(
                                                                  width: 3,
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          1)),
                                                              image: DecorationImage(
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  image: getfile(
                                                                      imgdir,
                                                                      item.worker_id))),
                                                        ),
                                                        Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    right: 5)),
                                                        Column(
                                                          children: [
                                                            Text(
                                                              item.firstname! +
                                                                  " " +
                                                                  item.lastname!,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      18.0,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            15)),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: <
                                                                  Widget>[
                                                                Padding(
                                                                    padding: EdgeInsets.only(
                                                                        right:
                                                                            7)),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    _displayprofile(
                                                                        item.firstname! +
                                                                            " " +
                                                                            item.lastname!,
                                                                        item.password,
                                                                        item.picture,
                                                                        item.role,
                                                                        item.date_added,
                                                                        item.initial_salary,
                                                                        item.current_salary,
                                                                        item.contact,
                                                                        item.address,
                                                                        item.salary_raise_date,
                                                                        item.worker_id);
                                                                  },
                                                                  child: Container(
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(.23),
                                                                        borderRadius:
                                                                            BorderRadius.circular(9),
                                                                        border: Border.all(
                                                                            width:
                                                                                1,
                                                                            color:
                                                                                Colors.white.withOpacity(.8)),
                                                                      ),
                                                                      padding: EdgeInsets.all(3.0),
                                                                      child: Icon(
                                                                        Icons
                                                                            .view_list,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            20,
                                                                      )),
                                                                ),
                                                                Padding(
                                                                    padding: EdgeInsets.only(
                                                                        right:
                                                                            39)),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    _displaydialogforsalaryincrease(
                                                                        item.firstname! +
                                                                            " " +
                                                                            item.lastname!,
                                                                        item.current_salary,
                                                                        item.worker_id,
                                                                        item.picture);
                                                                  },
                                                                  child: Container(
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(.23),
                                                                        borderRadius:
                                                                            BorderRadius.circular(9),
                                                                        border: Border.all(
                                                                            width:
                                                                                1,
                                                                            color:
                                                                                Colors.white.withOpacity(.8)),
                                                                      ),
                                                                      padding: EdgeInsets.all(3.0),
                                                                      child: Icon(
                                                                        Icons
                                                                            .upgrade,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            20,
                                                                      )),
                                                                ),
                                                                Padding(
                                                                    padding: EdgeInsets.only(
                                                                        right:
                                                                            39)),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    _displayalertforworkerremoval(
                                                                        item.firstname! +
                                                                            " " +
                                                                            item.lastname!,
                                                                        item.worker_id);
                                                                  },
                                                                  child: Container(
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(.23),
                                                                        borderRadius:
                                                                            BorderRadius.circular(9),
                                                                        border: Border.all(
                                                                            width:
                                                                                1,
                                                                            color:
                                                                                Colors.white.withOpacity(.8)),
                                                                      ),
                                                                      padding: EdgeInsets.all(3.0),
                                                                      child: Icon(
                                                                        Icons
                                                                            .delete_forever,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            20,
                                                                      )),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
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
                                        'No workers data available.',
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
    );
  }

  Future<File> file(String? filename) async {
    return File(imgdir! + filename!.trimLeft());
  }

  getfile(String? imgdir, String? name) {
    String? lastcharac = name!.substring(name.length - 1);
    var fname = name.trimLeft() + ".jpg";
    if (File("$imgdir/$fname").existsSync()) {
      String? imgname = name + ".jpg";
      return FileImage(File(imgdir! + fname.trimLeft()));
      Image.file(File(imgdir + imgname.trimLeft()));
    } else {
      downloadimage(fname);

      return NetworkImage(
          "$hostUrl/Madam_Rita_s_Enterprise/images/" +
              fname);
    }
  }

  downloadimage(String? filename) async {
    var url =
        "$hostUrl/Madam_Rita_s_Enterprise/images/" +
            filename!;
    var response = await http.get(Uri.parse(url));
    var filepathname = imgdir! + filename;
    File file = new File(filepathname);
    file.writeAsBytesSync(response.bodyBytes);
    print("Image has been downloaded");
  }

  bool isNumeric(String? lastcharac) {
    return double.parse(lastcharac!) != null;
  }

  _scrollListener() {
    if (_controller!.offset >= _controller!.position.maxScrollExtent &&
        !_controller!.position.outOfRange) {
      setState(() {});
    }
    if (_controller!.offset <= _controller!.position.minScrollExtent &&
        !_controller!.position.outOfRange) {
      setState(() {});
    }
  }

  _showcalcprice() {
    Future.delayed(Duration(seconds: 1)).then((value) {
      setState(() {
        calculatedprice = totalprice.toString();
      });
    });
  }
}
