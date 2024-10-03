import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../products_model.dart';
import '../DatabaseHelper.dart';
import '../Models/Utility.dart';
import '../Views/StaggeredTiles.dart';
import 'HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaggeredGridPage extends StatefulWidget {
  final notesViewType;

  final String? title, shopname, location;
  const StaggeredGridPage(
      {required Key key, this.notesViewType, required this.title, required this.shopname, required this.location})
      : super(key: key);
  @override
  _StaggeredGridPageState createState() => _StaggeredGridPageState();
}

class _StaggeredGridPageState extends State<StaggeredGridPage> {
  var noteDB = DBProvider();
  List<Map<String, dynamic>> _allNotesInQueryResult = [];
  viewType? notesViewType;
  SharedPreferences? sharedpref;
  String? _user = '';

  @override
  void initState() {
    super.initState();
    this.notesViewType = widget.notesViewType;
    initializesharedpref();
  }

  initializesharedpref() async {
    sharedpref = await SharedPreferences.getInstance();
    _user = sharedpref!.getString('user')!;
    // widget.shopname, widget.location = sharedpref.getString('shopname');
  }

  @override
  void setState(fn) {
    super.setState(fn);
    this.notesViewType = widget.notesViewType;
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey _stagKey = GlobalKey();

    print("update needed?: ${CentralStation.updateNeeded}");
    if (CentralStation.updateNeeded) {
      retrieveAllNotesFromDatabase();
    }
    return Container(
        child: Padding(
      padding: _paddingForView(context),
      child: new StaggeredGrid.count(
        key: _stagKey,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        crossAxisCount: _colForStaggeredView(context),
        children: List.generate(_allNotesInQueryResult.length, (i) {
          return _tileGenerator(i);
        }),

      ),
    ));
  }

  int _colForStaggeredView(BuildContext context) {
    if (widget.notesViewType == viewType.List) return 1;
    // for width larger than 600 on grid mode, return 3 irrelevant of the orientation to accommodate more notes horizontally
    return MediaQuery.of(context).size.width > 600 ? 3 : 2;
  }

  /*List<StaggeredGridTile> _tilesForView() {
    // Generate staggered tiles for the view based on the current preference.
    return List.generate(_allNotesInQueryResult.length, (index) {
      return StaggeredGridTile.fit();
    });
  }*/

  EdgeInsets _paddingForView(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double padding;
    double top_bottom = 8;
    if (width > 500) {
      padding = (width) * 0.05; // 5% padding of width on both side
    } else {
      padding = 8;
    }
    return EdgeInsets.only(
        left: padding, right: padding, top: top_bottom, bottom: top_bottom);
  }

  MyStaggeredTile _tileGenerator(int i) {
    return MyStaggeredTile(
        Note(
            _allNotesInQueryResult[i]["id"],
            _allNotesInQueryResult[i]["title"] == null
                ? ""
                : utf8.decode(_allNotesInQueryResult[i]["title"]),
            _allNotesInQueryResult[i]["content"] == null
                ? ""
                : utf8.decode(_allNotesInQueryResult[i]["content"]),
            DateTime.fromMillisecondsSinceEpoch(
                _allNotesInQueryResult[i]["date_created"] * 1000),
            DateTime.fromMillisecondsSinceEpoch(
                _allNotesInQueryResult[i]["date_last_edited"] * 1000),
            Color(_allNotesInQueryResult[i]["note_color"]),
            widget.shopname,
            widget.location),
        "",
        widget.shopname,
        widget.location);
  }

  void retrieveAllNotesFromDatabase() {
    // queries for all the notes from the database ordered by latest edited note. excludes archived notes.
    var _testData = noteDB.selectAllNotes();
    _testData.then((value) {
      setState(() {
        this._allNotesInQueryResult = value;
        CentralStation.updateNeeded = false;
      });
    });
  }
}
