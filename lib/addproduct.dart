import 'dart:ui';
import 'dart:io';
import 'dart:io' as Io;
import 'dart:typed_data';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
//import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'Utils/customfunctions.dart';
import 'home.dart';
import 'products_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'DatabaseHelper.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/*void main() {
  runApp(ProductsHome());
}

class ProductsHome extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Madam Rita\'s Enterprise',
      home: ProductsPage(title: 'Madam Rita\'s Enterprise'),
    );
  }
}
*/


class ProductsPage extends StatefulWidget {
  final String text;

  ProductsPage({required Key key, required this.text, required this.title, required this.shopname, required this.location})
      : super(key: key);
  final String title, shopname, location;

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _ProductsPageState extends State<ProductsPage>
    with TickerProviderStateMixin {
  Uint8List bytes = Uint8List(0);
  TextEditingController? _inputController;
  TextEditingController? _outputController;
  List<DropdownMenuItem<String>>? listnames;
  AppState? appstate;
  SharedPreferences? sharedpref;
  String _user = '';

  @override
  void initState() {
    super.initState();
    this._inputController = new TextEditingController();
    this._outputController = new TextEditingController();
    initializesharedpref();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    _selectcontainer(widget.text);
    listnames = [];
    appstate = AppState.free;
  }

  @override
  void dispose() {
    _outputController!.dispose();
    pricetec.dispose();
    super.dispose();
  }

  initializesharedpref() async {
    sharedpref = await SharedPreferences.getInstance();
    _user = sharedpref!.getString('user')!;
    // widget.shopname, widget.location = sharedpref.getString('shopname');
  }

  String _pnameslist = '';

  Future<String> fetchProductsNamesListone() async {
    var dbclient = await DBProvider().database;
    List<Map> list =
        await dbclient.rawQuery('SELECT product_name FROM  products');
    // List<ProductsName> productsname = [];
    for (int i = 0; i < list.length; i++) {
      // productsname.add(new ProductsName(
      //  list[i]["id"], list[i]["product_name"], list[i]["prodimg"]));
      _pnameslist += list[i]["productname"] + ",";
    }
    return _pnameslist!;
  }

  DropdownMenuItem<String> getDropDownWidget(Map<String, dynamic> map) {
    return DropdownMenuItem<String>(
      value: map['id'],
      child: Text(map['product_name']),
    );
  }

  final _formkeyAddProductName = GlobalKey<FormState>();
  final _formkeyAddProduct = GlobalKey<FormState>();
  final _formkeyAddProductPrice = GlobalKey<FormState>();
  final _formkeyUpdateProductPrice = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool pressed = false, _obscuretext = false, _visibility = false;
  SnackBar? snackBar;
  String result = "", _pname ="";

  TextEditingController mytec = TextEditingController();
  TextEditingController pricetec = TextEditingController();

  void showsnackbar(String _message, String _command) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    snackBar = SnackBar(
      duration: const Duration(minutes: 5),
      content: Text(_message),
      action: SnackBarAction(
        label: _command,
        onPressed: () {
          if (_command.contains("Close")) {
          } else if (_command.contains("Retry")) {}
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar!);
  }

  void gohome() {}

  //code to get barcode
  Future _scan() async {
    String? barcode = await scanner.scan();
    if (barcode == null) {
      print('nothing return.');
    } else {
      this._outputController!.text = barcode;

      setState(() {
        mytec.text = barcode;
        //result = barcode;
      });
    }
  }

  var db = DBProvider();
  bool isButtonEnabled = true;
  String fpname = '',
      message = '',
      pid = '',
      _pprice = '',
      _psize = '',
      _ppsize = '',
      _ppname = '',
      _upname = '',
      _upsize = '',
      _upprice = '',
      _radioitem = '';

  String _nameuploadmode = '';
  File? galleryfile, camerafile;
  Color primarycolor = Colors.transparent;
  Color primarycolorname = Colors.pink[900]!;
  Color primarycolorproduct = Colors.grey;
  Color primarycolorprice = Colors.grey;
  Color primarycolorpriceupdate = Colors.grey;
  List<bool> boolList = [true, false, false, false];
  Color btnuploadprimarycolor = Colors.pink[700]!;
  Color btncropprimarycolor = Colors.grey;
  Color btnclearprimarycolor = Colors.grey;

  bool _nameEnabled = false,
      _nameVisibility = true,
      _productEnabled = true,
      _productVisibility = false,
      _priceEnabled = true,
      _priceVisibility = false,
      _priceupdateEnabled = true,
      _priceupdateVisibility = false,
      _uploadbtnenabled = true,
      _cropbtnenabled = false,
      _clearbtnenabled = false;

  void setBoolValue(String value) {
    // Reset all values to false
    for (int i = 0; i < boolList.length; i++) {
      boolList[i] = false;
    }

    // Set the appropriate index to true based on the value
    switch (value) {
      case 'PN':
        boolList[0] = true;
        break;
      case 'PQ':
        boolList[1] = true;
        break;
      case 'PP':
        boolList[2] = true;
        break;
      case 'UPP':
        boolList[3] = true;
        break;
      default:
        break;
    }

    // Trigger a rebuild
    setState(() {});
  }
  Color getColor(int index) {
    return boolList[index] ? Colors.white : Colors.black.withOpacity(.68); // Change colors as needed
  }
  void _selectcontainer(String optionselected) {
    if (optionselected.contains("pname")) {
      setState(() {
        _nameEnabled = false;
        primarycolorname = Colors.pink[900]!;
        _nameVisibility = true;
        primarycolorprice = Colors.grey;
        primarycolorpriceupdate = Colors.grey;
        primarycolorproduct = Colors.grey;
        _productEnabled = true;
        _productVisibility = false;
        _priceEnabled = true;
        _priceVisibility = false;
        _priceupdateEnabled = true;
        _priceupdateVisibility = false;
      });
    }
    if (optionselected.contains("pproduct")) {
      setState(() {
        _nameEnabled = true;
        primarycolorname = Colors.grey;
        _nameVisibility = false;
        primarycolorprice = Colors.grey;
        primarycolorpriceupdate = Colors.grey;
        primarycolorproduct = Colors.pink[900]!;
        _productEnabled = false;
        _productVisibility = true;
        _priceEnabled = true;
        _priceVisibility = false;
        _priceupdateEnabled = true;
        _priceupdateVisibility = false;
      });
    }
    if (optionselected.contains("pprice")) {
      setState(() {
        _nameEnabled = true;
        primarycolorname = Colors.grey;
        primarycolorpriceupdate = Colors.grey;
        _nameVisibility = false;
        primarycolorprice = Colors.pink[900]!;
        primarycolorproduct = Colors.grey;
        _productEnabled = true;
        _productVisibility = false;
        _priceEnabled = false;
        _priceVisibility = true;
        _priceupdateEnabled = true;
        _priceupdateVisibility = false;
      });
    }

    if (optionselected.contains("upprice")) {
      setState(() {
        _nameEnabled = true;
        primarycolorname = Colors.grey;
        _nameVisibility = false;
        primarycolorprice = Colors.grey;
        primarycolorpriceupdate = Colors.pink[900]!;
        primarycolorproduct = Colors.grey;
        _productEnabled = true;
        _productVisibility = false;
        _priceEnabled = true;
        _priceVisibility = false;
        _priceupdateEnabled = false;
        _priceupdateVisibility = true;
      });
    }
  }

  String _imgfile = '', _finalfile = '';
  bool _autovalidatename = false;
  String base64image = '';

  void _showfilepicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height: 150,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    galleryimage();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(15),
                    margin: EdgeInsets.only(right: 30),
                    child: Column(children: [
                      Icon(Icons.photo_library, size: 55, color: Colors.grey),
                      new Text('Gallery')
                    ]),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    cameraimage();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Column(children: [
                      Icon(Icons.photo_camera, size: 55, color: Colors.grey),
                      new Text('Camera')
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  cameraimage() async {
    if (_uploadbtnenabled == true) {
      // ignore: deprecated_member_use
        XFile? gfile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (gfile != null) {
      galleryfile = File(gfile.path);
      final bytes = Io.File(galleryfile!.path).readAsBytesSync();
        _imgfile = galleryfile.toString().split('/').last.split('r').last;
        base64image = base64Encode(bytes);
        _finalfile = _imgfile.substring(0, _imgfile.indexOf('\''));
        setState(() {
          appstate = AppState.picked;
          _uploadbtnenabled = false;
          btnuploadprimarycolor = Colors.grey;
          _cropbtnenabled = true;
          btncropprimarycolor = Colors.pink[700]!;
          _clearbtnenabled = true;
          btnclearprimarycolor = Colors.pink[700]!;
        });
      }
    }
  }

  galleryimage() async {
    if (_uploadbtnenabled == true) {
      // ignore: deprecated_member_use
       XFile? gfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (gfile != null) {
      galleryfile = File(gfile.path);
      final bytes = Io.File(galleryfile!.path).readAsBytesSync();
        _imgfile = galleryfile.toString().split('/').last.split('r').last;
        base64image = base64Encode(bytes);
        _finalfile = _imgfile.substring(0, _imgfile.indexOf('\''));
        setState(() {
          appstate = AppState.picked;
          _uploadbtnenabled = false;
          btnuploadprimarycolor = Colors.grey;
          _cropbtnenabled = true;
          btncropprimarycolor = Colors.pink[700]!;
          _clearbtnenabled = true;
          btnclearprimarycolor = Colors.pink[700]!;
        });
      }
      //showsnackbar(_finalfile, "");
    }
  }

  cropimage() async {
    if (_cropbtnenabled == true) {
        ImageCropper imageCropper = ImageCropper();
    CroppedFile? ocroppedfile = await imageCropper.cropImage(
        sourcePath: galleryfile!.path,

        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Image Cropper',
              toolbarColor: Colors.pink[800],
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Image Cropper',
          ),
          WebUiSettings(
            context: context,
          ),
        ]
    );

    File? croppedfile = File(ocroppedfile!.path);

      if (croppedfile != null) {
        setState(() {
          galleryfile = croppedfile ?? galleryfile;
          final bytes = Io.File(galleryfile!.path).readAsBytesSync();
          _imgfile = galleryfile.toString().split('/').last.split('r').last;
          base64image = base64Encode(bytes);
          _finalfile = _imgfile.substring(0, _imgfile.indexOf('\''));
          appstate = AppState.cropped;
          _uploadbtnenabled = false;
          btnuploadprimarycolor = Colors.grey;
          _cropbtnenabled = true;
          btncropprimarycolor = Colors.pink[700]!;
          _clearbtnenabled = true;
          btnclearprimarycolor = Colors.pink[700]!;
        });
      }
    }
  }

  void clearimage() {
    if (_clearbtnenabled == true) {
      galleryfile = null;
      setState(() {
        appstate = AppState.free;
        _uploadbtnenabled = true;
        btnuploadprimarycolor = Colors.pink[700]!;
        _cropbtnenabled = false;
        btncropprimarycolor = Colors.grey;
        _clearbtnenabled = false;
        btnclearprimarycolor = Colors.grey;
      });
    }
  }

  enableButton() {
    setState(() {
      isButtonEnabled = true;
      primarycolor = Colors.transparent;
    });
  }

  disableButton() {
    setState(() {
      isButtonEnabled = false;
      primarycolor = Colors.grey;
    });
  }

  void generateid(String pname) {
    if (pname?.isEmpty ?? true) {
      showsnackbar("Please select a product", "");
    } else {
      List<String> words = pname.split(" ");
      String initials = "",
          formatteddate =
              DateFormat('yyyyMMddHHmmss').format(DateTime.now()).toString();

      int numofwords = 1;
      if (numofwords < words.length) {
        numofwords = words.length;
      }

      for (var i = 0; i < numofwords; i++) {
        initials += '${words[i][0]}';
      }

      mytec.text = initials + formatteddate;
    }
  }

  String _uploadurl =
      '$hostUrl/Madam_Rita_s_Enterprise/connection.php';
  //inserting product's name into database
  void addproductname(String fpname, String nameuploadmode, File galleryfile,
      String navoption, String randomid) async {
    String _foldername = "MyStockImages";

    final Directory _appDir = await getApplicationDocumentsDirectory();
    final Directory _appDirFolder = Directory('${_appDir.path}/$_foldername/');
    if (galleryfile != null && await galleryfile.exists()) {
      message = 'Please wait, data is being uploaded...';

      String newPath = path.join(_appDirFolder.path, fpname + '.jpg');
      galleryfile.copy(newPath).then((value) async {
        if (nameuploadmode.contains("Online")) {
          int timeout = 15;
          try {
            http.Response response =
                await http.get(Uri.parse(_uploadurl)).timeout(Duration(seconds: timeout));

            if (response.statusCode == 200) {
              //connected, validate email address and contact
              var urlone =
                  "http://$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php";
              var url =
                  "$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php";
              var data = {
                '"pname"': '"${fpname}"',
                '"pimage"': '"${base64image}"',
                '"proname"': '"request"'
              };

              var response = await http.post(
                Uri.parse('$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php'),
                body: <String, String>{
                  "pname": fpname,
                  "pimage": base64image!,
                  "proname": "request",
                  "shopname": widget.shopname,
                  "location": widget.location,
                  "product_name_id": randomid
                },
              );
              print(response.body);

              //await http.post(Uri.parse(url)one, body: data);
              //var response = await http.post(Uri.parse(url), body: data);

              if (jsonDecode(response.body) == "-1") {
                showsnackbar(
                    "Error processing request, please try again later",
                    "Close");
                setState(() {
                  _visibility = !_visibility;
                });
                enableButton();
              } else {
                var prodname = ProductsName(fpname, fpname + ".jpg",
                    widget.shopname, widget.location, randomid);
                var dbhelper = DBProvider();
                dbhelper.newProductName(prodname);
                Future.delayed(Duration(seconds: 1)).then((value) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsPage(
                                text: navoption,
                                shopname: widget.shopname,
                                location: widget.location,
                                key: _scaffoldKey, 
                                title: widget.title,
                                
                              )));
                });
                Future.delayed(Duration(seconds: 2)).then((value) {
                  showsnackbar("Data uploaded successfully", "Close");
                  _selectcontainer(navoption);
                });
              }
            } else {
              showsnackbar("Error connecting to server...", "Retry");
              setState(() {
                _visibility = !_visibility;
              });
              enableButton();
            }
          } on TimeoutException catch (e) {
            print('Timeout Error: $e');
            Future.delayed(Duration(seconds: 3)).then((value) {
              showsnackbar("Connection to server timed out!", "Close");

              setState(() {
                _visibility = !_visibility;
              });
              enableButton();
            });
          } on SocketException catch (e) {
            print('Socket Error: $e');
          } on Error catch (e) {
            Future.delayed(Duration(seconds: 3)).then((value) {
              showsnackbar("Error connecting to server : $e", "Close");
            });
            setState(() {
              _visibility = !_visibility;
            });
            enableButton();
          }
        }
      }).catchError((error) {
        showsnackbar("Error saving image.", "");
      });

      showsnackbar(message, "");
      disableButton();
    } else {
      message = 'Please select an image';
      showsnackbar(message, "Close");
    }
  }

  void addproduct(String pname, String psize, String pid, String uploadmode,
      String navopt) async {
    if (uploadmode.contains("Online")) {
      int timeout = 15;
      try {
        http.Response response =
            await http.get(Uri.parse(_uploadurl)).timeout(Duration(seconds: timeout));

        if (response.statusCode == 200) {
          //connected, validate email address and contact
          var urlone =
              "http://$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php";
          var url =
              "$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php";
          var data = {
            "pname": pname,
            "pid": pid,
            "psize": psize,
            "prodetails": "request",
            "shopname": widget.shopname,
            "location": widget.location
          };

          //await http.post(Uri.parse(url)one, body: data);
          var response = await http.post(Uri.parse(url), body: data);

          if (jsonDecode(response.body) == "-1") {
            showsnackbar(
                "Error processing request, please try again later", "Close");
            setState(() {
              _visibility = !_visibility;
            });
            enableButton();
          } else {
            var prods = Products(pname, pid, psize, "", "", widget.shopname,
                widget.location);
            var dbhelper = DBProvider();
            dbhelper.newProducts(prods);

            Future.delayed(Duration(seconds: 1)).then((value) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductsPage(
                            text: navopt,
                            shopname: widget.shopname,
                            location: widget.location, 
                            key: _scaffoldKey, 
                            title: widget.title,
                          )));
              showsnackbar("Data uploaded successfully", "Close");
              _selectcontainer(navopt);
            });
            Future.delayed(Duration(seconds: 2)).then((value) {
              showsnackbar("Data uploaded successfully", "Close");
              _selectcontainer(navopt);
            });
          }
        } else {
          showsnackbar("Error connecting to server...", "Retry");
          setState(() {
            _visibility = !_visibility;
          });
          enableButton();
        }
      } on TimeoutException catch (e) {
        print('Timeout Error: $e');
        Future.delayed(Duration(seconds: 3)).then((value) {
          showsnackbar("Connection to server timed out!", "Close");

          setState(() {
            _visibility = !_visibility;
          });
          enableButton();
        });
      } on SocketException catch (e) {
        print('Socket Error: $e');
      } on Error catch (e) {
        Future.delayed(Duration(seconds: 3)).then((value) {
          showsnackbar("Error connecting to server : $e", "Close");
        });
        setState(() {
          _visibility = !_visibility;
        });
        enableButton();
      }
    } else {
      var prods = Products(
          pname, pid, psize, "", "", widget.shopname, widget.location);
      var dbhelper = DBProvider();
      await dbhelper.newProducts(prods).then((value) {
        showsnackbar("Data uploaded successfully", "Close");
        Future.delayed(Duration(seconds: 1)).then((value) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductsPage(
                        text: navopt,
                        shopname: widget.shopname,
                        location: widget.location, key: _scaffoldKey, 
                        title: widget.title,
                      )));
        });
      }).catchError((error) {
        showsnackbar("Error occured while uploading data", "Close");
      });
    }
  }

  void addproductprice(String pname, String psize, String price,
      String uploadmode, String navopt, String randomid) async {
    if (uploadmode.contains("Online")) {
      int timeout = 15;
      try {
        http.Response response =
            await http.get(Uri.parse(_uploadurl)).timeout(Duration(seconds: timeout));

        if (response.statusCode == 200) {
          //connected, validate email address and contact
          var urlone =
              "http://$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php";
          var url =
              "$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php";
          var data = {
            "pname": pname,
            "psize": psize,
            "price": price,
            "proprice": "request",
            "shopname": widget.shopname,
            "location": widget.location,
            "product_price_id": randomid
          };

          //await http.post(Uri.parse(url)one, body: data);
          var response = await http.post(Uri.parse(url), body: data);

          if (jsonDecode(response.body) == "-1") {
            showsnackbar(
                "Error processing request, please try again later", "Close");
            setState(() {
              _visibility = !_visibility;
            });
            enableButton();
          } else {
            String randomchars = "ppr" +
                DateFormat('yyyyMMddHHmmss').format(DateTime.now()).toString();
            var prods = ProductsPrices(pname, psize, price, widget.shopname,
                widget.location, randomid);
            var dbhelper = DBProvider();
            dbhelper.newProductPrice(prods);
            Future.delayed(Duration(seconds: 1)).then((value) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductsPage(
                            text: navopt,
                            shopname: widget.shopname,
                            location: widget.location, 
                            key: _scaffoldKey, 
                            title: widget.title,
                          )));
            });
            Future.delayed(Duration(seconds: 2)).then((value) {
              showsnackbar("Data uploaded successfully", "Close");
              _selectcontainer(navopt);
            });
          }
        } else {
          showsnackbar("Error connecting to server...", "Retry");
          setState(() {
            _visibility = !_visibility;
          });
          enableButton();
        }
      } on TimeoutException catch (e) {
        print('Timeout Error: $e');
        Future.delayed(Duration(seconds: 3)).then((value) {
          showsnackbar("Connection to server timed out!", "Close");

          setState(() {
            _visibility = !_visibility;
          });
          enableButton();
        });
      } on SocketException catch (e) {
        print('Socket Error: $e');
      } on Error catch (e) {
        Future.delayed(Duration(seconds: 3)).then((value) {
          showsnackbar("Error connecting to server : $e", "Close");
        });
        setState(() {
          _visibility = !_visibility;
        });
        enableButton();
      }
    }
  }

  void updateproductprice(String upname, String upsize, String upprice,
      String uploadmode, String navopt) async {
    if (uploadmode.contains("Online")) {
      int timeout = 15;
      try {
        http.Response response =
            await http.get(Uri.parse(_uploadurl)).timeout(Duration(seconds: timeout));

        if (response.statusCode == 200) {
          //connected, validate email address and contact
          var urlone =
              "http://$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php";
          var url =
              "$hostUrl/Madam_Rita_s_Enterprise/data_inserts.php";
          var data = {
            "pname": upname,
            "psize": upsize,
            "price": upprice,
            "updproprice": "request",
            "shopname": widget.shopname,
            "location": widget.location
          };

          //await http.post(Uri.parse(url)one, body: data);
          var response = await http.post(Uri.parse(url), body: data);

          if (jsonDecode(response.body) == "-1") {
            showsnackbar(
                "Error processing request, please try again later", "Close");
            setState(() {
              _visibility = !_visibility;
            });
            enableButton();
          } else {
            String randomchars = "pp" +
                DateFormat('yyyyMMddHHmmss').format(DateTime.now()).toString();
            var prods = ProductsPrices(upname, upsize, upprice, widget.shopname,
                widget.location, randomchars);
            var dbhelper = DBProvider();
            dbhelper.updateProductPrices(prods);
            showsnackbar("Data uploaded successfully", "Close");
            Future.delayed(Duration(seconds: 1)).then((value) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductsPage(
                            text: navopt,
                            shopname: widget.shopname,
                            location: widget.location,
                            key: _scaffoldKey,
                            title: widget.title 
                          )));
            });
          }
        } else {
          showsnackbar("Error connecting to server...", "Retry");
          setState(() {
            _visibility = !_visibility;
          });
          enableButton();
        }
      } on TimeoutException catch (e) {
        print('Timeout Error: $e');
        Future.delayed(Duration(seconds: 3)).then((value) {
          showsnackbar("Connection to server timed out!", "Close");

          setState(() {
            _visibility = !_visibility;
          });
          enableButton();
        });
      } on SocketException catch (e) {
        print('Socket Error: $e');
      } on Error catch (e) {
        Future.delayed(Duration(seconds: 3)).then((value) {
          showsnackbar("Error connecting to server : $e", "Close");
        });
        setState(() {
          _visibility = !_visibility;
        });
        enableButton();
      }
    } else {}
  }

  fetchitemprice(String upname, String upsize) async {
    //var prodp = ProductsPrices(upname, upsize, null, null);
    var dbhelper = DBProvider();
    dbhelper
        .fetchspecificProductsPriceList(
            upname, upsize, widget.shopname, widget.location)
        .then((final String value) {
      if (value.contains("emptydata")) {
        showsnackbar("No price data available for product selected", "Close");
        pricetec.text = "";
      } else {
        setState(() {
          String regex = "\\(|\\)";
          String finalvalue = value.replaceAll(new RegExp(regex), '');
          pricetec.text = finalvalue;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            padding: EdgeInsets.all(18.0),
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 1,
            decoration: new BoxDecoration(color: Colors.black.withOpacity(0.4)),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottom),
              child: ListView(shrinkWrap: true, children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 15),
                  padding: EdgeInsets.all(5.0),
                  child: Stack(
                    children: <Widget>[
                      new Container(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.05),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white.withOpacity(.6), width: 1),
                          color: Colors.black.withOpacity(.4),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Wrap(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primarycolorname,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide(
                                          color: Color.fromRGBO(0, 0, 0, 0.09),
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_nameEnabled) {
                                        _selectcontainer("pname");
                                        setBoolValue("PN");
                                      }
                                    },
                                    child: Text(
                                      "Product Name",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12,
                                         color: getColor(0)
                                      ),
                                    ),
                                  )
                                  ,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  height: 40,
                                  child: new ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primarycolorproduct,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide(
                                          color: Color.fromRGBO(0, 0, 0, 0.09),
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_productEnabled) {
                                        _selectcontainer("pproduct");
                                        setBoolValue("PQ");
                                      }
                                    },
                                    child: Text(
                                      "Product Quantity",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12,
                                          color: getColor(1)
                                      ),
                                    ),
                                  )
                                  ,
                                ),
                              ],
                            ),
                            new Padding(
                                padding: const EdgeInsets.only(bottom: 20)),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    height: 30,
                                  )
                                ]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  height: 40,
                                  child: new ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primarycolorprice,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide(
                                          color: Color.fromRGBO(0, 0, 0, 0.09),
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_priceEnabled) {
                                        _selectcontainer("pprice");
                                        setBoolValue("PP");
                                      }
                                    },
                                    child: Text(
                                      "Product Price",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12,
                                          color: getColor(2)
                                      ),
                                    ),
                                  )
                                  ,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  height: 40,
                                  child: new ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primarycolorpriceupdate,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide(
                                          color: Color.fromRGBO(0, 0, 0, 0.09),
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_priceupdateEnabled) {
                                        _selectcontainer("upprice");
                                        setBoolValue("UPP");
                                      }
                                    },
                                    child: Text(
                                      "Update Product Price",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12,
                                          color: getColor(3)
                                      ),
                                    ),
                                  )
                                  ,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        child: Container(
                          margin: EdgeInsets.only(left: 7),
                          padding: EdgeInsets.all(5),
                          transform: Matrix4.translationValues(0, -17.0, 0),
                          child: Text(
                            'Menu',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'serif',
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.85),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                                color: Colors.white.withOpacity(.6), width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                    visible: _nameVisibility,
                    child: new Padding(padding: const EdgeInsets.only(top: 6))),
                Visibility(
                  visible: _nameVisibility,
                  child: new Container(

                    margin: EdgeInsets.only(top: 15),
                    padding: EdgeInsets.all(15.0),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          child: Container(
                            margin: EdgeInsets.only(left: 7),
                            padding: EdgeInsets.all(5),
                            transform: Matrix4.translationValues(-8, -30.0, 0),
                            child: Text(
                              'Add Product Name',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'serif',
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.85),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                  color: Colors.white.withOpacity(.6), width: 1),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: new Stack(
                            children: <Widget>[
                              new Form(
                                autovalidateMode: AutovalidateMode.always,
                                key: _formkeyAddProductName,
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
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: <Widget>[
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15)),
                                      Text(
                                        'Product Image',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'serif',
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15)),
                                      displayslectedfile(galleryfile),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5)),
                                      Container(
                                        width: 150,
                                        child: new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            new RawMaterialButton(
                                              onPressed: () {
                                                if (_uploadbtnenabled == true) {
                                                  _showfilepicker(context);
                                                }
                                              },
                                              elevation: 5.0,
                                              fillColor: btnuploadprimarycolor,
                                              child: Icon(
                                                Icons.attach_file_rounded,
                                                size: 15.0,
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 1),
                                              ),
                                              padding: EdgeInsets.all(6.0),
                                              shape: CircleBorder(
                                                side: BorderSide(
                                                    color: Colors.white,
                                                    width: 2),
                                              ),
                                              constraints:
                                                  BoxConstraints.expand(
                                                      width: 35, height: 35),
                                            ),
                                            new RawMaterialButton(
                                              onPressed: () {
                                                cropimage();
                                              },
                                              elevation: 5.0,
                                              fillColor: btncropprimarycolor,
                                              child: Icon(
                                                Icons.crop,
                                                size: 15.0,
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 1),
                                              ),
                                              padding: EdgeInsets.all(6.0),
                                              shape: CircleBorder(
                                                side: BorderSide(
                                                    color: Colors.white,
                                                    width: 2),
                                              ),
                                              constraints:
                                                  BoxConstraints.expand(
                                                      width: 35, height: 35),
                                            ),
                                            new RawMaterialButton(
                                              onPressed: () {
                                                clearimage();
                                              },
                                              elevation: 5.0,
                                              fillColor: btnclearprimarycolor,
                                              child: Icon(
                                                Icons.clear,
                                                size: 15.0,
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 1),
                                              ),
                                              padding: EdgeInsets.all(6.0),
                                              shape: CircleBorder(
                                                side: BorderSide(
                                                    color: Colors.white,
                                                    width: 2),
                                              ),
                                              constraints:
                                                  BoxConstraints.expand(
                                                      width: 35, height: 35),
                                            ),
                                          ],
                                        ),
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10)),
                                      new TextFormField(
                                        decoration: new InputDecoration(
                                          labelText:
                                              "Enter product's name here",
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
                                            fpname = newValue!;
                                          });
                                        },
                                        keyboardType: TextInputType.text,
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15)),
                                      new DropdownButtonFormField(
                                          value: _nameuploadmode,
                                          decoration: new InputDecoration(
                                            labelText: "Upload Mode",
                                          ),
                                          items: <String>[
                                            '',
                                            'Online',
                                          ].map((String value) {
                                            return new DropdownMenuItem<String>(
                                                value: value,
                                                child: new Text(value));
                                          }).toList(),
                                          validator: (value) {
                                            if (value?.isEmpty ?? true) {
                                              return 'This field is required';
                                            }
                                          },
                                          onSaved: (newValue) {
                                            setState(() {
                                              _nameuploadmode = newValue!;
                                            });
                                          },
                                          onChanged: (newValue) {
                                            setState(() {
                                              _nameuploadmode = newValue!;
                                            });
                                          }),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 22)),
                                      FractionallySizedBox(
                                        widthFactor: 0.40,
                                        child: new ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              side: BorderSide(
                                                color: Colors.white.withOpacity(.6),
                                                width: 2,
                                              ),
                                            ),
                                            backgroundColor: primarycolor,
                                          ),
                                          onPressed: () {
                                            if (isButtonEnabled) {
                                              final form = _formkeyAddProductName.currentState;
                                              if (form!.validate()) {
                                                form.save();
                                                String randomchars = "pn" +
                                                    DateFormat('yyyyMMddHHmmss').format(DateTime.now()).toString();
                                                addproductname(
                                                  fpname,
                                                  _nameuploadmode,
                                                  galleryfile!,
                                                  "pname",
                                                  randomchars,
                                                );
                                              } else {
                                                setState(() {
                                                  _autovalidatename = true;
                                                });
                                              }
                                            }
                                          },
                                          child: Text(
                                            "+ Add",
                                            style: TextStyle(fontSize: 15, color: Colors.white),
                                          ),
                                        )
                                        ,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.45),
                      border: Border.all(
                          color: Colors.white.withOpacity(.6), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Visibility(
                    visible: _productVisibility,
                    child:
                        new Padding(padding: const EdgeInsets.only(top: 25))),
                Visibility(
                  visible: _productVisibility,
                  child: new Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: EdgeInsets.all(15.0),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          child: Container(
                            margin: EdgeInsets.only(left: 7),
                            padding: EdgeInsets.all(5),
                            transform: Matrix4.translationValues(0, -30.0, 0),
                            child: Text(
                              'Add Products',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'serif',
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.85),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                  color: Colors.white.withOpacity(.6), width: 1),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: new Stack(
                            children: <Widget>[
                              new Form(
                                key: _formkeyAddProduct,
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
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: <Widget>[
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15)),
                                      FutureBuilder<List<ProductsName>>(
                                        future: DBProvider()
                                            .fetchProductsNamesList(
                                                widget.shopname,
                                                widget.location),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<List<ProductsName>>
                                                snapshot) {
                                          if (snapshot.hasData) {
                                            return DropdownButtonFormField(
                                                decoration: new InputDecoration(
                                                  labelText: "Product Name",
                                                ),
                                                items: snapshot.data!
                                                    .map((location) {
                                                  return DropdownMenuItem(
                                                    child: new Text(
                                                        location.prodname!),
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
                                                    _pname = newValue!;
                                                  });
                                                },
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    _pname = newValue!;
                                                  });
                                                });
                                          } else {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                        },
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15)),
                                      new DropdownButtonFormField(
                                          value: _psize,
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
                                          ].map((String value) {
                                            return new DropdownMenuItem<String>(
                                                value: value,
                                                child: new Text(value));
                                          }).toList(),
                                          validator: (value) {
                                            if (value?.isEmpty ?? true) {
                                              return 'This field is required';
                                            }
                                          },
                                          onSaved: (newValue) {
                                            setState(() {
                                              _psize = newValue!;
                                            });
                                          },
                                          onChanged: (newValue) {
                                            setState(() {
                                              _psize = newValue!;
                                            });
                                          }),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15)),
                                      new TextFormField(
                                        readOnly: true,
                                        controller: mytec,
                                        decoration: new InputDecoration(
                                          labelText: "Product id",
                                          prefixIcon: IconButton(
                                            icon: Padding(
                                              padding: EdgeInsets.all(3),
                                              child: ImageIcon(
                                                AssetImage(
                                                    'assets/images/generate_qrcode.png'),
                                              ),
                                            ),
                                            onPressed: () {
                                              generateid(_pname);
                                            },
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Padding(
                                              padding: EdgeInsets.all(3),
                                              child: ImageIcon(
                                                AssetImage(
                                                    'assets/images/scanner.png'),
                                              ),
                                            ),
                                            onPressed: () {
                                              _scan();
                                            },
                                          ),
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
                                            pid = newValue!;
                                          });
                                        },
                                        keyboardType: TextInputType.text,
                                      ),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15)),
                                      new DropdownButtonFormField(
                                          value: _radioitem,
                                          decoration: new InputDecoration(
                                            labelText: "Upload Mode",
                                          ),
                                          items: <String>[
                                            '',
                                            'Online',
                                          ].map((String value) {
                                            return new DropdownMenuItem<String>(
                                                value: value,
                                                child: new Text(value));
                                          }).toList(),
                                          validator: (value) {
                                            if (value?.isEmpty ?? true) {
                                              return 'This field is required';
                                            }
                                          },
                                          onSaved: (newValue) {
                                            setState(() {
                                              _radioitem = newValue!;
                                            });
                                          },
                                          onChanged: (newValue) {
                                            setState(() {
                                              _radioitem = newValue!;
                                            });
                                          }),
                                      new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 22)),
                                      FractionallySizedBox(
                                        widthFactor: 0.40,
                                        child: new ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              side: BorderSide(
                                                color: Colors.white.withOpacity(.6),
                                                width: 2,
                                              ),
                                            ),
                                            backgroundColor: primarycolor,
                                          ),
                                          onPressed: () {
                                            if (isButtonEnabled) {
                                              final form = _formkeyAddProduct.currentState;
                                              if (form!.validate()) {
                                                form.save();
                                                message = 'Please wait, data is being uploaded...';

                                                showsnackbar(message, "");
                                                disableButton();
                                                addproduct(
                                                  _pname,
                                                  _psize,
                                                  pid,
                                                  _radioitem,
                                                  "pproduct",
                                                );
                                                setState(() {
                                                  _visibility = _visibility;
                                                });
                                              }
                                            }
                                          },
                                          child: Text(
                                            "+ Add",
                                            style: TextStyle(fontSize: 15, color: Colors.white),
                                          ),
                                        )
                                        ,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.45),
                      border: Border.all(
                          color: Colors.white.withOpacity(.6), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Visibility(
                    visible: _priceVisibility,
                    child:
                        new Padding(padding: const EdgeInsets.only(top: 25))),
                Visibility(
                  visible: _priceVisibility,
                  child: new Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: EdgeInsets.all(15.0),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          child: Container(
                            margin: EdgeInsets.only(left: 7),
                            padding: EdgeInsets.all(5),
                            transform: Matrix4.translationValues(-12, -30.0, 0),
                            child: Text(
                              'Add Product Price',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'serif',
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.85),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                  color: Colors.white.withOpacity(.6), width: 1),
                            ),
                          ),
                        ),
                        new Form(
                          key: _formkeyAddProductPrice,
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
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
                                new DropdownButtonFormField(
                                    value: _radioitem,
                                    decoration: new InputDecoration(
                                      labelText: "Upload Mode",
                                    ),
                                    items: <String>[
                                      '',
                                      'Online',
                                    ].map((String value) {
                                      return new DropdownMenuItem<String>(
                                          value: value, child: new Text(value));
                                    }).toList(),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'This field is required';
                                      }
                                    },
                                    onSaved: (newValue) {
                                      setState(() {
                                        _radioitem = newValue!;
                                      });
                                    },
                                    onChanged: (newValue) {
                                      setState(() {
                                        _radioitem = newValue!;
                                      });
                                    }),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
                                new FutureBuilder<List<ProductsName>>(
                                  future: DBProvider().fetchProductsNamesList(
                                      widget.shopname, widget.location),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<List<ProductsName>>
                                          snapshot) {
                                    if (snapshot.hasData) {
                                      return DropdownButtonFormField(
                                          decoration: new InputDecoration(
                                            labelText: "Product Name",
                                          ),
                                          items: snapshot.data!.map((location) {
                                            return DropdownMenuItem(
                                              child:
                                                  new Text(location.prodname!),
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
                                              _ppname = newValue!;
                                            });
                                          },
                                          onChanged: (newValue) {
                                            setState(() {
                                              _ppname = newValue!;
                                            });
                                          });
                                    } else {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                  },
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
                                new DropdownButtonFormField(
                                    value: _ppsize,
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
                                    ].map((String value) {
                                      return new DropdownMenuItem<String>(
                                          value: value, child: new Text(value));
                                    }).toList(),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'This field is required';
                                      }
                                    },
                                    onSaved: (newValue) {
                                      setState(() {
                                        _ppsize = newValue!;
                                      });
                                    },
                                    onChanged: (newValue) {
                                      setState(() {
                                        _ppsize = newValue!;
                                      });
                                    }),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
                                new TextFormField(
                                    decoration: new InputDecoration(
                                      labelText: "Product price ",
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
                                        _pprice = newValue!;
                                      });
                                    },
                                    keyboardType: TextInputType.number),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 22)),
                                FractionallySizedBox(
                                  widthFactor: 0.40,
                                  child: new ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide(
                                          color: Colors.white.withOpacity(.6),
                                          width: 2,
                                        ),
                                      ),
                                      backgroundColor: primarycolor,
                                    ),
                                    onPressed: () {
                                      if (isButtonEnabled) {
                                        final form = _formkeyAddProductPrice.currentState;
                                        if (form!.validate()) {
                                          form.save();
                                          message = 'Please wait, data is being uploaded...';
                                          String randomchars = "ppr" +
                                              DateFormat('yyyyMMddHHmmss').format(DateTime.now()).toString();
                                          showsnackbar(message, "");
                                          disableButton();
                                          addproductprice(
                                            _ppname,
                                            _ppsize,
                                            _pprice,
                                            _radioitem,
                                            "pprice",
                                            randomchars,
                                          );
                                          setState(() {
                                            _visibility = _visibility;
                                          });
                                        }
                                      }
                                    },
                                    child: Text(
                                      "+ Add",
                                      style: TextStyle(fontSize: 15, color: Colors.white),
                                    ),
                                  )
                                  ,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.45),
                      border: Border.all(
                          color: Colors.white.withOpacity(.6), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Visibility(
                    visible: _priceupdateVisibility,
                    child:
                        new Padding(padding: const EdgeInsets.only(top: 25))),
                Visibility(
                  visible: _priceupdateVisibility,
                  child: new Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: EdgeInsets.all(15.0),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          child: Container(
                            margin: EdgeInsets.only(left: 7),
                            padding: EdgeInsets.all(5),
                            transform: Matrix4.translationValues(-12, -30.0, 0),
                            child: Text(
                              'Update Product Price',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'serif',
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.85),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                  color: Colors.white.withOpacity(.6), width: 1),
                            ),
                          ),
                        ),
                        new Form(
                          key: _formkeyUpdateProductPrice,
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
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
                                new DropdownButtonFormField(
                                    value: _radioitem,
                                    decoration: new InputDecoration(
                                      labelText: "Upload Mode",
                                    ),
                                    items: <String>[
                                      '',
                                      'Online',
                                    ].map((String value) {
                                      return new DropdownMenuItem<String>(
                                          value: value, child: new Text(value));
                                    }).toList(),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'This field is required';
                                      }
                                    },
                                    onSaved: (newValue) {
                                      setState(() {
                                        _radioitem = newValue!;
                                      });
                                    },
                                    onChanged: (newValue) {
                                      setState(() {
                                        _radioitem = newValue!;
                                      });
                                    }),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
                                FutureBuilder<List<ProductsName>>(
                                  future: DBProvider().fetchProductsNamesList(
                                      widget.shopname, widget.location),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<List<ProductsName>>
                                          snapshot) {
                                    if (snapshot.hasData) {
                                      return DropdownButtonFormField(
                                          decoration: new InputDecoration(
                                            labelText: "Product Name",
                                          ),
                                          items: snapshot.data!.map((location) {
                                            return DropdownMenuItem(
                                              child:
                                                  new Text(location.prodname!),
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
                                              _upname = newValue!;
                                            });
                                          },
                                          onChanged: (newValue) {
                                            setState(() {
                                              _upname = newValue!;
                                            });
                                          });
                                    } else {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                  },
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
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
                                    ].map((String value) {
                                      return new DropdownMenuItem<String>(
                                          value: value, child: new Text(value));
                                    }).toList(),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'This field is required';
                                      }
                                    },
                                    onSaved: (newValue) {
                                      setState(() {
                                        _upsize = newValue!;
                                      });
                                    },
                                    onChanged: (newValue) {
                                      setState(() {
                                        _upsize = newValue!;
                                      });
                                    }),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
                                TextFormField(
                                    controller: pricetec,
                                    decoration: new InputDecoration(
                                      labelText: "Product price ",
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
                                        _upprice = newValue!;
                                      });
                                    },
                                    keyboardType: TextInputType.number),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 15)),
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
                                      backgroundColor: Colors.pink[900],
                                    ),
                                    onPressed: () {
                                      if (_upsize?.isEmpty ?? true) {
                                        showsnackbar("Please select item's size", "Close");
                                      } else if (_upname?.isEmpty ?? true) {
                                        showsnackbar("Please select item's name", "Close");
                                      } else {
                                        fetchitemprice(_upname, _upsize);
                                        showsnackbar("Please wait, price is being fetched", "Close");
                                      }
                                    },
                                    child: Text(
                                      "Get Price",
                                      style: TextStyle(fontSize: 15, color: Colors.white),
                                    ),
                                  )
                                  ,
                                ),
                                new Padding(
                                    padding: const EdgeInsets.only(top: 22)),
                                FractionallySizedBox(
                                  widthFactor: 0.40,
                                  child: new ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide(
                                          color: Colors.white.withOpacity(.6),
                                          width: 2,
                                        ),
                                      ),
                                      backgroundColor: primarycolor,
                                    ),
                                    onPressed: () {
                                      if (isButtonEnabled) {
                                        final form = _formkeyUpdateProductPrice.currentState;
                                        if (form!.validate()) {
                                          form.save();
                                          message = 'Please wait, data is being uploaded...';
                                          String randomchars = "ppr" +
                                              DateFormat('yyyyMMddHHmmss').format(DateTime.now()).toString();
                                          showsnackbar(message, "");
                                          updateproductprice(
                                            _upname,
                                            _upsize,
                                            _upprice,
                                            _radioitem,
                                            "upprice",
                                          );
                                          disableButton();
                                          setState(() {
                                            _visibility = _visibility;
                                          });
                                        }
                                      }
                                    },
                                    child: Text(
                                      "Update",
                                      style: TextStyle(fontSize: 15, color: Colors.white),
                                    ),
                                  )
                                  ,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.45),
                      border: Border.all(
                          color: Colors.white.withOpacity(.6), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                new Padding(padding: const EdgeInsets.only(top: 10)),
              ]),
            ),
          ),
        ),
      )
      /*Builder(
                                                                                                                                                                                                                                                          builder: (BuildContext context) {
                                                                                                                                                                                                                                                            return ListView(
                                                                                                                                                                                                                                                                                                         children: <Widget>[
                                                                                                                                                                                                                                                                                                           Form(
                                                                                                                                                                                                                                                                                                             key: _formkeyAddProduct,
                                                                                                                                                                                                                                                                                                             child: TextFormField(
                                                                                                                                                                                                                                                                                                               decoration: InputDecoration(
                                                                                                                                                                                                                                                                                                                 hintText: "Result",
                                                                                                                                                                                                                                                                                                               ),
                                                                                                                                                                                                                                                                                                               controller: mytec,
                                                                                                                                                                                                                                                                                                               onSaved: (newValue) {
                                                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                                                               },
                                                                                                                                                                                                                                                                                                               style: TextStyle(
                                                                                                                                                                                                                                                                                                                 fontSize: 16,
                                                                                                                                                                                                                                                                                                                 fontFamily: 'serif',
                                                                                                                                                                                                                                                                                                                 fontWeight: FontWeight.bold,
                                                                                                                                                                                                                                                                                                                 color: Colors.amber,
                                                                                                                                                                                                                                                                                                               ),
                                                                                                                                                                                                                                                                                                             ),
                                                                                                                                                                                                                                                                                                           ),
                                                                                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                                                                                         ],
                                                                                                                                                                                                                                                                                                       );
                                                                                                                                                                                                                                                                                                     },
                                                                                                                                                                                                                                                                                                   )*/
      ,
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

  Future _scanPhoto() async {
    String barcode = await scanner.scanPhoto();
    this._outputController!.text = barcode;
  }

  Future _scanPath(String path) async {
    String barcode = await scanner.scanPath(path);
    this._outputController!.text = barcode;
  }

  Future _scanBytes() async {
    XFile? gfile = await _picker.pickImage(source: ImageSource.camera);
    File file = File(gfile!.path);
    Uint8List bytes = file.readAsBytesSync();
    String barcode = await scanner.scanBytes(bytes);
    this._outputController!.text = barcode;
  }

  Future _generateBarCode(String inputCode) async {
    Uint8List result = await scanner.generateBarCode(inputCode);
    this.setState(() => this.bytes = result);
  }

  displayslectedfile(File? galleryfile) {
    return new SizedBox(
      height: 150.0,
      width: 150.0,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.only(left: 0),
          child: galleryfile == null
              ? new Image.asset(
                  'assets/images/pic.png',
                  height: 150.0,
                  width: 150.0,
                )
              : new Image.file(
                  galleryfile,
                  height: 150.0,
                  width: 150.0,
                ),
        ),
      ),
    );
  }
}
