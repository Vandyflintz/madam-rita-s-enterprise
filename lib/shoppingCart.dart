import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'Utils/customfunctions.dart';
import 'home.dart';
import 'dart:io';
import 'dart:io' as Io;
import 'dart:typed_data';
import 'package:qrscan/qrscan.dart' as scanner;
import 'products_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'DatabaseHelper.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'products_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madam Rita\'s Enterprise',
      home: MyShoppingPage(),
    );
  }
}

final _scaffoldKey = GlobalKey<ScaffoldState>();
bool pressed = false, _obscuretext = false, _visibility = false;
SnackBar? snackBar;

class MyShoppingPage extends StatefulWidget {
  MyShoppingPage({Key? key, this.title, this.shopname, this.location})
      : super(key: key);
  final String? title, shopname, location;
  @override
  _MyShoppingPageState createState() => _MyShoppingPageState();
}

class _MyShoppingPageState extends State<MyShoppingPage> {
  TextEditingController? _totalitempricescontroller;
  TextEditingController? pricetec;
  TextEditingController? idtec;
  SharedPreferences? sharedpref;
  String? _user = '', _shopname = '', _userid = '', imgdir;
  @override
  void initState() {
    super.initState();
    initializesharedpref();
    loadfile();
    _totalitempricescontroller = TextEditingController();
    idtec = TextEditingController();
    pricetec = TextEditingController();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  initializesharedpref() async {
    sharedpref = await SharedPreferences.getInstance();
    setState(() {
      _user = sharedpref!.getString('user')!.trim();
      _userid = sharedpref!.getString('userid')!.trim();
    });

    /*Future.delayed(Duration(seconds: 1)).then((value) {
      showsnackbar(_user + " & " + _userid, "Okay");
    });*/

    _shopname = sharedpref!.getString('shopname');
  }

  @override
  void dispose() {
    //_itemidscontroller.dispose();
    //_itemnamescontroller.dispose();
    //_itempricescontroller.dispose();
    //_itemsizescontroller.dispose();
    idtec!.dispose();
    pricetec!.dispose();
    super.dispose();
  }

  String? _uploadurl =
      '$hostUrl/Madam_Rita_s_Enterprise/connection.php';
  var db = DBProvider();
  SnackBar? snackBar;

  Future _scan() async {
    String? barcode = await scanner.scan();
    if (barcode == null) {
      print('nothing return.');
    } else {
      _getproductscanned(barcode);
    }
  }

  _getproductscanned(String? code) async {
    db
        .getspecificProductwithcode(code, widget.shopname, widget.location)
        .then((final String? value) {
      if (value!.contains("emptydata")) {
        showsnackbar("No price data available for product selected", "Close");
      } else {
        //showsnackbar("Result got : " + value, "Okay");
        final split = value.split(',');
        Map<int, String> finalval = {
          for (int i = 0; i < split.length; i++) i: split[i]
        };
        _renderResult(finalval[2], finalval[3], finalval[4], finalval[0],
            int.tryParse(finalval[1]!)!);
      }
    });
  }

  PDFList? pDFList;
  List itemtidlist = [];
  List<String> itemnameslist = [];
  List<String> itemidslist = [];
  List<String> itemsizeslist = [];
  List<String> itempriceslist = [];
  List pdfitemtidlist = [];
  List<String> pdfitemnameslist = [];
  List<String> pdfitemidslist = [];
  List<String> pdfitemsizeslist = [];
  List<String> pdfitempriceslist = [];
  List allsolditems = [];
  List pdfofallsolditems = [];
  bool _calcvisible = false, _savevisible = false;
  final formattedval = new NumberFormat("#,##0.00", "en_US");
  String? _upid = '',
      _upname = '',
      _upsize = '',
      _upprice,
      _gpname = '',
      _gpsize = '';

  loadfile() async {
    final dir = await (getApplicationDocumentsDirectory());
    imgdir = dir.path + "/MyStockImages/";
  }

  Future<File> getfile(String? imgdir, String? name) async {
    var fname = name!.trimLeft();
    if (File("$imgdir/$fname").existsSync()) {
      return File(imgdir! + name.trimLeft());
    } else {
      final bytedata = await rootBundle.load('assets/images/madam_rita.png');
      var filepathname = imgdir! + 'madam_rita.png';
      File file = new File(filepathname);
      await file.writeAsBytes(bytedata.buffer
          .asUint8List(bytedata.offsetInBytes, bytedata.lengthInBytes));
      return file;
    }
  }

  Future<Uint8List> _printreceipt() async {
    final pw.Document doc = pw.Document();
    File filedec = await getfile(imgdir, 'madam_rita.png');
    //ByteData bytes = await rootBundle.load('assets/images/madam_rita.png');

    /* var codec = await instantiateImageCodec(bytes.buffer.asUint8List());
    var frame = await codec.getNextFrame();
    var imageBytes = await frame.image.toByteData();
    var imageProvider =
        MemoryImage(base64Decode('assets/images/madam_rita.png'));
    final img = PdfImage(doc.document,
        image: imageBytes.buffer.asUint8List(), width: 50, height: 50);
    final dbytes = bytes.buffer.asUint8List();*/
    final image =
        pw.MemoryImage(File("$imgdir/madam_rita.png").readAsBytesSync());
    /*const imageProviderr = const AssetImage('assets/images/madam_rita.png');
    final dimage = await flutterImageProvider(imageProviderr);*/

    pdfofallsolditems.clear();
    var itemsmap, namesmap;
    for (int i = 0; i < pdfitemnameslist.length; i++) {
      itemsmap = {
        '"product_name"': '"${pdfitemnameslist[i].toString()}"',
        '"product_id"': '"${pdfitemidslist[i].toString().trimLeft()}"',
        '"product_size"': '"${pdfitemsizeslist[i]}"',
        '"price"': '"${pdfitempriceslist[i]}"'
      };

      pdfofallsolditems.add(itemsmap);
    }
    print(pdfofallsolditems.toString());
    PDFModel pdfModel = PDFModel.fromJson(
        jsonDecode('{ "data":' + pdfofallsolditems.toString() + '}'));
    doc.addPage(pw.MultiPage(
        pageFormat:
            PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.center,
              margin: const pw.EdgeInsets.only(bottom: 5.0 * PdfPageFormat.mm),
              padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              decoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColors.grey, width: 0.5))),
              child: pw.ListView(children: <pw.Widget>[
                //Image.asset(
                //      'assets/images/madam_rita.png')
                pw.Image(image, height: 70, width: 70),

                new pw.Padding(padding: const pw.EdgeInsets.only(top: 5)),

                pw.Text(widget.shopname!,
                    style: pw.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(color: PdfColors.grey700)),
                new pw.Padding(padding: const pw.EdgeInsets.only(top: 5)),

                pw.Text("Location : " + widget.location!,
                    style: pw.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(color: PdfColors.grey700)),
                new pw.Padding(padding: const pw.EdgeInsets.only(top: 5)),
                pw.Text(
                    'Receipt for items purchased on ${DateFormat('EEEE , MMMM d, yyyy HH:mm:ss').format(DateTime.now()).toString()}',
                    textAlign: pw.TextAlign.center,
                    style: pw.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(color: PdfColors.grey700)),
              ]));
        },
        /*footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)),
          );
        },*/
        build: (pw.Context context) {
          // final image = pw.ImageProvider(image:'assets/images/madam_rita.png');
          final parsed = jsonDecode(pdfofallsolditems.toString())
              .cast<Map<String, dynamic>>();
          return <pw.Widget>[
            pw.Table.fromTextArray(
                context: context,
                border: null,
                headerAlignment: pw.Alignment.centerLeft,
                cellPadding: pw.EdgeInsets.only(bottom: 10),
                data: <List<String>>[
                  <String>['Item', 'Price'],
                  for (int i = 0; i < pdfModel.plist!.length; i++)
                    <String>[
                      '${i + 1}. ${pdfModel.plist!.elementAt(i).product} ${" ("} ${pdfModel.plist!.elementAt(i).size} ${")"} ',
                      '${"GH¢ "} ${formattedval.format(double.parse(pdfModel.plist!.elementAt(i).price!)).toString()}'
                    ],

                  /*<String>[
                        '${i + 1}. ${pdfList.product[i]}',
                        '${pdfList.size[i]}',
                        '${pdfList.price[i]}'
                      ]*/
                ]),
            pw.Paragraph(text: ""),
            pw.Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: pw.ListView(children: [
                pw.Padding(padding: const pw.EdgeInsets.only(top: 7)),
                pw.Divider(
                  color: PdfColors.grey100,
                  height: 1,
                ),
                pw.Padding(padding: const pw.EdgeInsets.only(top: 7)),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Total Price:"),
                      pw.Text(
                          "GH¢ " + formattedval.format(summedvalue).toString())
                    ]),
              ]),
            ),
            pw.Padding(padding: const pw.EdgeInsets.all(10)),
          ];
        }));
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
    return doc.save();
  }

  void fetchitemdetails(
      String? upname, String? upsize, String? availableid) async {
    setState(() {
      _savevisible = true;
    });
    String? regex = "\\[|\\]";
    String? finalid = availableid!.replaceAll(new RegExp(regex), '');
    String? finalstring, sortedid;
    if (finalid.isEmpty) {
      finalstring = '';
    } else if (finalid.isNotEmpty && !finalid.contains(",")) {
      finalstring = "'" + finalid + "'";
      // sortedid = finalstring.replaceAll(new RegExp(r"\s\b|\b\s"), "");
      var trimmed = finalid.trimLeft();
      sortedid = "pd.product_id !='$trimmed'";
    } else {
      // finalstring = '\'' + finalid.split(',').join('\',\'') + '\'';
      //sortedid = finalstring.replaceAll(new RegExp(r"\s\b|\b\s"), "");
      String? newf;
      List modifiedstring = [];
      modifiedstring = finalid.split(',');
      for (var i = 0; i < modifiedstring.length; i++) {
        var trimmed = modifiedstring[i].toString().trimLeft();
        modifiedstring[i] = "pd.product_id !='$trimmed'";
      }
      sortedid = modifiedstring.join(" and ");
      // pd.product_id !=''
    }

    db
        .getspecificProductwithoutcode(
            upname, upsize, sortedid, widget.shopname, widget.location)
        .then((final String? value) {
      print('$sortedid');
      if (value!.contains("emptydata")) {
        showsnackbar("No price data available for product selected", "Close");
      } else {
        //showsnackbar("Result got : " + value, "Okay");
        final split = value.split(',');
        Map<int, String> finalval = {
          for (int i = 0; i < split.length; i++) i: split[i]
        };
        String? regex = "\\(|\\)";
        String? finalid = finalval[1]!.replaceAll(new RegExp(regex), '');
        int tabid = int.tryParse(finalval[2]!.replaceAll(new RegExp(regex), ''))!;
        _renderResult(upname, finalid, upsize, finalval[0], tabid);
      }
    });
  }

  void postitemsdata(String? name, String? size, String? price, String? id) async {
    Future.delayed(Duration(seconds: 0), () {
      setState(() {
        _calcvisible = true;
        itemnameslist.add(name!);
        itemidslist.add(id!);
        itemsizeslist.add(size!);
        itempriceslist.add(price!);

        pdfitemnameslist.add(name);
        pdfitemidslist.add(id);
        pdfitemsizeslist.add(size);
        pdfitempriceslist.add(price);
      });
      clearitems();
    });
  }

  displaywindow(String? idlist, BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
          backgroundColor: Colors.black.withOpacity(.6),
          child: Container(
            height: 350,
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
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          new Padding(padding: const EdgeInsets.only(top: 15)),
                          FutureBuilder<List<ProductsName>>(
                            future: DBProvider().fetchProductsNamesList(
                                widget.shopname, widget.location),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<ProductsName>> snapshot) {
                              if (snapshot.hasData) {
                                return DropdownButtonFormField(
                                    decoration: new InputDecoration(
                                      labelText: "Product Name",
                                    ),
                                    items: snapshot.data!.map((location) {
                                      return DropdownMenuItem(
                                        child: new Text(location.prodname!),
                                        value: location.prodname,
                                      );
                                    }).toList(),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'This field is required';
                                      }
                                    },
                                    onSaved: (newValue) {
                                      setState(() {
                                        _gpname = newValue;
                                      });
                                    },
                                    onChanged: (newValue) {
                                      setState(() {
                                        _gpname = newValue;
                                      });
                                    });
                              } else {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                            },
                          ),
                          new Padding(padding: const EdgeInsets.only(top: 15)),
                          new DropdownButtonFormField(
                              value: _upsize,
                              decoration: new InputDecoration(
                                labelText: "Product Size",
                              ),
                              items: <String>[
                                '',
                                'S',
                                'M',
                                'L',
                                'XL',
                                'XXL',
                                'GS'
                              ].map((String? value) {
                                return new DropdownMenuItem<String>(
                                    value: value, child: new Text(value!));
                              }).toList(),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'This field is required';
                                }
                              },
                              onSaved: (newValue) {
                                setState(() {
                                  _gpsize = newValue;
                                });
                              },
                              onChanged: (newValue) {
                                setState(() {
                                  _gpsize = newValue;
                                });
                              }),
                          new Padding(padding: const EdgeInsets.only(top: 15)),
                          FractionallySizedBox(
                            widthFactor: 0.60,
                            child: new ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(
                                    color: Color.fromRGBO(0, 0, 0, 0.09),
                                    width: 3,
                                  ),
                                ),
                                backgroundColor: Colors.pink[900], // Replace `color` with `backgroundColor`
                                foregroundColor: Colors.white, // Replace `textColor` with `foregroundColor`
                              ),
                              child: Text(
                                "fetch item data",
                                style: TextStyle(fontSize: 15, color: Colors.white),
                              ),
                              onPressed: () {
                                fetchitemdetails(_gpname, _gpsize, idlist);
                                Navigator.of(context).pop();
                              },
                            )
                            ,
                          ),
                          new Padding(padding: const EdgeInsets.only(top: 15)),
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
                                backgroundColor: Colors.pink[900], // Replace `color` with `backgroundColor`
                                foregroundColor: Colors.white, // Replace `textColor` with `foregroundColor`
                              ),
                              child: Text(
                                "Exit",
                                style: TextStyle(fontSize: 15, color: Colors.white),
                              ),
                              onPressed: () {
                                if (_gpname!.isNotEmpty &&
                                    _gpsize!.isNotEmpty &&
                                    idtec!.text.isNotEmpty &&
                                    pricetec!.text.isNotEmpty) {
                                  postitemsdata(_gpname, _gpsize, pricetec!.text, idtec!.text);
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                            )
                            ,
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
      },
    );
  }

  void _renderResult(
      String? name, String? id, String? pprice, String? psize, int mainid) {
    String? regex = "\\(|\\)";
    String? finalsize = pprice!.replaceAll(new RegExp(regex), '');
    String? finalprice = psize!.replaceAll(new RegExp(regex), '');
    //showsnackbar(itemidslist.toString(), "Close");

    Future.delayed(Duration(seconds: 0), () {
      setState(() {
        _savevisible = true;
        _calcvisible = true;
        itemtidlist.add(mainid);
        itemnameslist.add(name!);
        itemidslist.add(id!);
        itemsizeslist.add(finalsize);
        itempriceslist.add(finalprice);
        pdfitemnameslist.add(name);
        pdfitemidslist.add(id);
        pdfitemsizeslist.add(finalsize);
        pdfitempriceslist.add(finalprice);
        ++prodindex;
      });
      clearitems();
      //showsnackbar(itemidslist.toString(), "Okay");
    });
  }

  recorditems() async {
    // Batch batch = txn.batch();

    var itemsmap, namesmap;
    for (int i = 0; i < itemnameslist.length; i++) {
      itemsmap = {
        '"product_name"': '"${itemnameslist[i]}"',
        '"product_size"': '"${itemsizeslist[i]}"',
        '"product_id"': '"${itemidslist[i]}"',
        '"price"': '"${itempriceslist[i]}"',
        '"date_sold"':
            '"${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString()}"',
        '"sold_by"': '"${_user}"',
        '"shopname"': '"${widget.shopname}"',
        '"location"': '"${widget.location}"'
      };
      allsolditems.add(itemsmap);
    }
    // showsnackbar(allsolditems.toString(), "Okay");
    print(allsolditems.toString());
    //

    int timeout = 15;
    String? regex = "\\[|\\]";
    try {
      http.Response response =
          await http.get(Uri.parse(_uploadurl!)).timeout(Duration(seconds: timeout));

      if (response.statusCode == 200) {
        print(response.body);
        //connected, validate email address and contact
        var urlone =
            "http://$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php";
        var url =
            "$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php";
        var data = {
          "solddata": allsolditems.toString(),
          "solddetails": "request"
        };

        //await http.post(Uri.parse(url)one, body: data);
        var responseone = await http.post(Uri.parse(url), body: data);
        print(responseone.body);
        if (jsonDecode(responseone.body) == "-1") {
          showsnackbar(
              "Error processing request, please try again later", "Close");
        } else {
          db.deleteproducts(itemtidlist);
          sortitems(allsolditems.toString());
          Future.delayed(Duration(seconds: 1)).then((value) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => MyShoppingPage(
                        shopname: widget.shopname, location: widget.location)),
                (Route<dynamic> route) => false);

            showsnackbar("Data uploaded successfully", "Close");

            //refreshpage();
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

  /*Future<List<SoldProducts>> sortitems(String? allsolditems) async {
    //showsnackbar(allsolditems, "Okay");
    var dbhelper = DBProvider();

    return (json.decode(allsolditems) as List).map((e) {
      // showsnackbar(itemidslist.toString(), "Okay");

      dbhelper.newsoldItems(SoldProducts.fromJson(e)).then((result) {
        showsnackbar("Transaction successful", "Okay");
        Future.delayed(Duration(seconds: 1)).then((value) {});
      }).catchError((error) {
        showsnackbar(error.toString(), "Close");
      });
    }).toList();
  }*/

  Future<List<SoldProducts>> sortitems(String? allsolditems) async {
    var dbhelper = DBProvider();

    // Decode the JSON into a List
    List<dynamic> items = json.decode(allsolditems!);

    // Create an empty list to hold SoldProducts
    List<SoldProducts> soldProductsList = [];

    // Iterate over the decoded items
    for (var e in items) {
      try {
        // Call the asynchronous method and wait for its completion
        SoldProducts product = await dbhelper.newsoldItems(SoldProducts.fromJson(e));
        soldProductsList.add(product); // Add the product to the list
        showsnackbar("Transaction successful", "Okay");
        await Future.delayed(Duration(seconds: 1)); // Optional: wait for 1 second
      } catch (error) {
        showsnackbar(error.toString(), "Close");
      }
    }

    return soldProductsList; // Return the final list of SoldProducts
  }


  void displayitems(String nameelement, String sizeelement, String priceelement,
      String idelement) {
    showsnackbar(
        "Name : " +
            nameelement +
            " , Size : " +
            sizeelement +
            " , Price : " +
            priceelement +
            " , ID : " +
            idelement,
        "Close");
  }

  List<TextEditingController> tnamescon = [];
  List<TextEditingController> tidcon = [];
  List<TextEditingController> tpricecon = [];
  List<TextEditingController> tsizecon = [];

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

  String? itemname = '';
  String? itemid = '';
  String? size = '';
  String? price = '';
  final _formkeyAddProduct = GlobalKey<FormState>();
  /*Widget _buildrow(String itemname, String itemid, String size, String price) {
    if (itemname.isEmpty ??
        true && itemid.isEmpty ??
        true && size.isEmpty ??
        true && price.isEmpty ??
        true) {
      return Center(
        child: Text('Items entered appear hear.'),
      );
    } else {}
  }*/

  String? randomString() {
    String? formatteddate =
        DateFormat('yyyyMMddHHmmss').format(DateTime.now()).toString();
    return formatteddate;
  }

  double summedvalue = 0;
  clearitems() async {
    summedvalue = itempriceslist.fold(
        0,
        (previousValue, element) =>
            previousValue + (double.tryParse(element ?? '0') ?? 0));
    var sum = double.parse(itempriceslist.reduce((a, b) => a + b));
    setState(() {
      _totalitempricescontroller!.text =
          formattedval.format(summedvalue).toString();
    });
  }

  int txtval = 0;
  int prodindex = 0;

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
            padding: EdgeInsets.all(2.0),
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 1,
            decoration: new BoxDecoration(color: Colors.black.withOpacity(0.4)),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottom),
              child: Form(
                key: _formkeyAddProduct,
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
                  child: IntrinsicHeight(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 1,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white.withOpacity(.15),
                                  width: 1),
                              color: Colors.pink[900]!.withOpacity(.4),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14)),
                            ),
                            child: ClipRect(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 1,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.4),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      topRight: Radius.circular(14)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      child: Text('Shopping Cart',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'serif',
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromRGBO(
                                                255, 255, 255, 1),
                                          )),
                                    ),
                                    Container(
                                      width: 35,
                                      height: 35,
                                      child: RawMaterialButton(
                                        onPressed: () {
                                          _scan();
                                        },
                                        elevation: 4.0,
                                        fillColor: Colors.lightGreen,
                                        child: Icon(
                                          Icons.qr_code,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                        padding: EdgeInsets.all(5.0),
                                        shape: CircleBorder(),
                                      ),
                                    ),
                                    Container(
                                      width: 35,
                                      height: 35,
                                      child: RawMaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            displaywindow(
                                                itemidslist.toString(),
                                                context);
                                          });
                                        },
                                        elevation: 4.0,
                                        fillColor: Colors.redAccent,
                                        child: Icon(
                                          Icons.article_rounded,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                        padding: EdgeInsets.all(5.0),
                                        shape: CircleBorder(),
                                      ),
                                    ),
                                    Visibility(
                                      visible: _calcvisible,
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        child: RawMaterialButton(
                                          onPressed: () {
                                            _printreceipt();
                                          },
                                          elevation: 4.0,
                                          fillColor: Colors.deepPurple,
                                          child: Icon(
                                            Icons.print,
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                          padding: EdgeInsets.all(5.0),
                                          shape: CircleBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 1,
                            height: MediaQuery.of(context).size.height - 270,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white.withOpacity(.15),
                                  width: 1),
                              color: Colors.black.withOpacity(.4),
                            ),
                            child: ListView.builder(
                              itemCount: itemnameslist.length,
                              itemBuilder: (BuildContext context, int index) {
                                int prodnum = index + 1;
                                for (int i = 0; i < itemnameslist.length; i++) {
                                  tnamescon.add(TextEditingController());
                                }

                                for (int i = 0; i < itemnameslist.length; i++) {
                                  tidcon.add(TextEditingController());
                                }

                                for (int i = 0; i < itemnameslist.length; i++) {
                                  tpricecon.add(TextEditingController());
                                }

                                for (int i = 0; i < itemnameslist.length; i++) {
                                  tsizecon.add(TextEditingController());
                                }

                                return Container(
                                  margin: EdgeInsets.only(bottom: 25),
                                  padding: EdgeInsets.all(7.0),
                                  child: Column(
                                    children: <Widget>[
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15)),
                                      new Text(
                                        'Item #' + prodnum.toString(),
                                        textAlign: TextAlign.center,
                                        style: new TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18.0,
                                            color: Colors.white),
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5)),
                                      TextFormField(
                                          controller: tnamescon[index]
                                            ..text = '${itemnameslist[index]}',
                                          readOnly: true,
                                          decoration: new InputDecoration(
                                            labelText: "Name of product ",
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
                                              //_upprice = newValue;
                                            });
                                          },
                                          keyboardType: TextInputType.number),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15)),
                                      TextFormField(
                                          controller: tsizecon[index]
                                            ..text = '${itemsizeslist[index]}',
                                          readOnly: true,
                                          decoration: new InputDecoration(
                                            labelText: "Size ",
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
                                              //_upprice = newValue;
                                            });
                                          },
                                          keyboardType: TextInputType.number),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15)),
                                      TextFormField(
                                          controller: tpricecon[index]
                                            ..text =
                                                '${formattedval.format(double.parse(itempriceslist[index]))}',
                                          readOnly: true,
                                          decoration: new InputDecoration(
                                            labelText: "Price (GH¢) ",
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
                                              // _upprice = newValue;
                                            });
                                          },
                                          keyboardType: TextInputType.number),
                                      Visibility(
                                        visible: false,
                                        child: TextFormField(
                                            controller: tidcon[index]
                                              ..text = '${itemidslist[index]}',
                                            decoration: new InputDecoration(
                                              labelText: "Product ID ",
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
                                                // _upprice = newValue;
                                              });
                                            },
                                            keyboardType: TextInputType.number),
                                      ),
                                      new Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 15)),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          itemtidlist.removeAt(index);
                                          itemidslist.removeAt(index);
                                          itemnameslist.removeAt(index);
                                          itemsizeslist.removeAt(index);
                                          itempriceslist.removeAt(index);
                                          if (itemidslist.isNotEmpty &&
                                              itemtidlist.isNotEmpty &&
                                              itemnameslist.isNotEmpty &&
                                              itemsizeslist.isNotEmpty &&
                                              itempriceslist.isNotEmpty) {
                                            clearitems();
                                          } else {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MyShoppingPage(
                                                          shopname:
                                                              widget.shopname,
                                                          location:
                                                              widget.location,
                                                        )));
                                          }
                                        },
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 7)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 1,
                            height: 145,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white.withOpacity(.15),
                                  width: 1),
                              color: Colors.pink[900]!.withOpacity(.4),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(14),
                                  bottomRight: Radius.circular(14)),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 1,
                              height: 115,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.4),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(14),
                                    bottomRight: Radius.circular(14)),
                              ),
                              child: Visibility(
                                visible: _calcvisible,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(5.0),
                                      child: TextFormField(
                                          controller:
                                              _totalitempricescontroller,
                                          decoration: new InputDecoration(
                                            hintText: "Total ",
                                          ),
                                          onSaved: (newValue) {
                                            setState(() {
                                              //_upprice = newValue;
                                            });
                                          },
                                          keyboardType: TextInputType.number),
                                    ),
                                    new Padding(
                                        padding: const EdgeInsets.only(top: 5)),
                                    Visibility(
                                      visible: _savevisible,
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
                                            backgroundColor: Colors.pink[900], // Replace `color` with `backgroundColor`
                                            foregroundColor: Colors.white, // Replace `textColor` with `foregroundColor`
                                          ),
                                          child: Text(
                                            "Save purchase data",
                                            style: TextStyle(fontSize: 15, color: Colors.white),
                                          ),
                                          onPressed: () {
                                            final form = _formkeyAddProduct.currentState;
                                            if (form!.validate()) {
                                              form.save();
                                              String? message = 'Please wait, items sold are being recorded..';
                                              showsnackbar(message, "Okay");
                                              recorditems();
                                            }
                                          },
                                        )
                                        ,
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink[100]!.withOpacity(.75),
        onPressed: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MyHomePage(
                        title: 'Madam Rita\'s Enterprise',
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
