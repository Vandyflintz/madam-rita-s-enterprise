import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'weeklysaleschart.dart';
import 'weeklysalesrecords.dart';
import 'keep_page_alive.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madam Rita\'s Enterprise',
      home: WeeklySalesContainer(),
    );
  }
}

final _scaffoldKey = GlobalKey<ScaffoldState>();
bool pressed = false, _obscuretext = false, _visibility = false;
SnackBar? snackBar;

class WeeklySalesContainer extends StatefulWidget {
  WeeklySalesContainer({Key? key, this.title, this.shopname, this.location})
      : super(key: key);
  final String? title, shopname, location;
  @override
  _MyShoppingPageState createState() => _MyShoppingPageState();
}

class _MyShoppingPageState extends State<WeeklySalesContainer>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int bottomSelectedIndex = 0;
  final Curve _curve = Curves.ease;
  final Duration _duration = Duration(milliseconds: 300);
  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
          backgroundColor: Colors.transparent,
          icon: new Icon(Icons.table_chart_outlined),
          label:  'Sales'),
      BottomNavigationBarItem(
        backgroundColor: Colors.transparent,
        icon: new Icon(Icons.table_chart_outlined),
        label: 'Chart',
      ),
    ];
  }

  PageController subpageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  Widget buildPageView() {
    return PageView(
      controller: subpageController,
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: <Widget>[
        KeepAlivePage(
            child: WeeklySalesRecords(
          shopname: widget.shopname,
          location: widget.location,
        )),
        KeepAlivePage(
            child: WeeklySalesCharts(
          shopname: widget.shopname,
          location: widget.location,
        )),
      ],
    );
  }

  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      subpageController.animateToPage(index,
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: NestedScrollView(
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Container(
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
                  padding: EdgeInsets.all(0.0),
                  width: MediaQuery.of(context).size.width * 1,
                  height: MediaQuery.of(context).size.height * 1,
                  decoration:
                      new BoxDecoration(color: Colors.black.withOpacity(0.4)),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottom),
                    child: buildPageView(),
                  ),
                ),
              ),
            ),
          ],
        ),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[];
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.pink[900]!.withOpacity(.3),
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.pink[900],
        selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
            color: Colors.white),
        unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
            color: Colors.white),
        currentIndex: bottomSelectedIndex,
        onTap: (index) {
          bottomTapped(index);
        },
        items: buildBottomNavBarItems(),
      ),
    );
  }
}
