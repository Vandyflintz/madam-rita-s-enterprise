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
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyStockList());
}

class MyStockList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Madam Rita\'s Enterprise',
      home: StockList(title: 'Madam Rita\'s Enterprise'),
    );
  }
}

Future<List<Products>> fetchavailableproducts() async {
  var dbhelper = DBProvider();
  Future<List<Products>> products = dbhelper.fetchAllProducts();
  return products;
}

class StockList extends StatefulWidget {
  StockList({Key? key, this.title, this.shopname, this.location})
      : super(key: key);
  final String? title, shopname, location;

  @override
  _MyStockState createState() => _MyStockState();
}

class _MyStockState extends State<StockList> with TickerProviderStateMixin {
  String? directory;
  List files = [];
  String? imgdir;
  final formattedval = new NumberFormat("#,##0.00", "en_US");
  Future<List<GeneralProducts>>? _future;
  @override
  void initState() {
    super.initState();
    loadfile();
    Future.delayed(Duration(seconds: 0)).then((value) {
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
    _future = DBProvider().fetchallproducts(widget.shopname, widget.location);
  }

  void _fileslist() async {
    directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      files = Io.Directory("$directory/MyStockImages/").listSync();
    });
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
        imageUrl:
            "$hostUrl/Madam_Rita_s_Enterprise/images/" +
                fname,
        progressIndicatorBuilder: (context, url, dprogress) =>
            CircularProgressIndicator(
          value: dprogress.progress,
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
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

  loadfile() async {
    final dir = await (getApplicationDocumentsDirectory());
    imgdir = dir.path + "/MyStockImages/";
  }

  final TextEditingController _filter = new TextEditingController();

  String? _searchText = "", _selectedproduct = "";
  List prodlist = [];
  List filteredproducts = [];
  Icon _searchIcon = new Icon(Icons.search);
  Icon _clearIcon = new Icon(Icons.clear_all);
  Widget _appBarTitle = new Text('Search for products here');
  bool _prodvisible = false;

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
              _future = DBProvider()
                  .fetchallproducts(widget.shopname, widget.location);
            });
            Future.delayed(Duration(seconds: 0)).then((value) {
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
          },
        )
      ],
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
            controller: _filter,
            onSubmitted: (value) {
              setState(() {
                _future = DBProvider().fetchsearchedproducts(
                    value, widget.shopname, widget.location);
              });
              Future.delayed(Duration(seconds: 0)).then((value) {
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
            },
            textInputAction: TextInputAction.search,
            decoration: new InputDecoration(
                prefixIcon: new Icon(Icons.search), hintText: 'Search...'),
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Search for products here');
        _filter.clear();
      }
    });
  }

  displaywindow(String? product, BuildContext context) {
    setState(() {
      _selectedproduct = product;
    });
    return showDialog(
      context: context, builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.all(10),
          contentPadding: EdgeInsets.all(0),
          content: Container(
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
                  border:
                  Border.all(color: Colors.white.withOpacity(.05), width: 5),
                  color: Colors.black.withOpacity(.62),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14)),
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(2.0),
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
                        child: new Container(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 60),
                                padding: EdgeInsets.only(
                                    left:
                                    MediaQuery.of(context).size.width * 0.03,
                                    right:
                                    MediaQuery.of(context).size.width * 0.03,
                                    bottom: 80,
                                    top: 0),
                                height: MediaQuery.of(context).size.height - 98,
                                child: new FutureBuilder<List<SpecificProducts>>(
                                  future: DBProvider().fetchspecificproducts(
                                      product, widget.shopname, widget.location),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<List<SpecificProducts>>
                                      snapshot) {
                                    Widget newsListSliver;
                                    if (snapshot.hasData) {
                                      newsListSliver =
                                          SliverGrid(
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4, // Set the number of columns
                                              mainAxisSpacing: MediaQuery.of(context).size.width * 0.07,
                                              crossAxisSpacing: MediaQuery.of(context).size.width * 0.07,
                                              childAspectRatio: 0.75, // Adjust this ratio to simulate the woven pattern
                                            ),
                                            delegate: SliverChildBuilderDelegate(
                                                  (BuildContext context, int index) {
                                                SpecificProducts item = snapshot.data![index];

                                                return Container(
                                                  width: MediaQuery.of(context).size.width * 0.48,
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
                                                            item.size!,
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
                                                          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
                                                          height: MediaQuery.of(context).size.width * 0.3,
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(15.0),
                                                            child: getfile(imgdir, item.pname),
                                                          ),
                                                        ),
                                                        Divider(
                                                          color: Colors.white.withOpacity(.4),
                                                          height: 1,
                                                        ),
                                                        Container(
                                                          padding: EdgeInsets.all(5),
                                                          child: Text(
                                                            "Qty : ${item.quantity}",
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
                                                            "Unit Price :\nGH¢ ${formattedval.format(double.parse(item.price!))}",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              height: 1.5,
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
                                top: 0,
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.all(5.0),
                                        color: Colors.black.withOpacity(.6),
                                        child: Text(
                                          _selectedproduct!,
                                          textAlign: TextAlign.center,
                                          style: new TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16.0,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context,
                                              rootNavigator: true)
                                              .pop('dialog');
                                        },
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              top: 5.0,
                                              bottom: 5.0,
                                              left: 10.0,
                                              right: 10.0),
                                          color: Colors.pink[900]!.withOpacity(.8),
                                          child: Text(
                                            'Close',
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
            ),
          ),
        );
    },

    );
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool pressed = false, _obscuretext = false, _visibility = false;

  SnackBar? snackBar;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildBar(context),
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
                  child: Center(
                    child: new Container(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 40),
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.07,
                                right: MediaQuery.of(context).size.width * 0.07,
                                bottom: 80,
                                top: 10),
                            height: MediaQuery.of(context).size.height - 98,
                            child: FutureBuilder<List<GeneralProducts>>(
                              future: _future,
                              builder:
                                  (BuildContext context, AsyncSnapshot<List<GeneralProducts>> snapshot) {
                                List<Widget> slivers = [];

                                // Add message if no data
                                slivers.add(
                                  SliverToBoxAdapter(
                                    child: Visibility(
                                      visible: _prodvisible,
                                      child: Text(
                                        'No data found for product.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );

                                if (snapshot.hasData) {
                                  slivers.add(
                                    SliverGrid(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4, // Number of columns
                                        mainAxisSpacing:
                                        MediaQuery.of(context).size.width * 0.07,
                                        crossAxisSpacing:
                                        MediaQuery.of(context).size.width * 0.07,
                                      ),
                                      delegate: SliverChildBuilderDelegate(
                                            (BuildContext context, int index) {
                                          GeneralProducts item = snapshot.data![index];

                                          return GestureDetector(
                                            onTap: () {
                                              if (item.quantity == "0") {
                                                showsnackbar("Out of stock", "Close");
                                              } else {
                                                displaywindow(item.name, context);
                                              }
                                            },
                                            child: Container(
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
                                                        item.name!,
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
                                                      padding: EdgeInsets.symmetric(
                                                          vertical: 15.0, horizontal: 10),
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
                                                        "Qty : ${item.quantity}",
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
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: snapshot.data!.length, // Number of items
                                      ),
                                    ),
                                  );
                                } else {
                                  slivers.add(
                                    SliverToBoxAdapter(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  );
                                }

                                return CustomScrollView(
                                  primary: false,
                                  slivers: slivers,
                                );
                              },
                            ),
                          )

                          /* Container(
                            margin: EdgeInsets.only(top: 40),
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.07,
                                right: MediaQuery.of(context).size.width * 0.07,
                                bottom: 80,
                                top: 10),
                            height: MediaQuery.of(context).size.height - 98,
                            child: new FutureBuilder<List<GeneralProducts>>(
                              future: _future,
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<GeneralProducts>>
                                      snapshot) {
                                Widget newsListSliver;
                                Widget newsTextSliver = SliverToBoxAdapter(
                                  child: Visibility(
                                    visible: _prodvisible,
                                    child: Text(
                                      'No data found for product.',
                                      textAlign: TextAlign.center,
                                      style: new TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.0,
                                          color: Colors.white),
                                    ),
                                  ),
                                );
                                if (snapshot.hasData) {
                                  newsListSliver =
                                      GridView.custom(
                                        gridDelegate: SliverWovenGridDelegate.count(
                                          crossAxisCount: 4, // Number of columns
                                          mainAxisSpacing: MediaQuery.of(context).size.width * 0.07,
                                          crossAxisSpacing: MediaQuery.of(context).size.width * 0.07,
                                          pattern: [
                                            WovenGridTile(1),
                                            WovenGridTile(5 / 7, crossAxisRatio: 0.9, alignment: AlignmentDirectional.centerEnd),
                                          ],
                                        ),
                                        childrenDelegate: SliverChildBuilderDelegate(
                                              (BuildContext context, int index) {
                                            GeneralProducts item = snapshot.data![index];

                                            return GestureDetector(
                                              onTap: () {
                                                if (item.quantity == "0") {
                                                  showsnackbar("Out of stock", "Close");
                                                } else {
                                                  displaywindow(item.name, context);
                                                }
                                              },
                                              child: Container(
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
                                                          item.name!,
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
                                                        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
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
                                                          "Qty : ${item.quantity}",
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
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          childCount: snapshot.data!.length, // Update this according to your data source
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
                                  slivers: <Widget>[
                                    newsListSliver,
                                  ],
                                );
                              },
                            ),
                          )*/,
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
                                  color: Colors.black.withOpacity(.6),
                                  child: Text(
                                    'Products Catalogue',
                                    textAlign: TextAlign.center,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.0,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
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
                                  'No data found for product.',
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.0,
                                      color: Colors.white),
                                ),
                              ),
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
      ),
    );
  }
}
