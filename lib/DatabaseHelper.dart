import 'dart:async';
import 'dart:io' as io;
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:store_stock/products_model.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  // DBProvider._();
  //static final DBProvider db = DBProvider._();
  Database? _database;
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  Future<Database> get database async {
    if (_database != null) return _database!;

    // if await database is null we instantiate it
    _database = await initDB();
    return _database!;
  }

  static initDB() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String? path = join(documentsDirectory.path, "mreDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute(
          """CREATE TABLE products ( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, product_name TEXT ,prodimg TEXT, shopname TEXT, location TEXT, product_name_id TEXT UNIQUE)""");

      await db.execute(
          """CREATE TABLE product_prices ( pp_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, product_id TEXT, product_size TEXT, price TEXT, shopname TEXT, location TEXT, product_price_id TEXT UNIQUE)""");

      await db.execute(
          """CREATE TABLE product_quantity (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,pid TEXT, product_id TEXT UNIQUE,product_size TEXT, shopname TEXT, location TEXT)""");

      await db.execute(
          """CREATE TABLE stock_tab (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, product_id TEXT UNIQUE, product_name TEXT,product_size TEXT,date_sold TEXT, price TEXT , sold_by TEXT, shopname TEXT, location TEXT)""");

      await db.execute(
          """CREATE TABLE notes(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, title BLOB, content BLOB, date_created INTEGER, date_last_edited INTEGER, note_color INTEGER, is_archived INTEGER, shopname TEXT, location TEXT)""");

      await db.execute(
          """CREATE TABLE workers(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, firstname TEXT, lastname TEXT,  password TEXT, picture TEXT, role TEXT, date_added TEXT, initial_salary TEXT, current_salary TEXT, contact TEXT, address TEXT, salary_raise_date TEXT, shopname TEXT, worker_id TEXT UNIQUE, location TEXT)""");

      await db.execute(
          """CREATE TABLE shops(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, shopname TEXT , location TEXT, shop_id TEXT UNIQUE) """);

      await db.execute(
          """CREATE TABLE payments(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, userid TEXT, payment_id TEXT UNIQUE, date_paid TEXT, amount_paid TEXT, shopname TEXT, location TEXT) """);
    });
  }

  newProductName(ProductsName productname) async {
    var db = await database;
    await db.transaction((txn) async {
      return await txn.rawInsert(
          "INSERT into products (product_name, prodimg, shopname, location)"
          " VALUES (?,?,?,?)",
          [
            productname.prodname,
            productname.img,
            productname.shopname,
            productname.location
          ]);
    });
  }

  newShopName(Shops shops) async {
    var db = await database;
    await db.transaction((txn) async {
      return await txn.rawInsert(
          "INSERT into shops (shopname, location)"
          " VALUES (?,?)",
          [shops.name, shops.location]);
    });
  }

  newProducts(Products products) async {
    final db = await database;

    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT into product_quantity (pid,product_id, product_size, shopname,location)"
        " VALUES (?,?,?,?,?)",
        [
          products.pid,
          products.prodid,
          products.size,
          products.shopname,
          products.location
        ]);
    return raw;
  }

  newProductPrice(ProductsPrices productsPrices) async {
    final db = await database;

    var raw = await db.rawInsert(
        "INSERT into product_prices (product_id, product_size, price, shopname, location)"
        " VALUES (?,?,?,?,?)",
        [
          productsPrices.pid,
          productsPrices.size,
          productsPrices.price,
          productsPrices.shopname,
          productsPrices.location
        ]);
    return raw;
  }

  newWorker(Workers workers) async {
    final db = await database;

    var raw = await db.rawInsert(
        "INSERT into workers (firstname, lastname, password,picture, role, date_added, initial_salary, current_salary, contact, address, shopname, worker_id, location)"
        " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",
        [
          workers.firstname,
          workers.lastname,
          workers.password,
          workers.picture,
          workers.role,
          workers.date_added,
          workers.initial_salary,
          workers.initial_salary,
          workers.contact,
          workers.address,
          workers.shopname,
          workers.worker_id,
          workers.location
        ]);
    return raw;
  }

  newsoldItems(SoldProducts soldProducts) async {
    final db = await database;
    var results = await db.insert("stock_tab", soldProducts.toMap());
    return results;
  }

  Future<int> deleteproducts(List data) async {
    String inData = '';
    for (int id in data) {
      inData += '$id,';
    }
    String? iddel = inData.substring(0, inData.length - 1);
    var dbclient = await database;
    int delete = await dbclient
        .rawUpdate('DELETE FROM product_quantity  where id IN ($iddel)');
    return delete;
  }

  Future<int> delsoldItems(List idlist) async {
    var dbclient = await database;
    String inData = '';
    for (var id in idlist) {
      inData += '"$id",';
    }
    String? regex = "\\[|\\]";
    String? iddel = inData.substring(0, inData.length - 1);
    var res, finalstring, sortedid, finalid;
    finalid = idlist.toString().replaceAll(new RegExp(regex), '');
    finalstring = '\'' + finalid.split(',').join('\',\'') + '\'';
    sortedid = finalstring.replaceAll(new RegExp(r"\s\b|\b\s"), "");
    var delete = await dbclient.rawUpdate(
        'DELETE FROM product_quantity  where product_id IN ($sortedid)');
    return delete;
  }

  updateProductPrices(ProductsPrices productsPrices) async {
    final db = await database;
    var res = await db.update("product_prices", productsPrices.toMap(),
        where:
            "product_id = ? and product_size = ? and shopname = ? and location = ?",
        whereArgs: [
          productsPrices.pid,
          productsPrices.size,
          productsPrices.shopname,
          productsPrices.location
        ]);
    return res;
  }

  //specific product
  //SELECT *, count(pq.product_id) as numofproducts FROM `products` left join product_quantity pq on pq.pid = products.product_name  WHERE product_name = 'Baby Dress' group by pq.product_size

  //allproducts
  //SELECT *, count(pq.product_id) as numofproducts FROM `products` left join product_quantity pq on pq.pid = products.product_name  group by product_name

  Future<List<GeneralProducts>> fetchallproducts(
      String? shop, String? loc) async {
    var dbclient = await database;
    List<Map> list = await dbclient.rawQuery(
        'SELECT *, count(pq.product_id) as numofproducts FROM `products` left join product_quantity pq on pq.pid = products.product_name where products.shopname="$shop" and products.location= "$loc"  group by product_name');
    List<GeneralProducts> productsname = [];
    for (int i = 0; i < list.length; i++) {
      productsname.add(new GeneralProducts(list[i]["product_name"].toString(),
          list[i]["prodimg"].toString(), list[i]["numofproducts"].toString()));
    }
    return productsname;
  }

  Future<List<GeneralProducts>> fetchsearchedproducts(
      String? query, String? shop, String? loc) async {
    var dbclient = await database;
    List<Map> list = await dbclient.rawQuery(
        'SELECT *, count(pq.product_id) as numofproducts FROM `products` left join product_quantity pq on pq.pid = products.product_name where product_name like "%$query%" and pq.shopname="$shop" and pq.location= "$loc"  group by product_name');
    List<GeneralProducts> productsname = [];
    for (int i = 0; i < list.length; i++) {
      productsname.add(new GeneralProducts(list[i]["product_name"].toString(),
          list[i]["prodimg"].toString(), list[i]["numofproducts"].toString()));
    }
    return productsname;
  }

  Future<List<SpecificProducts>> fetchspecificproducts(
      String? productname, String? shop, String? loc) async {
    var dbclient = await database;
    List<Map> list = await dbclient.rawQuery(
        'SELECT *, count(pq.product_id) as numofproducts FROM `products` left join product_quantity pq on pq.pid = products.product_name left join product_prices on product_prices.product_id = pq.pid and product_prices.product_size = pq.product_size  WHERE product_name = "$productname" and pq.shopname="$shop" and pq.location= "$loc" group by pq.product_size');
    List<SpecificProducts> productsname = [];
    for (int i = 0; i < list.length; i++) {
      productsname.add(new SpecificProducts(
          list[i]["product_name"].toString(),
          list[i]["product_size"].toString(),
          list[i]["prodimg"].toString(),
          list[i]["numofproducts"].toString(),
          list[i]["price"].toString(),
          list[i]["shopname"].toString(),
          list[i]["location"].toString()));
    }
    return productsname;
  }

  Future<List<Workers>> fetchallworkers(
      String? shopname, String? location) async {
    var dbclient = await database;
    List<Map> list = await dbclient.rawQuery(
        'SELECT * FROM `workers` where shopname="$shopname" and location= "$location"');
    List<Workers> workers = [];
    for (int i = 0; i < list.length; i++) {
      workers.add(new Workers(
        list[i]["firstname"].toString(),
        list[i]["lastname"].toString(),
        list[i]["password"].toString(),
        list[i]["picture"].toString(),
        list[i]["role"].toString(),
        list[i]["date_added"].toString(),
        list[i]["initial_salary"].toString(),
        list[i]["current_salary"].toString(),
        list[i]["contact"].toString(),
        list[i]["address"].toString(),
        list[i]["salary_raise_date"].toString(),
        list[i]["shopname"].toString(),
        list[i]["worker_id"].toString(),
        list[i]["location"].toString(),
      ));
    }
    return workers;
  }

  Future<List<Shops>> fetchavailableshops() async {
    var dbclient = await database;
    List<Map> list = await dbclient.rawQuery('SELECT * FROM `shops`');
    List<Shops> shops = [];
    for (int i = 0; i < list.length; i++) {
      shops.add(new Shops(list[i]["shopname"].toString(),
          list[i]["location"].toString(), list[i]["shop_id"].toString()));
    }
    return shops;
  }

  getUnsoldProduct(int id) async {
    final db = await database;
    String? query =
        'SELECT * FROM product_quantity left join products on products.id = product_quantity.pid' +
            'left join product_prices on product_prices.product_id = product_quantity.pid and product_prices.product_size = product_quantity.product_size' +
            'WHERE product_quantity.pid = $id';
    List<Map> res = await db.rawQuery(query);
    return res;
  }

  Future<bool> insert(Map<String, dynamic> data) async {
    return await _database!.insert('products', data) > 0;
  }

  void loadsampledata() async {
    Map<String, String> map = Map();
    for (int i = 0; i < 10; i++) {
      map['Item'] = "item: $i";
      insert(map);
    }
  }

  Future<List<String>?> getProductsNamesList() async {
    final db = await database;
    String? query = 'SELECT * FROM  products';
    final res = await db.rawQuery(query);
    if (res.length == 0) return null;
    return res.map((Map<String, dynamic> row) {
      return row["product_name"] as String;
    }).toList();
  }

  downloadproductnames(ModifiedProductsName productsName) async {
    final db = await database;
    var results = await db.insert("products", productsName.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return results;
  }

  downloadproductquantities(ModifiedProducts products) async {
    final db = await database;
    var results = await db.insert("product_quantity", products.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return results;
  }

  downloadproductprices(ModifiedProductsPrices productsPrices) async {
    final db = await database;
    var results = await db.insert("product_prices", productsPrices.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return results;
  }

  downloadstockdata(ModifiedSoldProducts soldProducts) async {
    final db = await database;
    var results = await db.insert("stock_tab", soldProducts.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return results;
  }

  downloadworkersdata(ModifiedWorkers workers) async {
    final db = await database;
    var results = await db.insert("workers", workers.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return results;
  }

  downloadshopsdata(ModifiedShops shops) async {
    final db = await database;
    var results = await db.insert("shops", shops.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return results;
  }

  Future<List<ProductsName>> fetchProductsNamesList(
      String? shop, String? loc) async {
    var dbclient = await database;
    List<Map> list = await dbclient.rawQuery(
        'SELECT * FROM  products where shopname = "$shop" and location="$loc"');
    List<ProductsName> productsname = [];
    for (int i = 0; i < list.length; i++) {
      productsname.add(new ProductsName(
          list[i]["product_name"],
          list[i]["prodimg"],
          list[i]["shopname"],
          list[i]["location"],
          list[i]["product_name_id"].toString()));
    }
    return productsname;
  }

  Future<List<Products>> fetchAllProducts() async {
    var dbclient = await database;
    List<Map> list = await dbclient.rawQuery(
        'SELECT * FROM  product_quantity left join product_prices on product_prices.product_id=product_quantity.pid and product_prices.product_size = product_quantity.product_size left join products on products.product_name = product_quantity.pid');
    List<Products> productsname = [];
    for (int i = 0; i < list.length; i++) {
      productsname.add(new Products(
          list[i]["product_name"],
          list[i]["product_id"],
          list[i]["product_size"],
          list[i]["prodimg"],
          list[i]["price"],
          list[i]["shopname"],
          list[i]["location"]));
    }
    return productsname;
  }

  Future<List<SoldProducts>> fetchsearchedsoldProducts(
      String? startdate,
      String? enddate,
      String mode,
      String? product,
      String? shop,
      String? loc) async {
    List<Map> list = [];
    var dbclient = await database;

    if (mode.contains("daily")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%Y-%m-%d", date(date_sold))  = "$startdate" and product_name like "%$product%" and shopname="$shop" and location="$loc"  GROUP by `product_name`,`product_size`');
    } else if (mode.contains("weekly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where date_sold >= "$startdate" and date_sold <= "$enddate"  and product_name like "%$product%" and shopname="$shop" and location="$loc"   GROUP by `product_name`,`product_size`');
    } else if (mode.contains("monthly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%m", `date_sold`) = "$startdate" and strftime("%Y", `date_sold`) = "$enddate" and product_name like "%$product%" and shopname="$shop" and location="$loc"  GROUP by `product_name`,`product_size`');
    } else if (mode.contains("yearly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%Y", `date_sold`) = "$startdate" and product_name like "%$product%" and shopname="$shop" and location="$loc"  GROUP by `product_name`,`product_size`');
    }

    List<SoldProducts> productsname = [];
    for (var i = 0; i < list.length; i++)
      productsname.add(new SoldProducts(
        list[i]["product_name"].toString(),
        list[i]["product_size"].toString(),
        list[i]["totalprods"].toString(),
        list[i]["totalprice"].toString(),
        list[i]["date_sold"].toString(),
        list[i]["sold_by"].toString(),
        list[i]["shopname"].toString(),
        list[i]["location"].toString(),
      ));

    return productsname;
  }

  Future<List<SoldProducts>> fetchindividualsearchedsoldProducts(
      String? startdate,
      String? enddate,
      String mode,
      String? product,
      String? shop,
      String? loc,
      String? soldby) async {
    List<Map> list = [];
    var dbclient = await database;

    if (mode.contains("daily")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%Y-%m-%d", date(date_sold))  = "$startdate" and product_name like "%$product%" and shopname="$shop" and location="$loc" and sold_by = "$soldby"  GROUP by `product_name`,`product_size`');
    } else if (mode.contains("weekly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where date_sold >= "$startdate" and date_sold <= "$enddate"  and product_name like "%$product%" and shopname="$shop" and location="$loc" and sold_by = "$soldby"   GROUP by `product_name`,`product_size`');
    } else if (mode.contains("monthly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%m", `date_sold`) = "$startdate" and strftime("%Y", `date_sold`) = "$enddate" and product_name like "%$product%" and shopname="$shop" and location="$loc" and sold_by = "$soldby"  GROUP by `product_name`,`product_size`');
    } else if (mode.contains("yearly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%Y", `date_sold`) = "$startdate" and product_name like "%$product%" and shopname="$shop" and location="$loc" and sold_by = "$soldby"  GROUP by `product_name`,`product_size`');
    }

    List<SoldProducts> productsname = [];
    for (var i = 0; i < list.length; i++)
      productsname.add(new SoldProducts(
        list[i]["product_name"].toString(),
        list[i]["product_size"].toString(),
        list[i]["totalprods"].toString(),
        list[i]["totalprice"].toString(),
        list[i]["date_sold"].toString(),
        list[i]["sold_by"].toString(),
        list[i]["shopname"].toString(),
        list[i]["location"].toString(),
      ));

    return productsname;
  }

  Future<List<SoldProducts>> fetchindividualworkersearchedsoldProducts(
      String? startdate,
      String? enddate,
      String mode,
      String? product,
      String? shop,
      String? loc,
      String? soldby) async {
    List<Map> list = [];
    var dbclient = await database;

    if (mode.contains("daily")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%Y-%m-%d", date(date_sold))  = "$startdate" and product_name like "%$product%" and shopname="$shop" and location="$loc" and sold_by = "$soldby"  GROUP by `product_name`,`product_size`');
    } else if (mode.contains("weekly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where date_sold >= "$startdate" and date_sold <= "$enddate"  and product_name like "%$product%" and shopname="$shop" and location="$loc" and sold_by = "$soldby"   GROUP by `product_name`,`product_size`');
    } else if (mode.contains("monthly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%m", `date_sold`) = "$startdate" and strftime("%Y", `date_sold`) = "$enddate" and product_name like "%$product%" and shopname="$shop" and location="$loc" and sold_by = "$soldby"  GROUP by `product_name`,`product_size`');
    } else if (mode.contains("yearly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%Y", `date_sold`) = "$startdate" and product_name like "%$product%" and shopname="$shop" and location="$loc" and sold_by = "$soldby"  GROUP by `product_name`,`product_size`');
    }

    List<SoldProducts> productsname = [];
    for (var i = 0; i < list.length; i++)
      productsname.add(new SoldProducts(
        list[i]["product_name"].toString(),
        list[i]["product_size"].toString(),
        list[i]["totalprods"].toString(),
        list[i]["totalprice"].toString(),
        list[i]["date_sold"].toString(),
        list[i]["sold_by"].toString(),
        list[i]["shopname"].toString(),
        list[i]["location"].toString(),
      ));

    return productsname;
  }

  Future<List<Soldby>> fetchsoldby(String? shop, String? loc) async {
    List<Map> list;
    var dbclient = await database;
    list = await dbclient.rawQuery(
        "SELECT * FROM `workers` WHERE `shopname` = '$shop' and `location` = '$loc'");
    List<Soldby> uname = [];
    for (var i = 0; i < list.length; i++)
      uname.add(new Soldby(
          list[i]["firstname"].toString() +
              " " +
              list[i]["lastname"].toString(),
          list[i]["picture"].toString()));

    return uname;
  }

  Future<List<SoldProducts>> fetchsoldProducts(String? startdate, String? enddate,
      String mode, String? shop, String? loc) async {
    List<Map> list = [];
    var dbclient = await database;

    if (mode.contains("daily")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%Y-%m-%d", date(date_sold)) = "$startdate" and shopname="$shop" and location="$loc"  GROUP by `product_name`,`product_size`');
    } else if (mode.contains("weekly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where date_sold >= "$startdate" and date_sold <= "$enddate" and shopname="$shop" and location="$loc"  GROUP by `product_name`,`product_size`');
    } else if (mode.contains("monthly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%m", date(date_sold)) = "$startdate" and strftime("%Y", date(date_sold)) = "$enddate"  and shopname="$shop" GROUP by `product_name`,`product_size`');
    } else if (mode.contains("yearly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%Y", `date_sold`) = "$startdate" and shopname="$shop" and location="$loc"   GROUP by `product_name`,`product_size`');
    }

    List<SoldProducts> productsname = [];
    for (var i = 0; i < list.length; i++)
      productsname.add(new SoldProducts(
        list[i]["product_name"].toString(),
        list[i]["product_size"].toString(),
        list[i]["totalprods"].toString(),
        list[i]["totalprice"].toString(),
        list[i]["date_sold"].toString(),
        list[i]["sold_by"].toString(),
        list[i]["shopname"].toString(),
        list[i]["location"].toString(),
      ));

    return productsname;
  }

  Future<List<SoldProducts>> fetchindividualsoldProducts(
      String? startdate,
      String? enddate,
      String mode,
      String? shop,
      String? loc,
      String? solby) async {
    List<Map> list = [];
    var dbclient = await database;

    if (mode.contains("daily")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%Y-%m-%d", date(date_sold)) = "$startdate" and shopname="$shop" and location="$loc" and sold_by = "$solby"  GROUP by `product_name`,`product_size`');
    } else if (mode.contains("weekly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where date_sold >= "$startdate" and date_sold <= "$enddate" and shopname="$shop" and location="$loc" and sold_by = "$solby"  GROUP by `product_name`,`product_size`');
    } else if (mode.contains("monthly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%m", date(date_sold)) = "$startdate" and strftime("%Y", date(date_sold)) = "$enddate" and sold_by = "$solby"  and shopname="$shop" and location="$loc" GROUP by `product_name`,`product_size`');
    } else if (mode.contains("yearly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%Y", `date_sold`) = "$startdate" and shopname="$shop" and location="$loc" and sold_by = "$solby"   GROUP by `product_name`,`product_size`');
    }

    List<SoldProducts> productsname = [];
    for (var i = 0; i < list.length; i++)
      productsname.add(new SoldProducts(
        list[i]["product_name"].toString(),
        list[i]["product_size"].toString(),
        list[i]["totalprods"].toString(),
        list[i]["totalprice"].toString(),
        list[i]["date_sold"].toString(),
        list[i]["sold_by"].toString(),
        list[i]["shopname"].toString(),
        list[i]["location"].toString(),
      ));

    return productsname;
  }

//$hostUrl/Madam_Rita_s_Enterprise/connection.php
  Future<List<SoldProducts>> fetchindividualsoldProductsone(
      String? startdate,
      String? enddate,
      String  mode,
      String? shop,
      String? loc,
      String? seller) async {
    List<Map> list = [];
    var dbclient = await database;

    if (mode.contains("daily")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%Y-%m-%d", date(date_sold)) = "$startdate" and shopname="$shop" and location="$loc" and sold_by="$seller" GROUP by `product_name`,`product_size`');
    } else if (mode.contains("weekly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where date_sold >= "$startdate" and date_sold <= "$enddate" and shopname="$shop" and location="$loc" and sold_by="$seller" GROUP by `product_name`,`product_size`');
    } else if (mode.contains("monthly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%m", date(date_sold)) = "$startdate" and strftime("%Y", date(date_sold)) = "$enddate" and sold_by="$seller" and shopname="$shop" and location="$loc" GROUP by `product_name`,`product_size`');
    } else if (mode.contains("yearly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%Y", `date_sold`) = "$startdate" and shopname="$shop" and location="$loc" and sold_by="$seller"  GROUP by `product_name`,`product_size`');
    }

    List<SoldProducts> productsname = [];
    for (var i = 0; i < list.length; i++)
      productsname.add(new SoldProducts(
        list[i]["product_name"].toString(),
        list[i]["product_size"].toString(),
        list[i]["totalprods"].toString(),
        list[i]["totalprice"].toString(),
        list[i]["date_sold"].toString(),
        list[i]["sold_by"].toString(),
        list[i]["shopname"].toString(),
        list[i]["location"].toString(),
      ));

    return productsname;
  }

  Future<String> fetcharraysoldProducts(String? startdate, String? enddate,
      String mode, String? shop, String? loc) async {
    //List<Map> list;
    var dbclient = await database;
    List<Map> list = [];
    List allsolditems = [];

    if (mode.contains("daily")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%Y-%m-%d", date(date_sold)) = "$startdate" and shopname="$shop" and location="$loc" GROUP by `product_name`,`product_size`');
    } else if (mode.contains("weekly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%Y-%m-%d", date(date_sold)) >= "$startdate" and strftime("%Y-%m-%d", date(date_sold)) <= "$enddate" and shopname="$shop" and location="$loc"  GROUP by `product_name`,`product_size`');
    } else if (mode.contains("monthly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%m", `date_sold`) = "$startdate" and strftime("%Y", `date_sold`) = "$enddate" and shopname="$shop" and location="$loc" GROUP by `product_name`,`product_size`');
    } else if (mode.contains("yearly")) {
      list = await dbclient.rawQuery(
          'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where strftime("%Y", `date_sold`) = "$startdate" and shopname="$shop" and location="$loc"  GROUP by `product_name`,`product_size`');
    }

    for (int i = 0; i < list.length; i++) {
      var itemsmap = {
        '"product_name"': '"${list[i]["product_name"].toString()}"',
        '"product_size"': '"${list[i]["product_size"].toString().trimLeft()}"',
        '"totalproducts"': '"${list[i]["totalprods"].toString()}"',
        '"price"': '"${list[i]["totalprice"].toString()}"',
        '"date_sold"': '"${list[i]["date_sold"].toString()}"',
      };
      allsolditems.add(itemsmap);

      /*

      List<SoldProducts> productsname = [];
      for (var i = 0; i < list.length; i++)
        productsname.add(new SoldProducts(
            list[i]["product_name"].toString(),
            list[i]["product_size"].toString(),
            list[i]["totalprods"].toString(),
            list[i]["totalprice"].toString(),
            list[i]["date_sold"].toString()));

      return productsname;*/
    }

    if (list.length > 0) {
      String? proddetails = allsolditems.toString();
      return proddetails;
    } else {
      return 'emptydata';
    }
  }

  Future<List<Salesdata>> fetchProductsSalesList(
      String? shop, String? loc) async {
    var dbclient = await database;
    List<Map> list = await dbclient.rawQuery(
        'SELECT *, count(`product_id`) as totalprods, sum(`price`) as totalprice  FROM `stock_tab` where shopname="$shop" and location ="$loc" GROUP by `product_name`,`product_size`');

    List<Salesdata> productsprice = [];
    //Salesdata(this.productname, this.productsize, this.totalproducts, this.price,
    //this.datesold);
    for (int i = 0; i < list.length; i++) {
      productsprice.add(new Salesdata(
          list[i]["product_name"],
          list[i]["product_size"],
          list[i]["totalprods"].toString(),
          double.tryParse(list[i]["price"])!,
          list[i]["date_sold"],
          list[i]["shopname"].toString(),
          list[i]["location"].toString()));
    }
    return productsprice;
  }

  Future<List<ProductsPrices>> fetchProductsPriceList(
      String? pname, String? psize, String? shopname, String? loc) async {
    var dbclient = await database;
    List<Map> list = await dbclient.rawQuery(
        'SELECT * FROM  product_prices where product_id = "$pname" and product_size="$psize" and shopname="$shopname" and location="$loc"');
    List<ProductsPrices> productsprice = [];
    for (int i = 0; i < list.length; i++) {
      productsprice.add(new ProductsPrices(
          list[i]["pid"],
          list[i]["product_size"],
          list[i]["price"],
          list[i]["shopname"],
          list[i]["location"],
          list[i]["product_price_id"].toString()));
    }
    return productsprice;
  }

  Future<List<Shops>> fetchShops() async {
    var dbclient = await database;
    List<Map> list = await dbclient.rawQuery('SELECT * FROM  shops');
    List<Shops> shops = [];
    for (int i = 0; i < list.length; i++) {
      shops.add(new Shops(
          list[i]["shopname"], list[i]["location"], list[i]["shop_id"]));
    }
    return shops;
  }

  Future<String> fetchspecificProductsPriceList(
      String? pname, String? psize, String? shopname, String? loc) async {
    var dbclient = await database;
    var dbquery = await dbclient.rawQuery(
        'SELECT price FROM  product_prices where product_id = "$pname" and product_size="$psize" and shopname="$shopname" and location="$loc"');
    if (dbquery.length > 0) {
      String? prodprice = dbquery.first.values.toString();
      return prodprice;
    } else {
      return 'emptydata';
    }
  }

  Future<String> getspecificProductwithoutcode(String? pname, String? psize,
      String? idlist, String? shopname, String? loc) async {
    var dbclient = await database;
    String? fid;
    if (idlist?.isEmpty ?? true) {
      fid = '';
    } else {
      fid = idlist! + " and ";
    }
    var dbquery = await dbclient.rawQuery(
        'SELECT pr.price as prodprice, pd.product_id, pd.id  FROM `product_prices` pr left join product_quantity pd on pr.product_id = pd.pid and pr.product_size = pd.product_size WHERE $fid pd.pid = "$pname" and pd.product_size = "$psize" and pd.shopname = "$shopname" and pd.location="$loc" order by pd.id  LIMIT 1');
    if (dbquery.length > 0) {
      String? prodprice = dbquery.first.values.toString();
      return prodprice;
    } else {
      return 'emptydata';
    }
  }

  Future<String> getspecificProductwithcode(
      String? pid, String? shopname, String? loc) async {
    var dbclient = await database;
    var dbquery = await dbclient.rawQuery(
        'SELECT pr.price as prodprice, pd.*  FROM `product_prices` pr left join product_quantity pd on pr.product_id = pd.pid and pr.product_size = pd.product_size WHERE pd.product_id = "$pid" and pd.shopname = "$shopname" and pd.location="$loc"  LIMIT 1');
    if (dbquery.length > 0) {
      String? prodDetails = dbquery.first.values.toString();
      return prodDetails;
    } else {
      return 'emptydata';
    }
  }

  Future<List<SoldProducts>> getAllSoldProductsDetails() async {
    final db = await database;
    String? query =
        'SELECT * FROM stock_tab left join products on products.product_name = stock_tab.product_name left join product_prices on product_prices.product_id = products.id GROUP by stock_tab.product_name';
    var res = await db.rawQuery(query);
     List<SoldProducts> list =
       res.isNotEmpty ? res.map((c) => SoldProducts.fromMap(c)).toList() : [];
    return list;
  }

  /*Future<List<ProductsName>> getAllProductsNames() async {
    final db = await database;
    String? query = 'SELECT * FROM  products';
    var res = await db.rawQuery(query);
    List<ProductsName> list =
        res.isNotEmpty ? res.map((c) => ProductsName.fromMap(c)).toList() : [];
    return list;
  }

  static Future<List<Map<String, dynamic>>> getProductsNames() async {
    String? query = 'SELECT * FROM  products';
    var res = await await database.rawQuery(query);
    List<ProductsName> list =
        res.isNotEmpty ? res.map((c) => ProductsName.fromMap(c)).toList() : [];
    return res;
  }*/

  /*getClient(int id) async {
    final db = await database;
    var res = await db.query("Client", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Client.fromMap(res.first) : null;
  }*/

  deleteProduct(SoldProducts soldProducts) async {
    final db = await database;
    return db.delete("product_quantity",
        where: "product_id = ?", whereArgs: [soldProducts.prodid]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from product_quantity");
  }

  static Future<String> dbPath() async {
    String? path = await getDatabasesPath();
    return path;
  }

  Future<int> insertNote(Note note, bool isNew) async {
    // Get a reference to the database
    final Database db = await database;
    print("insert called");

    // Insert the Notes into the correct table.
    await db.insert(
      'notes',
      isNew ? note.toMap(false) : note.toMap(true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (isNew) {
      // get latest note which isn't archived, limit by 1
      var one = await db.query("notes",
          orderBy: "date_last_edited desc",
          where: "is_archived = ?",
          whereArgs: [0],
          limit: 1);
      int latestId = one.first["id"] as int;
      return latestId;
    }
    return note.id;
  }

  Future<bool> copyNote(Note note) async {
    final Database db = await database;
    try {
      await db.insert("notes", note.toMap(false),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (Error) {
      print(Error);
      return false;
    }
    return true;
  }

  Future<bool> archiveNote(Note note) async {
    if (note.id != -1) {
      final Database db = await database;

      int idToUpdate = note.id;

      db.update("notes", note.toMap(true),
          where: "id = ?", whereArgs: [idToUpdate]);
      return true;
    }
    return false;
  }

  Future<bool> deleteNote(Note note) async {
    if (note.id != -1) {
      final Database db = await database;
      try {
        await db.delete("notes",
            where: "id = ? and shopname = ?",
            whereArgs: [note.id, note.shopname]);
        return true;
      } catch (Error) {
        print("Error deleting ${note.id}: ${Error.toString()}");
        return false;
      }
    }
    return false;
  }

  deleteWorkerbyid(String? userid) async {
    final db = await database;
    return db.delete("workers", where: "worker_id = ?", whereArgs: [userid]);
  }

  deleteWorkerbyshop(String? shopname, String? location) async {
    final db = await database;
    return db.delete("workers",
        where: "shopname = ? and location=?", whereArgs: [shopname, location]);
  }

  deleteshop(String? shopname, String? location) async {
    final db = await database;
    return db.delete("shops",
        where: "shopname = ? and location = ?",
        whereArgs: [shopname, location]);
  }

  deleteAllStock() async {
    final db = await database;
    db.rawDelete("delete from stock_tab");
  }

  deleteAllWorkers() async {
    final db = await database;
    db.rawDelete("delete from workers");
  }

  updatesalary(String? userid, String? salary, String? shopname, String? location,
      String? date) async {
    final db = await database;
    var update = await db.rawUpdate(
        'UPDATE `workers` SET  `current_salary` = "$salary", `salary_raise_date`="$date" WHERE `worker_id` = "$userid" and `shopname` = "$shopname" and `location` = "$location"');
    return update;
  }

  Future<List<Map<String, dynamic>>> selectAllNotes() async {
    final Database db = await database;
    // query all the notes sorted by last edited
    var data = await db.query("notes",
        orderBy: "date_last_edited desc",
        where: "is_archived = ?",
        whereArgs: [0]);

    return data;
  }
}
