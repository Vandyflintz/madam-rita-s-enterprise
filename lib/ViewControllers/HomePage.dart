import 'package:flutter/material.dart';
import 'StaggeredView.dart';
import '../products_model.dart';
import 'NotePage.dart';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../Models/Utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum viewType { List, Staggered }

class HomePage extends StatefulWidget {
  HomePage({Key? key, this.title, this.shopname,  this.location})
      : super(key: key);
  final String? title, shopname, location;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var notesViewType;
  SharedPreferences? sharedpref;
  String? _user = '';
  @override
  void initState() {
    notesViewType = viewType.Staggered;
    initializesharedpref();
  }

  initializesharedpref() async {
    sharedpref = await SharedPreferences.getInstance();
    _user = sharedpref!.getString('user')!;
    //widget.shopname, widget.location = sharedpref.getString('shopname');
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: _appBarActions(),
        elevation: 1,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Notes"), systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: _body(),
        right: true,
        left: true,
        top: true,
        bottom: true,
      ),
      bottomSheet: _bottomBar(),
    );
  }

  Widget _body() {
    print(notesViewType);
    return Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
          image: new ExactAssetImage('assets/images/bg.png'),
          fit: BoxFit.fill,
        )),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
          child: Container(
            decoration: new BoxDecoration(color: Colors.black.withOpacity(0.4)),
            child: StaggeredGridPage(
              notesViewType: notesViewType, key: _scaffoldKey, title: widget.title, shopname: widget.shopname, location: widget.location,
            ),
          ),
        ));
  }

  Widget _bottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          child: Text(
            "New Note\n",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          onPressed: () => _newNoteTapped(context),
        )
      ],
    );
  }

  void _newNoteTapped(BuildContext ctx) {
    // "-1" id indicates the note is not new
    var emptyNote = new Note(-1, "", "", DateTime.now(), DateTime.now(),
        Colors.white, widget.shopname, widget.location);
    Navigator.push(
        ctx,
        MaterialPageRoute(
            builder: (ctx) =>
                NotePage(emptyNote, "", widget.shopname, widget.location)));
  }

  void _toggleViewType() {
    setState(() {
      CentralStation.updateNeeded = true;
      if (notesViewType == viewType.List) {
        notesViewType = viewType.Staggered;
      } else {
        notesViewType = viewType.List;
      }
    });
  }

  List<Widget> _appBarActions() {
    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          child: GestureDetector(
            onTap: () => _toggleViewType(),
            child: Icon(
              notesViewType == viewType.List
                  ? Icons.developer_board
                  : Icons.view_headline,
              color: CentralStation.fontColor,
            ),
          ),
        ),
      ),
    ];
  }
}
