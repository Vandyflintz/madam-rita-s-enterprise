import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'DatabaseHelper.dart';
import 'dart:async';
import 'Utils/chartHelper.dart';
import 'Utils/customfunctions.dart';
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
//import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_charts/flutter_charts.dart';
import 'package:shared_preferences/shared_preferences.dart';


/*
void main() {
  runApp(MyDailySalesCharts());
}

class MyDailySalesCharts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Madam Rita\'s Enterprise',
      home: DailySalesCharts(title: 'Madam Rita\'s Enterprise'),
    );
  }
}
*/


double? totalprice;

Future<List<Products>> fetchavailableproducts() async {
  var dbhelper = DBProvider();
  Future<List<Products>> products = dbhelper.fetchAllProducts();
  return products;
}

class DailySalesCharts extends StatefulWidget {
  DailySalesCharts({required Key key, required this.title, required this.shopname, required this.location})
      : super(key: key);
  final String? title, shopname, location;

  @override
  _MyChartState createState() => _MyChartState();
}

class _MyChartState extends State<DailySalesCharts>
    with TickerProviderStateMixin {
  String? directory;
  var finaldir;
  List files = [];
  String? imgdir = '', sdata = '';
  String? searchdate = '';
  var dbhelper = DBProvider();
  Future<List<Products>>? productss;
  Future? _future;
  bool _prodvisible = false;
  final formattedval = new NumberFormat("#,##0.00", "en_US");
  String? dateinwords = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SnackBar? snackBar;
  Products? sproducts;
  List<Salesdata> chartdata = [];
  //List<charts.Series<Salesdata, String>>? series;
  List<String> xUserLabels = [];
  List<String> dataRowsLegends = [];
  //List<Color> colors = [];
  SharedPreferences? sharedpref;
  String? _user = '';


  @override
  void initState() {
    super.initState();
    loadfile();
    initializesharedpref();
    //fetchdataasjson();

    if (searchdate?.isEmpty ?? true) {
      searchdate = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();

      setState(() {
        _textEditingController.text = searchdate!;
        dateinwords =
            DateFormat('EEEE , MMMM d, yyyy').format(DateTime.now()).toString();
      });

      Future.delayed(Duration(seconds: 0)).then((evalue) {
        dbhelper
            .fetcharraysoldProducts(
                searchdate, "", "daily", widget.shopname, widget.location)
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
                sdata = '';
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
          showsnackbar(error, "Okay",context);
        });
      });
    }
  }

  initializesharedpref() async {
    sharedpref = await SharedPreferences.getInstance();
    _user = sharedpref!.getString('user')!;
  }

  fetchdataasjson() {
    dbhelper
        .fetcharraysoldProducts(
            searchdate, "", "daily", widget.shopname, widget.location)
        .then((final String? value) {
      showsnackbar(value, "Okay", context);

      String? regex = "\\[|\\]";

      String? finalval = value.toString().replaceAll(new RegExp(regex), '');
      final jsonresponse = json.decode(finalval);
      showsnackbar(jsonresponse, "ok", context);
      setState(() {
        for (Map<String, dynamic> i in jsonresponse) {
          chartdata.add(Salesdata.fromJson(i));
        }
      });

      //loadsalesdata(value);
    }).catchError((error) {
      showsnackbar(error, "Okay", context);
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


/*
  List<List<double>> cseries(List<dynamic> apiData, List<String> xUserLabels, List<String> dataRowsLegends, List<Color> colors) {
    List<List<double>> dataRows = [];

    for (var i = 0; i < apiData.length; i++) {
      Salesdata data = Salesdata(
        apiData[i]['product_name'],
        apiData[i]['product_size'],
        apiData[i]['totalproducts'],
        double.tryParse(apiData[i]['price'])!,
        apiData[i]['date_sold'],
        apiData[i]['shopname'],
        apiData[i]['location'],
      );

      xUserLabels.add('${data.productname} (${data.productsize})');
      dataRows.add([data.price]);
      dataRowsLegends.add(data.datesold);

      // Generate a random color for each entry
      var r = () => Random().nextInt(256);
      colors.add(Color.fromRGBO(r(), r(), r(), 1.0));
    }

    return dataRows;
  }
  */
/*
  static List<charts.Series<Salesdata, String>> cseries(List<dynamic> apiData) {
    List<Salesdata> list = [];
    var r = () => Random().nextInt(256) >> 0;
    var color = Color.fromRGBO(
      int.tryParse('${r()}') ?? 0,
      int.tryParse('${r()}') ?? 0,
      int.tryParse('${r()}') ?? 0,
      1,
    );

    for (var i = 0; i < apiData.length; i++)
      list.add(new Salesdata(
          apiData[i]['product_name'],
          apiData[i]['product_size'],
          apiData[i]['totalproducts'],
          double.tryParse(apiData[i]['price'])!,
          apiData[i]['date_sold'],
          apiData[i]['shopname'],
          apiData[i]['location']));
    return [
      charts.Series(
          data: list,
          id: "Products Sold",
          domainFn: (Salesdata series, _) =>
              series.productname + ' (' + series.productsize + ')',
          measureFn: (Salesdata series, _) => series.price,
          labelAccessorFn: (Salesdata row, _) => '${row.datesold}',
          colorFn: (Salesdata series, _) => charts.Color.fromHex(
              code:
                  "#${Colors.primaries[math.Random().nextInt(Colors.primaries.length)].value}"))
    ];
  }
  */



  TextEditingController _textEditingController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  DateTime? _selectedDate;

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

    if (newSelectedDate != null && newSelectedDate != _selectedDate) {
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
        //EEEE , MMMM d, YYYY
        var formatteddate = "${newSelectedDate.year}-${month}-${day}";
        searchdate = formatteddate.toString();
        dateinwords = DateFormat('EEEE , MMMM d, yyyy')
            .format(newSelectedDate)
            .toString();
        _textEditingController.text = formatteddate;
      });

      Future.delayed(Duration(seconds: 0)).then((value) {
        dbhelper
            .fetcharraysoldProducts(
                searchdate, "", "daily", widget.shopname, widget.location)
            .then((final String? value) {
          if (!value!.contains("emptydata")) {
            Future.delayed(Duration(seconds: 0)).then((evalue) {
              setState(() {
                sdata = value;
                _prodvisible = false;
              });
            });
          } else {
            Future.delayed(Duration(seconds: 0)).then((value) {
              setState(() {
                sdata = "";
                _prodvisible = true;
              });
            });
          }

          Future.delayed(Duration(seconds: 0)).then((evalue) {
            _future = loadsalesdata();
          });

          Future.delayed(Duration(seconds: 1)).then((value) {
            //loadsalesdata();
          });
        }).catchError((error) {
          showsnackbar(error, "Okay", context);
        });
      });
    }
  }

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

  FocusNode focusnode = FocusNode();

  @override
  Widget build(BuildContext context) {
    double devicewidth = MediaQuery.of(context).size.width,
        deviceheight = MediaQuery.of(context).size.height,
        navwidth;
    /*series = [
      charts.Series(
        data: chartdata,
        id: "Products Sold",
        domainFn: (Salesdata series, _) => series.productname,
        measureFn: (Salesdata series, _) => series.price,
      )
    ];*/

    List<List<double>> dataRows = cseries(chartdata, xUserLabels, dataRowsLegends, colors);
    if (devicewidth > 600) {
      // gridsize = 3;
    } else {
      // gridsize = 2;
    }

    return Scaffold(
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
                              child: Container(
                                margin: EdgeInsets.only(top: 125),
                                padding: EdgeInsets.only(
                                    top: 10, left: 10, bottom: 10, right: 60),
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
                                      child:

                                      MyBarChart(
                                        dataRows: dataRows,
                                        xUserLabels: xUserLabels,
                                        dataRowsLegends: dataRowsLegends,
                                        colors: colors,
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
                                'Daily Sales Record For:',
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
                                    padding: EdgeInsets.all(7.0),
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
                                      child: TextFormField(
                                        controller: _textEditingController,
                                        decoration: InputDecoration(
                                          labelText: 'Current Date',
                                          prefixIcon: IconButton(
                                              icon: Padding(
                                                padding: EdgeInsets.all(3),
                                                child:
                                                    Icon(Icons.calendar_today),
                                              ),
                                              onPressed: () async {
                                                focusnode.unfocus();
                                                focusnode.canRequestFocus =
                                                    false;
                                                await _selectDate(context);
                                              }),
                                          suffixIcon: IconButton(
                                              icon: Padding(
                                                padding: EdgeInsets.all(3),
                                                child: Icon(Icons.home),
                                              ),
                                              onPressed: () async {
                                                focusnode.unfocus();
                                                focusnode.canRequestFocus =
                                                    false;
                                                await _jumptodate();
                                              }),
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
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 30,
                              padding: EdgeInsets.all(5.0),
                              color: Colors.black.withOpacity(.8),
                              child: Text(
                                dateinwords!,
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.0,
                                    color: Colors.white),
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
    try {
      double.parse(lastcharac!);
      return true;
    } catch (e) {
      return false;
    }
  }


  _jumptodate() async {
    setState(() {
      _selectedDate = DateTime.now();
      searchdate = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
      _textEditingController.text = searchdate!;
      dateinwords =
          DateFormat('EEEE , MMMM d, yyyy').format(DateTime.now()).toString();
    });

    Future.delayed(Duration(seconds: 0)).then((evalue) {
      dbhelper
          .fetcharraysoldProducts(
              searchdate, "", "daily", widget.shopname, widget.location)
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
              sdata = "";
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
        showsnackbar(error, "Okay", context);
      });
    });
  }
}
