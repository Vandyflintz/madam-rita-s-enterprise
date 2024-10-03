import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'DatabaseHelper.dart';
import 'dart:async';
import 'Utils/chartHelper.dart';
import 'products_model.dart';
import 'home.dart';
import 'dart:io';
import 'dart:math';
import 'dart:math' as math;
import 'dart:io' as Io;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyWeeklySalesCharts());
}

class MyWeeklySalesCharts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Madam Rita\'s Enterprise',
      home: WeeklySalesCharts(title: 'Madam Rita\'s Enterprise'),
    );
  }
}

double totalprice = 0;

Future<List<Products>> fetchavailableproducts() async {
  var dbhelper = DBProvider();
  Future<List<Products>> products = dbhelper.fetchAllProducts();
  return products;
}

class WeeklySalesCharts extends StatefulWidget {
  WeeklySalesCharts({Key? key, this.title, this.shopname, this.location})
      : super(key: key);
  final String? title, shopname, location;

  @override
  _MyChartState createState() => _MyChartState();
}

class _MyChartState extends State<WeeklySalesCharts>
    with TickerProviderStateMixin {
  String? directory;
  var finaldir;
  List files = [];
  String? imgdir, sdata;
  String? searchdate = '', enddate = '', weeknum = '';
  var dbhelper = DBProvider();
  Future<List<Products>>? productss;
  Future? _future;
  bool _prodvisible = false, _isenabled = false;
  String? dateinwords = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SnackBar? snackBar;
  Products? sproducts;
  List<Salesdata> chartdata = [];
  final formattedval = new NumberFormat("#,##0.00", "en_US");
  //List<charts.Series<Salesdata, String>> series;
  Color primarycolor = Colors.grey;
  SharedPreferences? sharedpref;
  String? _user = '';
  TransformationController _controller = TransformationController();
  @override
  void initState() {
    super.initState();
    loadfile();
    initializesharedpref();
//fetchdataasjson();
    _controller.value = matrix;
    if (searchdate?.isEmpty ?? true && enddate!.isEmpty ?? true) {
      var start = DateTime.now().weekday;
      String? date = DateTime.now().toString();
      String? firstday = date.substring(0, 7) + '01' + date.substring(10);
      int weekDay = DateTime.parse(firstday).weekday;
      int currentweek;
      if (weekDay == 7) {
        currentweek = (DateTime.now().day / 7).ceil();
      } else {
        currentweek = ((DateTime.now().day + weekDay) / 7).ceil();
      }

      setState(() {
        searchdate = DateFormat('yyyy-MM-dd')
            .format(
                DateTime.now().subtract(Duration(days: DateTime.now().weekday)))
            .toString();

        enddate = DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(searchdate!).add(Duration(days: 6)))
            .toString();

        var fstart = DateFormat('EEEE , MMMM d, yyyy')
            .format(DateTime.tryParse(searchdate!)!)
            .toString();
        var fend = DateFormat('EEEE , MMMM d, yyyy')
            .format(DateTime.tryParse(enddate!)!)
            .toString();
        dateinwords = "Week " +
            currentweek.toString() +
            ": " +
            fstart.toString() +
            "  to  " +
            fend;
      });

      Future.delayed(Duration(seconds: 0)).then((evalue) {
        dbhelper
            .fetcharraysoldProducts(
                searchdate, enddate, "weekly", widget.shopname, widget.location)
            .then((final String? value) {
          if (!value!.contains("emptydata")) {
// showsnackbar(value, "Okay");
            Future.delayed(Duration(seconds: 0)).then((evalue) {
              setState(() {
                sdata = value;
                _prodvisible = false;
              });
            });
          } else {
            Future.delayed(Duration(seconds: 0)).then((value) {
              setState(() {
                _prodvisible = true;
                sdata = null;
              });
            });
          }
          Future.delayed(Duration(seconds: 1)).then((evalue) {
            setState(() {
              _future = loadsalesdata();
            });
          });

          Future.delayed(Duration(seconds: 1)).then((value) {
//loadsalesdata();
          });
        }).catchError((error) {
          showsnackbar(error, "Okay");
        });
      });
    }
  }

  int numofweeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayofDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayofDec28 - dec28.weekday + 10) / 7).floor();
  }

  initializesharedpref() async {
    sharedpref = await SharedPreferences.getInstance();
    _user = sharedpref!.getString('user');
    // widget.shopname, widget.location = sharedpref.getString('shopname');
  }

  fetchdataasjson() {
    dbhelper
        .fetcharraysoldProducts(
            searchdate, "", "weekly", widget.shopname, widget.location)
        .then((final String? value) {
      showsnackbar(value, "Okay");

      String? regex = "\\[|\\]";

      String? finalval = value.toString().replaceAll(new RegExp(regex), '');
      final jsonresponse = json.decode(finalval);
      showsnackbar(jsonresponse, "ok");
      setState(() {
        for (Map<String, dynamic>  i in jsonresponse) {
          chartdata.add(Salesdata.fromJson(i));
        }
      });

//loadsalesdata(value);
    }).catchError((error) {
      showsnackbar(error, "Okay");
    });
  }

  loadsalesdata() async {
    Iterable data = json.decode(sdata!);
    List<dynamic> list = data.toList();
    return list;
  }


  List<List<double>> cseries(List<dynamic> apiData, List<String> xUserLabels, List<String> dataRowsLegends, List<Color> colors) {
    List<Salesdata> list = [];
    List<double> data = [];

    // Generate a random color for the bars
    var r = () => Random().nextInt(256) >> 0;
    var color = Color.fromRGBO(
      int.tryParse('${r()}') ?? 0,
      int.tryParse('${r()}') ?? 0,
      int.tryParse('${r()}') ?? 0,
      1,
    );

    for (var i = 0; i < apiData.length; i++) {
      list.add(Salesdata(
          apiData[i]['product_name'],
          apiData[i]['product_size'],
          apiData[i]['totalproducts'],
          double.tryParse(apiData[i]['price'])!,
          apiData[i]['date_sold'],
          apiData[i]['shopname'],
          apiData[i]['location']));
    }

    // Populate xUserLabels, dataRowsLegends, and colors
    xUserLabels.clear();
    dataRowsLegends.clear();
    colors.clear();

    for (var item in list) {
      xUserLabels.add('${item.productname} (${item.productsize}) - ${item.datesold}');
      data.add(item.price);
      colors.add(color); // Adding the generated color for each bar
    }

    return [
      data,
    ];
  }

  void showsnackbar(String? _message, String? _command) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    snackBar = SnackBar(
      duration: const Duration(minutes: 5),
      content: Text(_message!),
      action: SnackBarAction(
        label: _command!,
        onPressed: () {},
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar!);
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
  List<String> xUserLabels = [];
  List<String> dataRowsLegends = [];
  List<Color> colors = [
    Colors.red,
    Colors.indigo,
    Colors.amber,
    Colors.blue,
    Colors.pink[900]!,
    Colors.blueGrey,
    Colors.brown,
    Colors.deepPurple,
    Colors.deepOrange,
    Colors.yellow
  ];

  Matrix4 matrix = Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    double devicewidth = MediaQuery.of(context).size.width,
        deviceheight = MediaQuery.of(context).size.height,
        navwidth;
    List<List<double>> dataRows = cseries(chartdata, xUserLabels, dataRowsLegends, colors);

    if (devicewidth > 600) {
// gridsize = 3;
    } else {
// gridsize = 2;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
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
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      FutureBuilder(
                        future: _future,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          Widget chartcon;
                          if (snapshot.hasData) {
                            double wid, exp;

                            if (snapshot.data.length < 7) {
                              wid = (snapshot.data.length * 79).toDouble();
                              exp = 130;
                            } else {
                              wid = (snapshot.data.length * 67).toDouble();
                              exp = 170;
                            }

                            chartcon = SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: InteractiveViewer(
                                transformationController: _controller,
                                onInteractionUpdate: (ScaleUpdateDetails details) {
                                  setState(() {
                                    // Update the transformation matrix using scale and translation
                                    matrix = _controller.value;

                                    // Extract translation, scale, and rotation from details and update matrix
                                    Matrix4 translationDeltaMatrix = Matrix4.translationValues(
                                      details.focalPointDelta.dx,
                                      details.focalPointDelta.dy,
                                      0,
                                    );
                                    Matrix4 scaleDeltaMatrix = Matrix4.diagonal3Values(
                                      details.scale,
                                      details.scale,
                                      1,
                                    );
                                    matrix = matrix * translationDeltaMatrix * scaleDeltaMatrix;
                                  });
                                },
                                child: Transform(
                                  transform: matrix,
                                  child: Container(
                                    margin: EdgeInsets.only(top: 125),
                                    padding: EdgeInsets.only(
                                        top: 10,
                                        left: 10,
                                        bottom: 10,
                                        right: 60),
                                    width: wid + exp,
                                    child: Container(
                                      width: wid,
                                      child: Card(
                                        color: Colors.white.withOpacity(.15),
                                        elevation: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0,
                                              top: 8.0,
                                              bottom: 8.0,
                                              right: 25.0),
                                          child: MyBarChart(
                                            dataRows: dataRows,
                                            xUserLabels: xUserLabels,
                                            dataRowsLegends: dataRowsLegends,
                                            colors: colors,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            chartcon =
                                Center(child: CircularProgressIndicator());
                          }

                          return chartcon;
                        },
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
                              'No data found for product sold.',
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.0,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 30,
                              padding: EdgeInsets.all(5.0),
                              color: Colors.black.withOpacity(.8),
                              child: Text(
                                'Weekly Sales Record For:',
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.0,
                                    color: Colors.white),
                              ),
                            ),
                            Container(
                              height: 70,
                              decoration: new BoxDecoration(
                                  image: new DecorationImage(
                                image:
                                    new ExactAssetImage('assets/images/bg.png'),
                                fit: BoxFit.fill,
                              )),
                              child: ClipRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 7.0,
                                    sigmaY: 7.0,
                                  ),
                                  child: Container(
                                    height: 70,
                                    padding: EdgeInsets.all(10.0),
                                    decoration: new BoxDecoration(
                                        color: Colors.black.withOpacity(0.4)),
                                    child: Theme(
                                      data: new ThemeData(
                                        brightness: Brightness.dark,
                                        primarySwatch: Colors.pink,
                                        inputDecorationTheme:
                                            new InputDecorationTheme(
                                          labelStyle: new TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: RawMaterialButton(
                                              shape: CircleBorder(),
                                              onPressed: () {
                                                _movetopreviousweek(searchdate);
                                              },
                                              elevation: 4.0,
                                              fillColor: Colors.pink[900]!
                                                  .withOpacity(0.4),
                                              child: IconButton(
                                                  icon: Padding(
                                                      padding:
                                                          EdgeInsets.all(3),
                                                      child: Icon(Icons
                                                          .arrow_back_rounded)),
                                                  onPressed: () {
                                                    _movetopreviousweek(
                                                        searchdate);
                                                  }),
                                            ),
                                          ),
                                          Expanded(
                                            child: IconButton(
                                                icon: Padding(
                                                  padding: EdgeInsets.all(3),
                                                  child: Icon(
                                                    Icons.home_rounded,
                                                    size: 35,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  _jumptocurrentweek(
                                                      searchdate);
                                                }),
                                          ),
                                          Expanded(
                                            child: RawMaterialButton(
                                              shape: CircleBorder(),
                                              onPressed: () async {
                                                if (_isenabled) {
                                                  _movetonextweek(searchdate);
                                                }
                                              },
                                              elevation: 4.0,
                                              fillColor: primarycolor,
                                              child: IconButton(
                                                  icon: Padding(
                                                    padding: EdgeInsets.all(3),
                                                    child: Icon(Icons
                                                        .arrow_forward_rounded),
                                                  ),
                                                  onPressed: () async {
                                                    _movetonextweek(searchdate);
                                                  }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(5.0),
                              color: Colors.black.withOpacity(.8),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  height: 21,
                                  child: Text(
                                    dateinwords!,
                                    textAlign: TextAlign.center,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.0,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  getfile(String? imgdir, String? name) {
    String? lastcharac = name!.substring(name.length - 1);
    if (!isNumeric(lastcharac)) {
      return Image.file(File(imgdir! + name + ".jpg"));
    } else {
      return Image.asset(
        'assets/images/pic.png',
      );
    }
  }

  bool isNumeric(String? lastcharac) {
    return double.parse(lastcharac!) != null;
  }

  _jumptocurrentweek(String? sdate) {
    // showsnackbar(sdate, "Okay");
    String? date = DateTime.now().toString();
    String? firstday = date.substring(0, 7) + '01' + date.substring(10);
    int weekDay = DateTime.parse(firstday).weekday;
    int currentweek;
    if (weekDay == 7) {
      currentweek = (DateTime.now().day / 7).ceil();
    } else {
      currentweek = ((DateTime.now().day + weekDay) / 7).ceil();
    }

    setState(() {
      primarycolor = Colors.grey;
      _isenabled = false;
      searchdate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(
              Duration(days: DateTime.daysPerWeek - DateTime.now().weekday)))
          .toString();

      enddate = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(searchdate!).add(Duration(days: 6)))
          .toString();

      var fstart = DateFormat('EEEE , MMMM d, yyyy')
          .format(DateTime.tryParse(searchdate!)!)
          .toString();
      var fend = DateFormat('EEEE , MMMM d, yyyy')
          .format(DateTime.tryParse(enddate!)!)
          .toString();
      dateinwords = "Week " +
          currentweek.toString() +
          ": " +
          fstart.toString() +
          "  to  " +
          fend;
    });

    Future.delayed(Duration(seconds: 0)).then((evalue) {
      dbhelper
          .fetcharraysoldProducts(
              searchdate, enddate, "weekly", widget.shopname, widget.location)
          .then((final String? value) {
        if (!value!.contains("emptydata")) {
          // showsnackbar(value, "Okay");
          Future.delayed(Duration(seconds: 0)).then((evalue) {
            setState(() {
              sdata = value;
              _prodvisible = false;
            });
          });
        } else {
          Future.delayed(Duration(seconds: 0)).then((value) {
            setState(() {
              _prodvisible = true;
              sdata = null;
            });
          });
        }
        Future.delayed(Duration(seconds: 1)).then((evalue) {
          setState(() {
            _future = loadsalesdata();
          });
        });

        Future.delayed(Duration(seconds: 1)).then((value) {
          //loadsalesdata();
        });
      }).catchError((error) {
        showsnackbar(error, "Okay");
      });
    });
  }

  _movetonextweek(String? odate) async {
    //showsnackbar(odate, "Okay");
    String? date = DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(odate!).add(Duration(days: 7)))
        .toString();

    if (DateTime.parse(date).compareTo(DateTime.now()) > 0) {
      setState(() {
        primarycolor = Colors.grey;
        _isenabled = false;
      });
    } else {
      String? firstday = date.substring(0, 7) + '01' + date.substring(10);
      int weekDay = DateTime.parse(firstday).weekday;
      int currentweek;
      if (weekDay == 7) {
        currentweek = (DateTime.parse(date).day / 7).ceil();
      } else {
        currentweek = ((DateTime.parse(date).day + weekDay) / 7).ceil();
      }

      setState(() {
        if (currentweek > 4) {
          currentweek = 1;
        } else {
          currentweek = currentweek;
        }
        searchdate = date;
        if (DateTime.parse(searchdate!).compareTo(DateTime.now()) > 0) {
          primarycolor = Colors.grey;
          _isenabled = false;
        }
        enddate = DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(searchdate!).add(Duration(days: 6)))
            .toString();

        var fstart = DateFormat('EEEE , MMMM d, yyyy')
            .format(DateTime.tryParse(searchdate!)!)
            .toString();
        var fend = DateFormat('EEEE , MMMM d, yyyy')
            .format(DateTime.tryParse(enddate!)!)
            .toString();
        dateinwords = "Week " +
            currentweek.toString() +
            ": " +
            fstart.toString() +
            "  to  " +
            fend;
      });

      Future.delayed(Duration(seconds: 0)).then((evalue) {
        dbhelper
            .fetcharraysoldProducts(
                searchdate, enddate, "weekly", widget.shopname, widget.location)
            .then((final String? value) {
          if (!value!.contains("emptydata")) {
            // showsnackbar(value, "Okay");
            Future.delayed(Duration(seconds: 0)).then((evalue) {
              setState(() {
                sdata = value;
                _prodvisible = false;
              });
            });
          } else {
            Future.delayed(Duration(seconds: 0)).then((value) {
              setState(() {
                _prodvisible = true;
                sdata = null;
              });
            });
          }
          Future.delayed(Duration(seconds: 1)).then((evalue) {
            setState(() {
              _future = loadsalesdata();
            });
          });

          Future.delayed(Duration(seconds: 1)).then((value) {
            //loadsalesdata();
          });
        }).catchError((error) {
          showsnackbar(error, "Okay");
        });
      });
    }
  }

  _movetopreviousweek(String? odate) async {
    //showsnackbar(odate, "Okay");
    String? date = DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(odate!).subtract(Duration(days: 7)))
        .toString();
    String? firstday = date.substring(0, 7) + '01' + date.substring(10);
    int weekDay = DateTime.parse(firstday).weekday;
    int currentweek;
    if (weekDay == 7) {
      currentweek = (DateTime.parse(date).day / 7).ceil();
    } else {
      currentweek = ((DateTime.parse(date).day + weekDay) / 7).ceil();
    }

    setState(() {
      primarycolor = Colors.pink[900]!.withOpacity(0.4);
      _isenabled = true;
      if (currentweek > 4) {
        currentweek = 1;
      } else {
        currentweek = currentweek;
      }
      searchdate = date;

      enddate = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(searchdate!).add(Duration(days: 6)))
          .toString();

      var fstart = DateFormat('EEEE , MMMM d, yyyy')
          .format(DateTime.tryParse(searchdate!)!)
          .toString();
      var fend = DateFormat('EEEE , MMMM d, yyyy')
          .format(DateTime.tryParse(enddate!)!)
          .toString();
      dateinwords = "Week " +
          currentweek.toString() +
          ": " +
          fstart.toString() +
          "  to  " +
          fend;
    });

    Future.delayed(Duration(seconds: 0)).then((evalue) {
      dbhelper
          .fetcharraysoldProducts(
              searchdate, enddate, "weekly", widget.shopname, widget.location)
          .then((final String? value) {
        if (!value!.contains("emptydata")) {
          // showsnackbar(value, "Okay");
          Future.delayed(Duration(seconds: 0)).then((evalue) {
            setState(() {
              sdata = value;
              _prodvisible = false;
            });
          });
        } else {
          Future.delayed(Duration(seconds: 0)).then((value) {
            setState(() {
              _prodvisible = true;
              sdata = null;
            });
          });
        }
        Future.delayed(Duration(seconds: 1)).then((evalue) {
          setState(() {
            _future = loadsalesdata();
          });
        });

        Future.delayed(Duration(seconds: 1)).then((value) {
          //loadsalesdata();
        });
      }).catchError((error) {
        showsnackbar(error, "Okay");
      });
    });
  }
}
