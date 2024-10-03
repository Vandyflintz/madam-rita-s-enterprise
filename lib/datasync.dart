import 'dart:ui';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'DatabaseHelper.dart';
import 'dart:async';
import 'dart:convert';
import 'Utils/customfunctions.dart';
import 'products_model.dart';
import 'workersdetails.dart';
import 'addnewworker.dart';
import 'home.dart';
import 'dart:io';
import 'dart:io' as Io;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'keep_page_alive.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
//import 'package:flutter_archive/flutter_archive.dart';

void main() {
  runApp(DataSyncPage());
}

class DataSyncPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Madam Rita\'s Enterprise',
      home: SyncPage(title: 'Madam Rita\'s Enterprise'),
    );
  }
}

class SyncPage extends StatefulWidget {
  SyncPage({Key? key, this.title, this.shopname, this.location})
      : super(key: key);
  final String? title, shopname, location;

  @override
  _MyChartState createState() => _MyChartState();
}

class _MyChartState extends State<SyncPage>
    with SingleTickerProviderStateMixin {
  String? directory;
  Directory? finaldir;
  List files = [];
  String? imgdir;
  var _scrollController, _tabController;
  int bottomSelectedIndex = 0;

  @override
  void initState() {
    loadfile();
    super.initState();
    _images = [];
    _tempimages = [];
    _downloading = false;
  }

  String? dir;

  loadfile() async {
    imgdir =
        (await getApplicationDocumentsDirectory()).path + "/MyStockImages/";
    dir = (await getApplicationDocumentsDirectory()).path;
    directory = ((await getExternalStorageDirectory())!.path + "/Downloads");
  }

  void _fileslist() async {
    directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      files = Io.Directory("$directory/MyStockImages/").listSync();
    });
  }

  bool? _downloading;

  List<String>? _images, _tempimages;
  String? _zippath =
      '$hostUrl/Madam_Rita_s_Enterprise/images.zip';
  String? _zipfile = 'images.rar';
  String? _uploadurl =
      '$hostUrl/Madam_Rita_s_Enterprise/connection.php';
  /*Future<File> _downloadfiles(String? url, String? fileName, String? dir) async {
    var req = await http.Client().get(Uri.parse(url));
    if (jsonDecode(req.body) == "-1") {
      Navigator.of(context, rootNavigator: true).pop();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("No images available for download"),
        action: SnackBarAction(
          label: "Close",
          onPressed: () {},
        ),
      ));
    } else {
      var file = File('$dir$fileName');
      var dfile = File('$directory/$fileName');
      print(file.path);
      await dfile.writeAsBytes(req.bodyBytes);
      return file.writeAsBytes(req.bodyBytes);
    }
  }*/

  /*Future<File> _downloadfile(String? url, String? fileName, String? dir) async {
    var req = await http.Client().get(Uri.parse(url!));
    if (jsonDecode(req.body) == "-1") {
      showsnackbar("No images available for download", "Close", context);
      Navigator.of(context, rootNavigator: true).pop();

    } else {
      var file = File('$dir$fileName');
      var dfile = File('$directory/$fileName');
      var dldata = <int>[];
      HttpClient client = new HttpClient();
      var request = await client.getUrl(Uri.parse(url));
      var response = await request.close();

      response.listen(
            (event) {
          dldata.addAll(event); // Add the incoming bytes to the dldata list
        },
        onDone: () async {
          // Ensure to write as bytes
          await file.writeAsBytes(dldata);
          print('Data written to file successfully.');

        },
        onError: (error) {
          print('Error: $error'); // Handle any errors
        },
      );
      return file;
    }
  }*/

  Future<File?> _downloadfile(String? url, String? fileName, String? dir) async {
    try {
      var req = await http.Client().get(Uri.parse(url!));

      // Check if there are images available for download
      if (jsonDecode(req.body) == "-1") {
        showsnackbar("No images available for download", "Close", context);
        Navigator.of(context, rootNavigator: true).pop();
        return null; // Return null if no images are available
      }

      var file = File('$dir$fileName');
      var dldata = <int>[];

      HttpClient client = new HttpClient();
      var request = await client.getUrl(Uri.parse(url));
      var response = await request.close();

      await for (var event in response) {
        dldata.addAll(event); // Add the incoming bytes to the dldata list
      }

      // Write the bytes to the file
      await file.writeAsBytes(dldata);
      print('Data written to file successfully.');

      return file; // Return the file object
    } catch (e) {
      print('Error: $e'); // Handle any errors
      showsnackbar(e.toString(), "Close", context);
      Navigator.of(context, rootNavigator: true).pop();
      return null; // Return null on error
    }
  }

  Future<void> _downloadZip() async {
    // await _downloadfiles(_zippath, _zipfile, imgdir);
    await _downloadfile(_zippath, _zipfile, imgdir).then((file) {
      if (file != null) {
        Navigator.of(context, rootNavigator: true).pop();
        showsnackbar("Images have been successfully downloaded", "Close", context);
      } else {
        // Handle case where file is null (indicating an error or no images)
        showsnackbar("Download failed or no images available", "Close", context);
      }
    }).catchError((err) {
      showsnackbar(err.toString(), "Close", context);
      Navigator.of(context, rootNavigator: true).pop();
    });
    //await unarchiveandsave(zippedfile);
  }

  unarchiveandsave(var zippedFile) async {
    /* final zipFile = File("$imgdir$_zipfile");
    final destinationdir = Directory("$imgdir");
    try {
      await ZipFile.extractToDirectory(
        zipFile: zipFile,
        destinationDir: destinationdir,
      ).then((e) {
        Navigator.of(context, rootNavigator: true).pop();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Images have been successfully downloaded"),
          action: SnackBarAction(
            label: "Close",
            onPressed: () {},
          ),
        ));
      }).catchError((err) {
        Navigator.of(context, rootNavigator: true).pop();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
            label: "Close",
            onPressed: () {},
          ),
        ));
      });
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        action: SnackBarAction(
          label: "Close",
          onPressed: () {},
        ),
      ));
    }*/
    var bytes = zippedFile.readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);
    // print(archive);
    for (var file in archive) {
      var filename = '$imgdir/${file.name}';
      if (file.isFile) {
        var outFile = File(filename);

        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content).then((value) {

          showsnackbar("Images have been downloaded successfully", "Close", context);
          Navigator.of(context, rootNavigator: true).pop();
        }).catchError((onError) {
          showsnackbar(onError.toString(), "Close", context);
          Navigator.of(context, rootNavigator: true).pop();

        });
      }
    }
  }

  int gridsize = 0;
  SnackBar? snackBar;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _downloaddata(String? nameoftab, BuildContext bcontext) async {
    String? tabtoquery;
    if (nameoftab!.contains("pname")) {
      tabtoquery = "getproductnames";
      _executeoperations(tabtoquery, "pname", bcontext);
    }

    if (nameoftab.contains("pquant")) {
      tabtoquery = "getproductquantities";
      _executeoperations(tabtoquery, "pquant", bcontext);
    }

    if (nameoftab.contains("pprice")) {
      tabtoquery = "getproductprices";
      _executeoperations(tabtoquery, "pprice", bcontext);
    }

    if (nameoftab.contains("psold")) {
      tabtoquery = "getproductstock";
      _executeoperations(tabtoquery, "psold", bcontext);
    }

    if (nameoftab.contains("pwork")) {
      tabtoquery = "getworkersdata";
      _executeoperations(tabtoquery, "pwork", bcontext);
    }

    if (nameoftab.contains("pshop")) {
      tabtoquery = "getshopdata";
      _executeoperations(tabtoquery, "pshop", bcontext);
    }

    if (nameoftab.contains("pimages")) {
      _downloadZip();
    }
  }

  _executeoperations(
      String? tabtoquery, String? nameoftab, BuildContext bcontext) async {
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
        Navigator.of(context, rootNavigator: true).pop();
        if (jsonDecode(response.body) == "-1") {
          showsnackbar("No data available to download", "Close", context);

        } else {
          if (nameoftab!.contains("pwork")) {
            downloadworkdata(response.body.toString(), bcontext);
          }

          if (nameoftab.contains("pname")) {
            downloadproductnamesdata(response.body.toString(), bcontext);
          }

          if (nameoftab.contains("pquant")) {
            downloadquantitydata(response.body.toString(), bcontext);
          }

          if (nameoftab.contains("pprice")) {
            downloadpricedata(response.body.toString(), bcontext);
          }

          if (nameoftab.contains("psold")) {
            downloadstockdata(response.body.toString(), bcontext);
          }
        }
      } else {
        showsnackbar("Error connecting to server...","Close", context);
        Navigator.of(context, rootNavigator: true).pop();

      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      Navigator.of(context, rootNavigator: true).pop();
      Future.delayed(Duration(seconds: 0)).then((value) {
        showsnackbar("Connection to server timed out!","Close", context);
      });
    } on SocketException catch (e) {
      print('Socket Error: $e');
    } on Error catch (e) {
      showsnackbar("Error connecting to server...","Close", context);
      Navigator.of(context, rootNavigator: true).pop();

    }
  }

  _displayalertforupdate(String? tabname) {
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
      builder: (BuildContext bcontext) {
        _downloaddata(tabname, bcontext);
        return alert;
      },
    );
  }

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
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      padding: EdgeInsets.only(top: 15.0),
                      color: Colors.black.withOpacity(.6),
                      child: Text(
                        'Data Synchronization Page',
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                top: 25, left: 10, right: 10, bottom: 7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    "Product Names ",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontFamily: 'serif',
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _displayalertforupdate("pname");
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(.23),
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                            width: 1,
                                            color:
                                                Colors.white.withOpacity(.8)),
                                      ),
                                      padding: EdgeInsets.all(3.0),
                                      child: Icon(
                                        Icons.download_rounded,
                                        color: Colors.white,
                                        size: 25,
                                      )),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.white.withOpacity(.6),
                            height: 1,
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                top: 25, left: 10, right: 10, bottom: 7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    "Product Quantity",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontFamily: 'serif',
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _displayalertforupdate("pquant");
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(.23),
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                            width: 1,
                                            color:
                                                Colors.white.withOpacity(.8)),
                                      ),
                                      padding: EdgeInsets.all(3.0),
                                      child: Icon(
                                        Icons.download_rounded,
                                        color: Colors.white,
                                        size: 25,
                                      )),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.white.withOpacity(.6),
                            height: 1,
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                top: 25, left: 10, right: 10, bottom: 7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    "Product Prices",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontFamily: 'serif',
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _displayalertforupdate("pprice");
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(.23),
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                            width: 1,
                                            color:
                                                Colors.white.withOpacity(.8)),
                                      ),
                                      padding: EdgeInsets.all(3.0),
                                      child: Icon(
                                        Icons.download_rounded,
                                        color: Colors.white,
                                        size: 25,
                                      )),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.white.withOpacity(.6),
                            height: 1,
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                top: 25, left: 10, right: 10, bottom: 7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    "Products Sold",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontFamily: 'serif',
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _displayalertforupdate("psold");
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(.23),
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                            width: 1,
                                            color:
                                                Colors.white.withOpacity(.8)),
                                      ),
                                      padding: EdgeInsets.all(3.0),
                                      child: Icon(
                                        Icons.download_rounded,
                                        color: Colors.white,
                                        size: 25,
                                      )),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.white.withOpacity(.6),
                            height: 1,
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                top: 25, left: 10, right: 10, bottom: 7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    "Workers' Data",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontFamily: 'serif',
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _displayalertforupdate("pwork");
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(.23),
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                            width: 1,
                                            color:
                                                Colors.white.withOpacity(.8)),
                                      ),
                                      padding: EdgeInsets.all(3.0),
                                      child: Icon(
                                        Icons.download_rounded,
                                        color: Colors.white,
                                        size: 25,
                                      )),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.white.withOpacity(.6),
                            height: 1,
                          ),
                          /*Container(
                            padding: EdgeInsets.only(
                                top: 25, left: 10, right: 10, bottom: 7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    "Product Images",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontFamily: 'serif',
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _displayalertforupdate("pimages");
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(.23),
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                            width: 1,
                                            color:
                                                Colors.white.withOpacity(.8)),
                                      ),
                                      padding: EdgeInsets.all(3.0),
                                      child: Icon(
                                        Icons.download_rounded,
                                        color: Colors.white,
                                        size: 25,
                                      )),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.white.withOpacity(.6),
                            height: 1,
                          ),*/
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

  Future<List<ModifiedWorkers>> downloadworkdata(
      String? res, BuildContext bcontext) async {
    var dbhelper = DBProvider();

    final parsed = jsonDecode(res!).cast<Map<String, dynamic>>();

    return parsed.map<ModifiedWorkers>((json) {
      dbhelper
          .downloadworkersdata(ModifiedWorkers.fromJson(json))
          .whenComplete(() {
        Future.delayed(Duration(seconds: 0)).then((value) {
          //showsnackbar("Data downloaded successfully", "Close");
        });
      });
    }).toList();
  }

  Future<List<ModifiedSoldProducts>> downloadstockdata(
      String? res, BuildContext bcontext) async {
    var dbhelper = DBProvider();

    final parsed = jsonDecode(res!).cast<Map<String, dynamic>>();

    return parsed.map<ModifiedSoldProducts>((json) {
      dbhelper
          .downloadstockdata(ModifiedSoldProducts.fromJson(json))
          .whenComplete(() {
        Future.delayed(Duration(seconds: 0)).then((value) {
          //showsnackbar("Data downloaded successfully", "Close");
        });
      });
    }).toList();
  }

  Future<List<ModifiedProductsPrices>> downloadpricedata(
      String? res, BuildContext bcontext) async {
    var dbhelper = DBProvider();

    final parsed = jsonDecode(res!).cast<Map<String, dynamic>>();

    return parsed.map<ModifiedProductsPrices>((json) {
      dbhelper
          .downloadproductprices(ModifiedProductsPrices.fromJson(json))
          .whenComplete(() {
        Future.delayed(Duration(seconds: 0)).then((value) {
          //showsnackbar("Data downloaded successfully", "Close");
        });
      });
    }).toList();
  }

  Future<List<ModifiedProducts>> downloadquantitydata(
      String? res, BuildContext bcontext) async {
    var dbhelper = DBProvider();

    final parsed = jsonDecode(res!).cast<Map<String, dynamic>>();

    return parsed.map<ModifiedProducts>((json) {
      dbhelper
          .downloadproductquantities(ModifiedProducts.fromJson(json))
          .whenComplete(() {
        Future.delayed(Duration(seconds: 0)).then((value) {
          //showsnackbar("Data downloaded successfully", "Close");
        });
      });
    }).toList();
  }

  Future<List<ModifiedProductsName>> downloadproductnamesdata(
      String? res, BuildContext bcontext) async {
    var dbhelper = DBProvider();

    final parsed = jsonDecode(res!).cast<Map<String, dynamic>>();

    return parsed.map<ModifiedProductsName>((json) {
      dbhelper
          .downloadproductnames(ModifiedProductsName.fromJson(json))
          .whenComplete(() {
        Future.delayed(Duration(seconds: 5)).then((value) {
          // Navigator.of(context).pop();
          //showsnackbar("Data downloaded successfully", "Close");
        });
      });
    }).toList();
  }
}
/*
.then((result) {
        Future.delayed(Duration(seconds: 0)).then((value) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Data downloaded successfully"),
            action: SnackBarAction(
              label: "Close",
              onPressed: () {},
            ),
          ));
        });

        Future.delayed(Duration(seconds: 1)).then((value) {});
      }).catchError((error) {
        Future.delayed(Duration(seconds: 0)).then((value) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(error.toString()),
            action: SnackBarAction(
              label: "Close",
              onPressed: () {},
            ),
          ));
        });
      });
*/
