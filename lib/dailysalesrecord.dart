import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

/*
void main() {
  runApp(MyDailySalesRecords());
}

class MyDailySalesRecords extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Madam Rita\'s Enterprise',
      home: DailySalesRecords(title: 'Madam Rita\'s Enterprise'),
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

class DailySalesRecords extends StatefulWidget {
  DailySalesRecords(
      {required Key key,
      required this.title,
      required this.shopname,
      required this.location})
      : super(key: key);
  final String? title, shopname, location;

  @override
  _MyChartState createState() => _MyChartState();
}

class _MyChartState extends State<DailySalesRecords>
    with TickerProviderStateMixin {
  String? directory;
  var finaldir;
  List files = [];
  String? imgdir;
  bool _individualsalesvisible = false,
      _workerssalesvisible = false,
      _soldvisible = true,
      _innersalesvisible = false;
  String? searchdate = '', dateinwords = '';
  ScrollController? _controller;
  String? calculatedprice = '';
  final formattedval = new NumberFormat("#,##0.00", "en_US");
  Future<List<SoldProducts>>? _individualworkerfuture;
  Future<List<SoldProducts>>? _individualfuture, _future;

  Future<List<Workers>>? _workersfuture;
  bool _prodvisible = false,
      _pricevisible = false,
      _indworkerssalesvisible = false,
      _indprodvisible = false;
  Icon _searchIcon = new Icon(Icons.search);
  Icon _clearIcon = new Icon(Icons.clear_all);
  Widget _appBarTitle = new Text('Search for products here');
  SharedPreferences? sharedpref;
  double btmMargin = 130;
  bool _datevisibility = true, boolTrue = true;
  String? _user = '', user = '';
  double? _individualprice, _individualworkerprice, _generalworkerprice;

  @override
  void initState() {
    super.initState();
    loadfile();
    initializesharedpref();
    Future.delayed(Duration(seconds: 1)).then((value) {
      _workersfuture!.then((value) {
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
      _future!.then((value) {
        if (value.isNotEmpty) {
          Future.delayed(Duration(seconds: 0)).then((value) {
            setState(() {
              _prodvisible = false;
              _pricevisible = true;
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
      _individualfuture!.then((value) {
        if (value.isNotEmpty) {
          Future.delayed(Duration(seconds: 0)).then((value) {
            setState(() {
              _soldvisible = false;
            });
          });
        } else {
          Future.delayed(Duration(seconds: 0)).then((value) {
            setState(() {
              _soldvisible = true;
            });
          });
        }
      });
    });
    _workersfuture =
        DBProvider().fetchallworkers(widget.shopname, widget.location);
    _showcalcprice();
    if (searchdate?.isEmpty ?? true) {
      searchdate = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();

      setState(() {
        _future = DBProvider().fetchsoldProducts(
            searchdate, "", "daily", widget.shopname, widget.location);
        _individualfuture = DBProvider().fetchindividualsoldProducts(
            searchdate, "", "daily", widget.shopname, widget.location, _user);
        _textEditingController.text = searchdate!;
        dateinwords =
            DateFormat('EEEE , MMMM d, yyyy').format(DateTime.now()).toString();
      });
    }
    _controller = ScrollController();
    _controller!.addListener(_scrollListener);
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      backgroundColor: Colors.pink[900]!.withOpacity(.4),
      title: _appBarTitle,
      leading: new IconButton(
        icon: _searchIcon,
        onPressed: _searchPressed,
      ),
      actions: <Widget>[
        new IconButton(
          icon: _clearIcon,
          onPressed: () {
            setState(() {
              searchdate =
                  DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
              _textEditingController.text = searchdate!;
              dateinwords = DateFormat('EEEE , MMMM d, yyyy')
                  .format(DateTime.now())
                  .toString();
              _selectedDate = DateTime.now();
              _future = DBProvider().fetchsoldProducts(
                  searchdate, "", "daily", widget.shopname, widget.location);
              _individualfuture = DBProvider().fetchindividualsoldProducts(
                  searchdate,
                  "",
                  "daily",
                  widget.shopname,
                  widget.location,
                  _user);
            });
            Future.delayed(Duration(seconds: 0)).then((value) {
              _future!.then((value) {
                if (value.isNotEmpty) {
                  Future.delayed(Duration(seconds: 0)).then((value) {
                    setState(() {
                      _prodvisible = false;
                      _pricevisible = true;
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
              _individualfuture!.then((value) {
                if (value.isNotEmpty) {
                  Future.delayed(Duration(seconds: 0)).then((value) {
                    setState(() {
                      _soldvisible = false;
                    });
                  });
                } else {
                  Future.delayed(Duration(seconds: 0)).then((value) {
                    setState(() {
                      _soldvisible = true;
                      _individualsalesvisible = false;
                    });
                  });
                }
              });
            });
          },
        )
      ],
    );
  }

  initializesharedpref() async {
    sharedpref = await SharedPreferences.getInstance();
    _user = sharedpref!.getString('user')!;
  }

  String? userid = '';

  _showsalesdialog(String? user, String? image) {
    _individualworkerfuture = DBProvider().fetchindividualsoldProducts(
        searchdate, "", "daily", widget.shopname, widget.location, user);

    var cbody = Container(
      child: Stack(
        children: [
          Container(
            height: 60,
            padding: EdgeInsets.only(left: 5, top: 9, bottom: 9),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(70),
                      border: Border.all(
                          width: 3, color: Colors.white.withOpacity(1)),
                      image: DecorationImage(
                          fit: BoxFit.fill, image: getnfile(imgdir!, image))),
                ),
                Padding(padding: EdgeInsets.only(right: 10)),
                Text(
                  user!,
                  textAlign: TextAlign.left,
                  style: new TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18.0,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 60),
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 15),
            height: 50,
            color: Colors.pink[900],
            child: Text(
              'Amount of items sold : GH¢ ' + _individualworkerprice.toString(),
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0,
                  color: Colors.white),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 115),
            height: 50,
            padding: EdgeInsets.all(10),
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
              child: new TextField(
                onSubmitted: (value) {
                  setState(() {
                    _individualworkerfuture = DBProvider()
                        .fetchindividualworkersearchedsoldProducts(
                            searchdate,
                            "",
                            "daily",
                            value,
                            widget.shopname,
                            widget.location,
                            user);
                  });
                  Future.delayed(Duration(seconds: 0)).then((value) {
                    _individualworkerfuture!.then((value) {
                      if (value.isNotEmpty) {
                        Future.delayed(Duration(seconds: 0)).then((value) {
                          setState(() {
                            _innersalesvisible = false;
                          });
                        });
                      } else {
                        Future.delayed(Duration(seconds: 0)).then((value) {
                          setState(() {
                            _innersalesvisible = true;
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
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 160, bottom: 60),
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(20),
            color: Colors.black.withOpacity(.7),
            child: new FutureBuilder<List<SoldProducts>>(
              future: _individualworkerfuture,
              builder: (BuildContext context,
                  AsyncSnapshot<List<SoldProducts>> snapshot) {
                Widget newsListSliver;
                if (snapshot.hasData) {
                  newsListSliver = CustomScrollView(
                    slivers: [
                      SliverGrid(
                        gridDelegate: SliverWovenGridDelegate.count(
                          crossAxisCount: 2, // Adjust according to your layout needs
                          mainAxisSpacing: MediaQuery.of(context).size.width * 0.07,
                          crossAxisSpacing: MediaQuery.of(context).size.width * 0.07,
                          pattern: [
                            WovenGridTile(1), // Full width for one tile
                            WovenGridTile(
                              5 / 7,
                              crossAxisRatio: 0.9,
                              alignment: AlignmentDirectional.centerEnd,
                            ),
                          ],
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                            SoldProducts item = snapshot.data![index];

                            List<String> itemPricesList = [];
                            for (int i = 0; i < snapshot.data!.length; i++) {
                              itemPricesList.add(snapshot.data![i].price!);
                            }

                            Future.delayed(Duration(seconds: 1)).then((value) {
                              setState(() {
                                _individualworkerprice = itemPricesList.fold(
                                  0,
                                      (previousValue, element) =>
                                  previousValue! + (double.tryParse(element ?? '0') ?? 0),
                                );
                              });
                            });

                            return Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(0, 0, 20, .4),
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(.8),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "${item.name!} (${item.size!})",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.white.withOpacity(.4),
                                      height: 1,
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(15.0),
                                      height: MediaQuery.of(context).size.width * 0.3,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15.0),
                                        child: getfile(imgdir!, item.name),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.white.withOpacity(.4),
                                      height: 1,
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "Qty : ${item.prodid!}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.white.withOpacity(.4),
                                      height: 1,
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "Amt : GH¢ ${double.parse(item.price!).toString()}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: snapshot.data!.length,
                        ),
                      ),
                    ],
                  );
                  ;

                  /*
                      SliverStairedGridDelegate(
                    itemCount: snapshot.data!.length,
                    crossAxisCount: 4,
                    staggeredTileBuilder: (int index) =>
                        new StaggeredTile.fit(2),
                    mainAxisSpacing: MediaQuery.of(context).size.width * 0.07,
                    crossAxisSpacing: MediaQuery.of(context).size.width * 0.07,
                    itemBuilder: (BuildContext context, int index) {
                      SoldProducts item = snapshot.data![index];

                      List<String> itempriceslist = [];
                      for (int i = 0; i < snapshot.data!.length; i++) {
                        itempriceslist.add(snapshot.data![i].price);
                      }
                      double calcprice;
                      Future.delayed(Duration(seconds: 1)).then((value) {
                        setState(() {
                          _individualworkerprice = itempriceslist.fold(
                              0,
                              (previousValue, element) =>
                                  previousValue! +
                                  (double.tryParse(element ?? '0') ?? 0));
                        });
                      });

                      return Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(0, 0, 20, .4),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          border: Border.all(
                            color: Colors.grey.withOpacity(.8),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(5),
                                child: new Text(
                                  item.name + " (" + item.size + ")",
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14.0,
                                      color: Colors.white),
                                ),
                              ),
                              Divider(
                                color: Colors.white.withOpacity(.4),
                                height: 1,
                              ),
                              Container(
                                padding: EdgeInsets.all(15.0),
                                height: MediaQuery.of(context).size.width * 0.3,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: getfile(imgdir!, item.name),
                                ),
                              ),
                              Divider(
                                color: Colors.white.withOpacity(.4),
                                height: 1,
                              ),
                              Container(
                                padding: EdgeInsets.all(5),
                                child: new Text(
                                  "Qty : " + item.prodid,
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14.0,
                                      color: Colors.white),
                                ),
                              ),
                              Divider(
                                color: Colors.white.withOpacity(.4),
                                height: 1,
                              ),
                              Container(
                                padding: EdgeInsets.all(5),
                                child: new Text(
                                  "Amt : GH¢ " +
                                      double.parse(item.price).toString(),
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14.0,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, pattern: [
                    StairedGridTile(2, 2),
                  ],
                  )*/
                  ;
                } else {
                  newsListSliver = SliverToBoxAdapter(
                    child: CircularProgressIndicator(),
                  );
                }

                return CustomScrollView(
                  primary: false,
                  slivers: <Widget>[newsListSliver],
                );
              },
            ),
          ),
          Visibility(
            visible: _innersalesvisible,
            child: Center(
              child: Text(
                "No products sold on this day",
                textAlign: TextAlign.center,
                style: new TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0,
                    color: Colors.white),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              height: 50,
              color: Colors.black.withOpacity(.8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: FractionallySizedBox(
                      widthFactor: 0.50,
                      child: new ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                                color: Color.fromRGBO(0, 0, 0, 0.09), width: 3),
                          ),
                          backgroundColor: Colors.pink[900],
                          textStyle:
                              TextStyle(color: Colors.white), // Text color
                        ),
                        child: Text(
                          "Close",
                          style: TextStyle(fontSize: 15),
                        ),
                        onPressed: () {
                          _individualworkerfuture = null;
                          _individualworkerprice = 0;
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: FractionallySizedBox(
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
                          backgroundColor: Colors
                              .pink[900], // Updated button background color
                        ),
                        child: Text(
                          "Clear",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white, // Text color using TextStyle
                          ),
                        ),
                        onPressed: () {
                          _individualworkerfuture =
                              DBProvider().fetchindividualsoldProducts(
                            searchdate,
                            "",
                            "daily",
                            widget.shopname,
                            widget.location,
                            user,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                insetPadding: EdgeInsets.all(5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                backgroundColor: Colors.black.withOpacity(.6),
                child: Scaffold(
                  body: Builder(builder: (context) {
                    return Container(
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
                          decoration: new BoxDecoration(
                              color: Colors.black.withOpacity(0.4)),
                          child: cbody,
                        ),
                      ),
                    );
                  }),
                ));
          });
        });
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
              setState(() {
                _future = DBProvider().fetchsearchedsoldProducts(searchdate, "",
                    "daily", value, widget.shopname, widget.location);
                _individualfuture = DBProvider()
                    .fetchindividualsearchedsoldProducts(
                        searchdate,
                        "",
                        "daily",
                        value,
                        widget.shopname,
                        widget.location,
                        _user);
              });
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
                _individualfuture!.then((value) {
                  if (value.isNotEmpty) {
                    Future.delayed(Duration(seconds: 0)).then((value) {
                      setState(() {
                        _soldvisible = false;
                      });
                    });
                  } else {
                    Future.delayed(Duration(seconds: 0)).then((value) {
                      setState(() {
                        _soldvisible = true;
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
        //EEEE , MMMM d, YYYY
        var formatteddate = "${newSelectedDate.year}-${month}-${day}";
        searchdate = formatteddate.toString();
        dateinwords = DateFormat('EEEE , MMMM d, yyyy')
            .format(newSelectedDate)
            .toString();
        _textEditingController.text = formatteddate;
      });
    Future.delayed(Duration(seconds: 0)).then((value) {
      setState(() {
        _future = DBProvider().fetchsoldProducts(
            searchdate, "", "daily", widget.shopname, widget.location);
        _individualfuture = DBProvider().fetchindividualsoldProducts(
            searchdate, "", "daily", widget.shopname, widget.location, _user);
      });

      Future.delayed(Duration(seconds: 0)).then((value) {
        _future!.then((value) {
          if (value.isNotEmpty) {
            Future.delayed(Duration(seconds: 0)).then((value) {
              setState(() {
                _prodvisible = false;
                _pricevisible = true;
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
        _individualfuture!.then((value) {
          if (value.isNotEmpty) {
            Future.delayed(Duration(seconds: 0)).then((value) {
              setState(() {
                _soldvisible = false;
              });
            });
          } else {
            Future.delayed(Duration(seconds: 0)).then((value) {
              setState(() {
                _soldvisible = true;
              });
            });
          }
        });
      });
    });
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

  @override
  Widget build(BuildContext context) {
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
      appBar: boolTrue ? _buildBar(context) : null,
      body: Center(
        child: Container(
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
                  child: Stack(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: btmMargin),
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.07,
                            right: MediaQuery.of(context).size.width * 0.07,
                            bottom: 80,
                            top: 10),
                        height: MediaQuery.of(context).size.height - btmMargin,
                        child: new FutureBuilder<List<SoldProducts>>(
                          future: _future,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<SoldProducts>> snapshot) {
                            Widget newsListSliver;
                            if (snapshot.hasData) {
                              newsListSliver = SliverGrid(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Set the number of columns
                                  mainAxisSpacing: MediaQuery.of(context).size.width * 0.07,
                                  crossAxisSpacing: MediaQuery.of(context).size.width * 0.07,
                                  childAspectRatio: 5 / 7, // Set an appropriate aspect ratio
                                ),
                                delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                    SoldProducts item = snapshot.data![index];

                                    List<String> itempriceslist = [];
                                    for (int i = 0; i < snapshot.data!.length; i++) {
                                      itempriceslist.add(snapshot.data![i].price!);
                                    }

                                    Future.delayed(Duration(seconds: 1)).then((value) {
                                      setState(() {
                                        totalprice = itempriceslist.fold(
                                            0,
                                                (previousValue, element) =>
                                            previousValue! +
                                                (double.tryParse(element ?? '0') ?? 0));
                                      });
                                    });

                                    return Container(
                                      width: MediaQuery.of(context).size.width * 0.45,
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(0, 0, 20, .4),
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(.8),
                                          width: 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                item.name! + " (" + item.size! + ")",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14.0,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              color: Colors.white.withOpacity(.4),
                                              height: 1,
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(15.0),
                                              height: MediaQuery.of(context).size.width * 0.3,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(15.0),
                                                child: getfile(imgdir, item.name),
                                              ),
                                            ),
                                            Divider(
                                              color: Colors.white.withOpacity(.4),
                                              height: 1,
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                "Qty : " + item.prodid!,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14.0,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              color: Colors.white.withOpacity(.4),
                                              height: 1,
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                "Amt : GH¢ " + double.parse(item.price!).toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14.0,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: snapshot.data!.length,
                                ),
                              );
                              ;
                            } else {
                              newsListSliver = SliverToBoxAdapter(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return CustomScrollView(
                              primary: false,
                              slivers: <Widget>[newsListSliver],
                            );
                          },
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Visibility(
                          visible: _pricevisible,
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.all(15.0),
                            color: Colors.black.withOpacity(.6),
                            child: Text(
                              'Total : GH¢ ' + totalprice.toString(),
                              textAlign: TextAlign.left,
                              style: new TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.0,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 123,
                        bottom: 10,
                        child: Visibility(
                          visible: _pricevisible,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _individualsalesvisible =
                                    !_individualsalesvisible;
                                _workerssalesvisible = false;
                                boolTrue = true;
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.23),
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                      width: 1,
                                      color: Colors.white.withOpacity(.8)),
                                ),
                                padding: EdgeInsets.all(3.0),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 23,
                                )),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 67,
                        bottom: 10,
                        child: Visibility(
                          visible: _pricevisible,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _workerssalesvisible = !_workerssalesvisible;
                                _individualsalesvisible = false;

                                if (boolTrue == true) {
                                  boolTrue = false;
                                } else {
                                  boolTrue = true;
                                }
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.23),
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                      width: 1,
                                      color: Colors.white.withOpacity(.8)),
                                ),
                                padding: EdgeInsets.all(3.0),
                                child: Icon(
                                  Icons.people,
                                  color: Colors.white,
                                  size: 23,
                                )),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Visibility(
                          visible: _pricevisible,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                boolTrue = !boolTrue;
                                _datevisibility = !_datevisibility;
                                if (btmMargin == 130) {
                                  btmMargin = 0;
                                } else {
                                  btmMargin = 130;
                                }
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.23),
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                      width: 1,
                                      color: Colors.white.withOpacity(.8)),
                                ),
                                padding: EdgeInsets.all(3.0),
                                child: Icon(
                                  Icons.toggle_on_rounded,
                                  color: Colors.white,
                                  size: 23,
                                )),
                          ),
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
                        child: AnimatedOpacity(
                          opacity: _datevisibility ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 500),
                          child: Visibility(
                            visible: _datevisibility,
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
                                    image: new ExactAssetImage(
                                        'assets/images/bg.png'),
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
                                            color:
                                                Colors.black.withOpacity(0.4)),
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
                                          child: InkWell(
                                            onTap: () => _selectDate(context),
                                            child: IgnorePointer(
                                              child: TextFormField(
                                                controller:
                                                    _textEditingController,
                                                decoration: InputDecoration(
                                                  labelText: 'Current Date',
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
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 50,
                        child: Visibility(
                          visible: _individualsalesvisible,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.65,
                            color: Colors.black.withOpacity(.8),
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.only(top: 15),
                                  height: 50,
                                  color: Colors.pink[900],
                                  child: Text(
                                    'Items sold by you : GH¢ ' +
                                        _individualprice.toString(),
                                    textAlign: TextAlign.center,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18.0,
                                        color: Colors.white),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(10.0),
                                    child: Stack(children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(
                                            bottom: 80, top: 10),
                                        height:
                                            MediaQuery.of(context).size.height -
                                                btmMargin,
                                        child: new FutureBuilder<
                                            List<SoldProducts>>(
                                          future: _individualfuture,
                                          builder: (BuildContext context,
                                              AsyncSnapshot<List<SoldProducts>>
                                                  snapshot) {
                                            Widget newsListSliver;
                                            if (snapshot.hasData) {
                                              newsListSliver = SliverGrid(
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2, // Two items per row
                                                  mainAxisSpacing: MediaQuery.of(context).size.width * 0.07,
                                                  crossAxisSpacing: MediaQuery.of(context).size.width * 0.07,
                                                  childAspectRatio: 0.7, // Adjust the aspect ratio for the staggered effect
                                                ),
                                                delegate: SliverChildBuilderDelegate(
                                                      (BuildContext context, int index) {
                                                    SoldProducts item = snapshot.data![index];

                                                    List<String> itempriceslist = [];
                                                    for (int i = 0; i < snapshot.data!.length; i++) {
                                                      itempriceslist.add(snapshot.data![i].price!);
                                                    }

                                                    // Calculating individual price
                                                    _individualprice = itempriceslist.fold(
                                                      0,
                                                          (previousValue, element) =>
                                                      previousValue! + (double.tryParse(element ?? '0') ?? 0),
                                                    );

                                                    // Updating the general worker price
                                                    Future.delayed(Duration(seconds: 1)).then((value) {
                                                      setState(() {
                                                        _generalworkerprice = totalprice! - _individualprice!;
                                                      });
                                                    });

                                                    // Rebuilding the UI after delay
                                                    Future.delayed(Duration(seconds: 4)).then((value) {
                                                      setState(() {});
                                                    });

                                                    return Container(
                                                      width: MediaQuery.of(context).size.width * 0.45,
                                                      decoration: BoxDecoration(
                                                        color: Color.fromRGBO(0, 0, 20, .4),
                                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                                        border: Border.all(
                                                          color: Colors.grey.withOpacity(.8),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(15.0),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: <Widget>[
                                                            Container(
                                                              padding: EdgeInsets.all(5),
                                                              child: Text(
                                                                item.name! + " (" + item.size! + ")",
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.w400,
                                                                  fontSize: 14.0,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                            ),
                                                            Divider(
                                                              color: Colors.white.withOpacity(.4),
                                                              height: 1,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(15.0),
                                                              height: MediaQuery.of(context).size.width * 0.3,
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(15.0),
                                                                child: getfile(imgdir, item.name),
                                                              ),
                                                            ),
                                                            Divider(
                                                              color: Colors.white.withOpacity(.4),
                                                              height: 1,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(5),
                                                              child: Text(
                                                                "Qty : " + item.prodid!,
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.w400,
                                                                  fontSize: 14.0,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                            ),
                                                            Divider(
                                                              color: Colors.white.withOpacity(.4),
                                                              height: 1,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(5),
                                                              child: Text(
                                                                "Amt : GH¢ " + double.parse(item.price!).toString(),
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.w400,
                                                                  fontSize: 14.0,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  childCount: snapshot.data!.length,
                                                ),
                                              );
                                              ;
                                              ;
                                            } else {
                                              newsListSliver =
                                                  SliverToBoxAdapter(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }

                                            return CustomScrollView(
                                              primary: false,
                                              slivers: <Widget>[newsListSliver],
                                            );
                                          },
                                        ),
                                      ),
                                      Visibility(
                                        visible: _soldvisible,
                                        child: Center(
                                          child: Text(
                                            'No items sold by you',
                                            textAlign: TextAlign.center,
                                            style: new TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18.0,
                                                color: Colors.white),
                                          ),
                                        ),
                                      )
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 50,
                        child: Visibility(
                          visible: _workerssalesvisible,
                          child: Container(
                            height: (MediaQuery.of(context).size.height) - 170,
                            color: Colors.black.withOpacity(.8),
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.only(top: 15),
                                  height: 50,
                                  color: Colors.pink[900],
                                  child: Text(
                                    'Amount of items sold by workers : GH¢ ' +
                                        _generalworkerprice.toString(),
                                    textAlign: TextAlign.center,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15.0,
                                        color: Colors.white),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(15.0),
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          child:
                                              new FutureBuilder<List<Workers>>(
                                            future: _workersfuture,
                                            builder: (BuildContext context,
                                                AsyncSnapshot<List<Workers>>
                                                    snapshot) {
                                              Widget newsListSliver;
                                              if (snapshot.hasData) {
                                                newsListSliver =
                                                    ListView.builder(
                                                  itemCount:
                                                      snapshot.data!.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    Workers item =
                                                        snapshot.data![index];
                                                    Future.delayed(Duration(
                                                            seconds: 1))
                                                        .then((value) {
                                                      if (mounted) {
                                                        setState(() {});
                                                      }
                                                    });

                                                    return GestureDetector(
                                                      onTap: () {
                                                        _indworkerssalesvisible =
                                                            true;
                                                        _individualworkerprice =
                                                            0;
                                                        user = item.firstname! +
                                                            " " +
                                                            item.lastname!;
                                                        userid = item.worker_id;
                                                        _individualworkerfuture =
                                                            DBProvider().fetchindividualsoldProducts(
                                                                searchdate,
                                                                "",
                                                                "daily",
                                                                widget.shopname,
                                                                widget.location,
                                                                item.firstname! +
                                                                    " " +
                                                                    item.lastname!);
                                                        /* _showsalesdialog(
                                                            item.firstname +
                                                                " " +
                                                                item.lastname,
                                                            item.worker_id);*/
                                                      },
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 15),
                                                        child: Column(
                                                          children: <Widget>[
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 5,
                                                                      top: 9,
                                                                      bottom:
                                                                          9),
                                                              child: Row(
                                                                children: <Widget>[
                                                                  Container(
                                                                    width: 60,
                                                                    height: 60,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                70),
                                                                        border: Border.all(
                                                                            width:
                                                                                3,
                                                                            color: Colors.white.withOpacity(
                                                                                1)),
                                                                        image: DecorationImage(
                                                                            fit:
                                                                                BoxFit.fill,
                                                                            image: getnfile(imgdir, item.worker_id))),
                                                                  ),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(
                                                                          right:
                                                                              5)),
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
                                                                ],
                                                              ),
                                                            ),
                                                            Divider(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      .6),
                                                              height: 3,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              } else {
                                                newsListSliver = Center(
                                                  child:
                                                      CircularProgressIndicator(),
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
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 30,
                                              padding: EdgeInsets.all(5.0),
                                              color:
                                                  Colors.black.withOpacity(.6),
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 50,
                        child: Visibility(
                          visible: _indworkerssalesvisible,
                          child: Container(
                            height: (MediaQuery.of(context).size.height) - 170,
                            color: Color.fromRGBO(0, 0, 32, .5),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.all(10),
                                        height: 50,
                                        color: Colors.black.withOpacity(.8),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: FractionallySizedBox(
                                            widthFactor: 0.25,
                                            child: new ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(9),
                                                  side: BorderSide(
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 0.09),
                                                    width: 3,
                                                  ),
                                                ),
                                                backgroundColor: Colors.pink[
                                                    900], // Updated button background color
                                              ),
                                              child: Text(
                                                "Back",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors
                                                      .white, // Text color using TextStyle
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _indworkerssalesvisible =
                                                      false;
                                                  _indprodvisible = false;
                                                  _individualworkerprice = 0;
                                                  _individualworkerfuture =
                                                      null;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.only(top: 15),
                                  height: 50,
                                  color: Colors.pink[900]!.withOpacity(.53),
                                  child: Text(
                                    'Amount of items sold : GH¢ ' +
                                        _individualworkerprice.toString(),
                                    textAlign: TextAlign.center,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18.0,
                                        color: Colors.white),
                                  ),
                                ),
                                Container(
                                  color: Colors.black.withOpacity(0.75),
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
                                    child: new TextField(
                                      onSubmitted: (value) {
                                        setState(() {
                                          _individualworkerfuture = DBProvider()
                                              .fetchindividualsearchedsoldProducts(
                                                  searchdate,
                                                  "",
                                                  "daily",
                                                  value,
                                                  widget.shopname,
                                                  widget.location,
                                                  user);
                                        });
                                        Future.delayed(Duration(seconds: 0))
                                            .then((value) {
                                          _individualworkerfuture!
                                              .then((value) {
                                            if (value.isNotEmpty) {
                                              Future.delayed(
                                                      Duration(seconds: 0))
                                                  .then((value) {
                                                setState(() {
                                                  _indprodvisible = false;
                                                });
                                              });
                                            } else {
                                              Future.delayed(
                                                      Duration(seconds: 0))
                                                  .then((value) {
                                                setState(() {
                                                  _indprodvisible = true;
                                                  _individualworkerprice = 0;
                                                });
                                              });
                                            }
                                          });
                                        });
                                      },
                                      textInputAction: TextInputAction.search,
                                      decoration: new InputDecoration(
                                          prefixIcon: new Icon(Icons.search),
                                          hintText: 'Search...'),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(0),
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          padding: EdgeInsets.all(20),
                                          color: Colors.black.withOpacity(.7),
                                          child: new FutureBuilder<
                                              List<SoldProducts>>(
                                            future: _individualworkerfuture,
                                            builder: (BuildContext context,
                                                AsyncSnapshot<
                                                        List<SoldProducts>>
                                                    snapshot) {
                                              Widget newsListSliver;
                                              if (snapshot.hasData) {
                                                newsListSliver =
                                                    SliverGrid(
                                                      gridDelegate: SliverWovenGridDelegate.count(
                                                        crossAxisCount: 2,
                                                        mainAxisSpacing: MediaQuery.of(context).size.width * 0.07,
                                                        crossAxisSpacing: MediaQuery.of(context).size.width * 0.07,
                                                        pattern: [
                                                          WovenGridTile(1),
                                                          WovenGridTile(
                                                            5 / 7,
                                                            crossAxisRatio: 0.9,
                                                            alignment: AlignmentDirectional.centerEnd,
                                                          ),
                                                        ],
                                                      ),
                                                      delegate: SliverChildBuilderDelegate(
                                                            (BuildContext context, int index) {
                                                          SoldProducts items = snapshot.data![index];

                                                          return Container(
                                                            width: MediaQuery.of(context).size.width * 0.45,
                                                            decoration: BoxDecoration(
                                                              color: Color.fromRGBO(0, 0, 20, .4),
                                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                                              border: Border.all(
                                                                color: Colors.grey.withOpacity(.8),
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(15.0),
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: <Widget>[
                                                                  Container(
                                                                    padding: EdgeInsets.all(5),
                                                                    child: Text(
                                                                      '${items.name} (${items.size})',
                                                                      textAlign: TextAlign.center,
                                                                      style: TextStyle(
                                                                        fontWeight: FontWeight.w400,
                                                                        fontSize: 14.0,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Divider(
                                                                    color: Colors.white.withOpacity(0.4),
                                                                    height: 1,
                                                                  ),
                                                                  Container(
                                                                    padding: EdgeInsets.all(15.0),
                                                                    height: MediaQuery.of(context).size.width * 0.3,
                                                                    child: ClipRRect(
                                                                      borderRadius: BorderRadius.circular(15.0),
                                                                      child: getfile(imgdir, items.name), // Adjust as needed
                                                                    ),
                                                                  ),
                                                                  Divider(
                                                                    color: Colors.white.withOpacity(0.4),
                                                                    height: 1,
                                                                  ),
                                                                  Container(
                                                                    padding: EdgeInsets.all(5),
                                                                    child: Text(
                                                                      'Qty : ${items.prodid}',
                                                                      textAlign: TextAlign.center,
                                                                      style: TextStyle(
                                                                        fontWeight: FontWeight.w400,
                                                                        fontSize: 14.0,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Divider(
                                                                    color: Colors.white.withOpacity(0.4),
                                                                    height: 1,
                                                                  ),
                                                                  Container(
                                                                    padding: EdgeInsets.all(5),
                                                                    child: Text(
                                                                      'Amt : GH¢ ${double.parse(items.price!).toString()}',
                                                                      textAlign: TextAlign.center,
                                                                      style: TextStyle(
                                                                        fontWeight: FontWeight.w400,
                                                                        fontSize: 14.0,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        childCount: snapshot.data!.length, // Make sure this reflects the data count
                                                      ),
                                                    )
                                                ;
                                              } else {
                                                newsListSliver =
                                                    SliverToBoxAdapter(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }

                                              return CustomScrollView(
                                                primary: false,
                                                slivers: <Widget>[
                                                  newsListSliver
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: Visibility(
                                            visible: _indprodvisible,
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 30,
                                              padding: EdgeInsets.all(5.0),
                                              color:
                                                  Colors.black.withOpacity(.6),
                                              child: Text(
                                                'No items sold.',
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
                                ),
                              ],
                            ),
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
    );
  }

  getnfile(String? imgdir, String? name) {
    String? lastcharac = name!.substring(name.length - 1);
    if (!name.contains("-1")) {
      var fname = name.trimLeft() + ".jpg";
      if (File("$imgdir/$fname").existsSync()) {
        String? imgname = name + ".jpg";
        return FileImage(File(imgdir! + fname.trimLeft()));
        // return Image.file(File(imgdir + imgname.trimLeft()));
      } else {
        downloadimage(fname);

        return NetworkImage(
            "$hostUrl/Madam_Rita_s_Enterprise/images/" + fname);
      }
    }
  }

  getfile(String? imgdir, String? name) {
    String? lastcharac = name!.substring(name.length - 1);
    var fname = name.trimLeft() + ".jpg";
    if (File("$imgdir/$fname").existsSync()) {
      String? imgname = name + ".jpg";
      // FileImage(File(imgdir + fname.trimLeft()));
      return Image.file(File(imgdir! + imgname.trimLeft()));
    } else {
      downloadimage(fname);

      return CachedNetworkImage(
        imageUrl: "$hostUrl/Madam_Rita_s_Enterprise/images/" + fname,
        progressIndicatorBuilder: (context, url, dprogress) =>
            CircularProgressIndicator(
          value: dprogress.progress,
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    }
  }

  downloadimage(String? filename) async {
    var url = "$hostUrl/Madam_Rita_s_Enterprise/images/" + filename!;
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
