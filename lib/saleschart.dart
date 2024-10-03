import 'dart:ui';
import 'package:store_stock/Utils/customfunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'DatabaseHelper.dart';
import 'dart:async';
import 'products_model.dart';
import 'home.dart';
import 'dart:io';
import 'dart:io' as Io;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dailysalescontainer.dart';
import 'weeklysalescontainer.dart';
import 'monthlysalescontainer.dart';
import 'yearlysalescontainer.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyChartList());
}

class MyChartList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Madam Rita\'s Enterprise',
      home: ChartList(title: 'Madam Rita\'s Enterprise'),
    );
  }
}

class ChartList extends StatefulWidget {
  ChartList({Key? key, this.title, this.shopname, this.location})
      : super(key: key);

  final String? title;
  final String? shopname;
  final String? location;
  @override
  _MyChartState createState() => _MyChartState();
}

class _MyChartState extends State<ChartList>
    with SingleTickerProviderStateMixin {
  String? directory;
  var finaldir;
  List files = [];
  String? imgdir;
  var _scrollController, _tabController;
  int bottomSelectedIndex = 0;
  final formattedval = new NumberFormat("#,##0.00", "en_US");
  @override
  void initState() {
    _scrollController = ScrollController();
    _tabController = TabController(length: 4, vsync: this);
    loadfile();
    super.initState();
  }

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
          backgroundColor: Colors.transparent,
          icon: new Icon(Icons.table_chart_outlined),
          label: 'Daily'),
      BottomNavigationBarItem(
        backgroundColor: Colors.transparent,
        icon: new Icon(Icons.table_chart_outlined),
        label: 'Weekly'

      ),
      BottomNavigationBarItem(
          backgroundColor: Colors.transparent,
          icon: Icon(Icons.table_chart_outlined),
          label: 'Monthly'),
      BottomNavigationBarItem(
          backgroundColor: Colors.transparent,
          icon: Icon(Icons.table_chart_outlined),
          label: 'Yearly'),
      BottomNavigationBarItem(
          backgroundColor: Colors.transparent,
          icon: Icon(Icons.home),
          label: 'Home')
    ];
  }

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  Widget buildPageView() {
    return PageView(
      controller: pageController,
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: <Widget>[
        DailySalesContainer(
          shopname: widget.shopname,
          location: widget.location, key: scaffoldKey, title: '',
        ),
        WeeklySalesContainer(
          shopname: widget.shopname,
          location: widget.location,
        ),
        MonthlySalesContainer(
          shopname: widget.shopname,
          location: widget.location,
        ),
        YearlySalesContainer(
          shopname: widget.shopname,
          location: widget.location,
        )
      ],
    );
  }

  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
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
              child: buildPageView(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.pink[900]!.withOpacity(.5),
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.pink[900],
        unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
            color: Colors.white),
        selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
            color: Colors.white),
        currentIndex: bottomSelectedIndex,
        onTap: (index) {
          if (index == 4) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MyHomePage(
                          shopname: widget.shopname,
                          location: widget.location,
                        )));
          } else {
            bottomTapped(index);
          }
        },
        items: buildBottomNavBarItems(),
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
}
