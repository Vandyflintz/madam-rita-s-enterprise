import 'dart:convert';
import 'package:flutter/material.dart';

String? SoldProductsToJson(Products data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

/*ProductsName ProductsNameFromJson(String? str) {
  final jsonData = json.decode(str);
  return ProductsName.fromMap(jsonData);
}*/

String? ProductsNameToJson(Products data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

String? ProductsPricesToJson(Products data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class ProductsName {
  int? id;
  String? prodname;
  String? img;
  String? shopname;
  String? location;
  String? product_name_id;

  bool operator ==(o) => o is ProductsName && o.prodname == prodname;
  int get hashCode => prodname.hashCode;

  ProductsName(this.prodname, this.img, this.shopname, this.location,
      this.product_name_id);

  /*factory ProductsName.fromMap(Map<String, dynamic> json) => new ProductsName(
        id: json["id"],
        prodname: json["product_name"],
        img: json["prodimg"],
      );*/

  factory ProductsName.fromJson(dynamic json) {
    return ProductsName(json["product_name"], json["prodimg"], json["shopname"],
        json["location"], json["product_name_id"]);
  }

  Map<String, dynamic> toMap() => {
        "product_name": prodname,
        "prodimg": img,
        "shopname": shopname,
        "location": location,
        "product_name_id": product_name_id
      };
}

class ModifiedProductsName {
  int? id;
  String? prodname;
  String? img;
  String? shopname;
  String? location;
  String? product_name_id;

  bool operator ==(o) => o is ModifiedProductsName && o.prodname == prodname;
  int get hashCode => prodname.hashCode;

  ModifiedProductsName(
      {required this.prodname,
      required this.img,
      required this.shopname,
      required this.location,
      required this.product_name_id});

  /*factory ProductsName.fromMap(Map<String, dynamic> json) => new ProductsName(
        id: json["id"],
        prodname: json["product_name"],
        img: json["prodimg"],
      );*/

  factory ModifiedProductsName.fromJson(dynamic json) {
    return ModifiedProductsName(
        prodname: json["product_name"],
        img: json["prodimg"],
        shopname: json["shopname"],
        location: json["location"],
        product_name_id: json["product_name_id"]);
  }

  Map<String, dynamic> toMap() => {
        "product_name": prodname,
        "prodimg": img,
        "shopname": shopname,
        "location": location,
        "product_name_id": product_name_id
      };
}

class ModifiedProductsPrices {
  int? id;
  String? pid;
  String? size;
  String? price;
  String? name;
  String? shopname;
  String? location;
  String? product_price_id;

  ModifiedProductsPrices(
      {required this.pid,
      required this.size,
      required this.price,
      required this.shopname,
      required this.location,
      required this.product_price_id});

  Map<String, dynamic> toMap() => {
        "product_size": size,
        "price": price,
        "product_id": pid,
        "shopname": shopname,
        "location": location,
        "product_price_id": product_price_id
      };

  factory ModifiedProductsPrices.fromJson(Map<String, dynamic> parsedJson) {
    return ModifiedProductsPrices(
        size: parsedJson['product_size'].toString(),
        price: parsedJson['price'].toString(),
        pid: parsedJson['product_id'].toString(),
        shopname: parsedJson['shopname'].toString(),
        location: parsedJson['location'].toString(),
        product_price_id: parsedJson['product_price_id'].toString());
  }
}

class ModifiedProducts {
  String? pid;
  String? prodid;
  String? size;
  String? shopname;
  String? location;

  ModifiedProducts({
    required this.pid,
    required this.prodid,
    required this.size,
    required this.shopname,
    required this.location,
  });

  factory ModifiedProducts.fromJson(Map<String, dynamic> json) {
    return ModifiedProducts(
      pid: json['pid'],
      prodid: json['product_id'],
      size: json['product_size'],
      shopname: json['shopname'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() => {
        "pid": pid,
        "product_id": prodid,
        "product_size": size,
        "shopname": shopname,
        "location": location
      };
}

class Soldby {
  String? uname;
  String? img;

  Soldby(this.uname, this.img);

  factory Soldby.fromJson(dynamic json) {
    return Soldby(json["username"], json["picture"]);
  }

  Map<String, dynamic> toMap() => {"uname": uname, "picture": img};
}

class Shops {
  String? name;
  String? location;
  String? shop_id;

  Shops(this.name, this.location, this.shop_id);

  factory Shops.fromJson(dynamic json) {
    return Shops(json["shopname"], json["location"], json["shop_id"]);
  }

  Map<String, dynamic> toMap() =>
      {"shopname": name, "location": location, "shop_id": shop_id};
}

class ModifiedShops {
  String? name;
  String? location;
  String? shop_id;

  ModifiedShops({required this.name, required this.location, required this.shop_id});

  factory ModifiedShops.fromJson(dynamic json) {
    return ModifiedShops(
        name: json["shopname"],
        location: json["location"],
        shop_id: json["shop_id"]);
  }

  Map<String, dynamic> toMap() =>
      {"shopname": name, "location": location, "shop_id": shop_id};
}

class DeleteSoldProducts {
  String? name;
  String? prodid;
  String? size;
  String? shopname;

  DeleteSoldProducts(this.name, this.prodid, this.size, this.shopname);

  factory DeleteSoldProducts.fromJson(dynamic json) {
    return DeleteSoldProducts(json["pid"], json["product_id"],
        json["product_size"], json["shopname"]);
  }

  Map<String, dynamic> toMap() => {
        "product_name": name,
        "product_id": prodid,
        "product_size": size,
        "shopname": shopname,
      };
}

class Workers {
  String? firstname;
  String? lastname;
  String? password;
  String? picture;
  String? role;
  String? date_added;
  String? initial_salary;
  String? current_salary;
  String? contact;
  String? address;
  String? salary_raise_date;
  String? shopname;
  String? worker_id;
  String? location;

  Workers(
      this.firstname,
      this.lastname,
      this.password,
      this.picture,
      this.role,
      this.date_added,
      this.initial_salary,
      this.current_salary,
      this.contact,
      this.address,
      this.salary_raise_date,
      this.shopname,
      this.worker_id,
      this.location);

  factory Workers.fromJson(dynamic json) {
    return Workers(
      json["firstname"],
      json["lastname"],
      json["password"],
      json["picture"],
      json["role"],
      json["date_added"],
      json["initial_salary"],
      json["current_salary"],
      json["contact"],
      json["address"],
      json["salary_raise_date"],
      json["shopname"],
      json["worker_id"],
      json["location"],
    );
  }

  Map<String, dynamic> toMap() => {
        "firstname": firstname,
        "lastname": lastname,
        "password": password,
        "picture": picture,
        "role": role,
        "date_added": date_added,
        "initial_salary": initial_salary,
        "current_salary": current_salary,
        "contact": contact,
        "address": address,
        "salary_raise_date": salary_raise_date,
        "shopname": shopname,
        "worker_id": worker_id,
        "location": location,
      };
}

class ModifiedWorkers {
  String? firstname;
  String? lastname;
  String? password;
  String? picture;
  String? role;
  String? date_added;
  String? initial_salary;
  String? current_salary;
  String? contact;
  String? address;
  String? salary_raise_date;
  String? shopname;
  String? worker_id;
  String? location;

  ModifiedWorkers(
      {required this.firstname,
      required this.lastname,
      required this.password,
      required this.picture,
      required this.role,
      required this.date_added,
      required this.initial_salary,
      required this.current_salary,
      required this.contact,
      required this.address,
      required this.salary_raise_date,
      required this.shopname,
      required this.worker_id,
      required this.location});

  factory ModifiedWorkers.fromJson(dynamic json) {
    return ModifiedWorkers(
      firstname: json["firstname"],
      lastname: json["lastname"],
      password: json["password"],
      picture: json["picture"],
      role: json["role"],
      date_added: json["date_added"],
      initial_salary: json["initial_salary"],
      current_salary: json["current_salary"],
      contact: json["contact"],
      address: json["address"],
      salary_raise_date: json["salary_raise_date"],
      shopname: json["shopname"],
      worker_id: json["worker_id"],
      location: json["location"],
    );
  }

  Map<String, dynamic> toMap() => {
        "firstname": firstname,
        "lastname": lastname,
        "password": password,
        "picture": picture,
        "role": role,
        "date_added": date_added,
        "initial_salary": initial_salary,
        "current_salary": current_salary,
        "contact": contact,
        "address": address,
        "salary_raise_date": salary_raise_date,
        "shopname": shopname,
        "worker_id": worker_id,
        "location": location,
      };
}

class SoldProducts {
  String? name;
  String? date;
  String? size;
  String? prodid;
  String? price;
  String? sold_by;
  String? shopname;
  String? location;

  SoldProducts(this.name, this.size, this.prodid, this.price, this.date,
      this.sold_by, this.shopname, this.location);

  factory SoldProducts.fromJson(dynamic json) {
    return SoldProducts(
        json["product_name"],
        json["product_size"],
        json["product_id"],
        json["price"],
        json["date_sold"],
        json["sold_by"],
        json["shopname"],
        json["location"]);
  }

  factory SoldProducts.fromMap(Map<String, dynamic> map) {
    return SoldProducts(
        map["product_name"],
        map["product_size"],
        map["product_id"],
        map["price"],
        map["date_sold"],
        map["sold_by"],
        map["shopname"],
        map["location"]);
  }

  Map<String, dynamic> toMap() => {
        "product_name": name,
        "product_size": size,
        "product_id": prodid,
        "price": price,
        "date_sold": date,
        "sold_by": sold_by,
        "shopname": shopname,
        "location": location,
      };
}

class PDFModel {
  List<PDFList>? plist;

  PDFModel({required this.plist});
  PDFModel.fromJson(Map<String, dynamic> json) {
    plist = [];
    json['data'].forEach((v) {
      plist!.add(new PDFList.fromJson(v));
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['data'] = this.plist!.map((v) => v.toMap()).toList();
    return data;
  }
}

class PDFList {
  String? product;
  String? price;
  String? size;
  String? product_id;

  PDFList({required this.product, required this.product_id, required this.size, required this.price});

  factory PDFList.fromJson(dynamic json) {
    return PDFList(
        product: json["product_name"],
        product_id: json["product_id"].toString(),
        size: json["product_size"].toString(),
        price: json["price"].toString());
  }

  Map<String, dynamic> toMap() => {
        "product_name": product,
        "product_id": product_id,
        "product_size": size,
        "price": price
      };
}

class ModifiedSoldProducts {
  String? name;
  String? date;
  String? size;
  String? prodid;
  String? price;
  String? sold_by;
  String? shopname;
  String? location;

  ModifiedSoldProducts(
      {required this.name,
      required this.size,
      required this.prodid,
      required this.price,
      required this.date,
      required this.sold_by,
      required this.shopname,
      required this.location});

  factory ModifiedSoldProducts.fromJson(dynamic json) {
    return ModifiedSoldProducts(
        name: json["product_name"],
        size: json["product_size"],
        prodid: json["product_id"],
        price: json["price"],
        date: json["date_sold"],
        sold_by: json["sold_by"],
        shopname: json["shopname"],
        location: json["location"]);
  }

  Map<String, dynamic> toMap() => {
        "product_name": name,
        "product_size": size,
        "product_id": prodid,
        "price": price,
        "date_sold": date,
        "sold_by": sold_by,
        "shopname": shopname,
        "location": location,
      };
}

class GeneralProducts {
  String? name;
  String? img;
  String? quantity;

  GeneralProducts(
    this.name,
    this.img,
    this.quantity,
  );

  Map<String, dynamic> toMap() => {
        "product_name": name,
        "prodimg": img,
        "product_quantity": quantity,
      };
}

class SpecificProducts {
  String? pname;
  String? size;
  String? img;
  String? quantity;
  String? price;
  String? shopname;
  String? location;

  SpecificProducts(
    this.pname,
    this.size,
    this.img,
    this.quantity,
    this.price,
    this.shopname,
    this.location,
  );

  Map<String, dynamic> toMap() => {
        "pid": pname,
        "product_size": size,
        "prodimg": img,
        "product_quantity": quantity,
        "price": price,
        "shopname": shopname,
        "location": location,
      };
}

class Salesdata {
  final String? productname;
  final String? productsize;
  final String? totalproducts;
  final double price;
  final String? datesold;
  final String? shopname;
  final String? location;

  Salesdata(this.productname, this.productsize, this.totalproducts, this.price,
      this.datesold, this.shopname, this.location);

  factory Salesdata.fromJson(Map<String, dynamic> parsedJson) {
    return Salesdata(
        parsedJson['product_name'].toString(),
        parsedJson['product_size'].toString(),
        parsedJson['totalproducts'].toString(),
        parsedJson['totalprice'] as double,
        parsedJson['datesold'].toString(),
        parsedJson['shopname'].toString(),
        parsedJson['location'].toString());
  }
}

class Products {
  int? id;
  String? pid;
  String? prodid;
  String? size;
  String? img;
  String? price;
  String? shopname;
  String? location;

  Products(
    this.pid,
    this.prodid,
    this.size,
    this.img,
    this.price,
    this.shopname,
    this.location,
  );

  Map<String, dynamic> toMap() => {
        "pid": pid,
        "product_id": prodid,
        "product_size": size,
        "prodimg": img,
        "price": price,
        "shopname": shopname,
        "location": location
      };
  factory Products.fromJson(Map<String, dynamic> parsedJson) {
    return Products(
        parsedJson['pid'].toString(),
        parsedJson['product_id'].toString(),
        parsedJson['product_size'].toString(),
        parsedJson['prodimg'].toString(),
        parsedJson['price'].toString(),
        parsedJson['shopname'].toString(),
        parsedJson['location'].toString());
  }
}

class GeneralPayments {
  String? workername;
  double salaryamount;
  double productssoldamount;
  String? workerid;
  String? payment_id;

  GeneralPayments(this.workername, this.workerid, this.productssoldamount,
      this.salaryamount);

  factory GeneralPayments.fromJson(Map<String, dynamic> parsedJson) {
    return GeneralPayments(
        parsedJson['workername'].toString(),
        parsedJson['workerid'].toString(),
        parsedJson['productssoldamount'] as double,
        parsedJson['salaryamount'] as double);
  }
}

class ProductsPrices {
  int? id;
  String? pid;
  String? size;
  String? price;
  String? name;
  String? shopname;
  String? location;
  String? product_price_id;

  ProductsPrices(this.pid, this.size, this.price, this.shopname, this.location,
      this.product_price_id);

  Map<String, dynamic> toMap() => {
        "product_size": size,
        "price": price,
        "product_id": pid,
        "shopname": shopname,
        "location": location,
        "product_price_id": product_price_id
      };

  factory ProductsPrices.fromJson(Map<String, dynamic> parsedJson) {
    return ProductsPrices(
        parsedJson['product_size'].toString(),
        parsedJson['price'].toString(),
        parsedJson['product_id'].toString(),
        parsedJson['prodimg'].toString(),
        parsedJson['location'].toString(),
        parsedJson['product_price_id'].toString());
  }
}

class Note {
  int id;
  String? title;
  String? content;
  DateTime date_created;
  DateTime date_last_edited;
  Color note_color;
  int is_archived = 0;
  String? shopname;
  String? location;

  Note(this.id, this.title, this.content, this.date_created,
      this.date_last_edited, this.note_color, this.shopname, this.location);

  Map<String, dynamic> toMap(bool forUpdate) {
    var data = {
//      'id': id,  since id is auto incremented in the database we don't need to send it to the insert query.
      'title': utf8.encode(title!),
      'content': utf8.encode(content!),
      'date_created': epochFromDate(date_created),
      'date_last_edited': epochFromDate(date_last_edited),
      'note_color': note_color.value,
      'is_archived': is_archived,
      'shopname': shopname,
      'location': location //  for later use for integrating archiving
    };
    if (forUpdate) {
      data["id"] = this.id;
    }
    return data;
  }

// Converting the date time object into int representing seconds passed after midnight 1st Jan, 1970 UTC
  int epochFromDate(DateTime dt) {
    return dt.millisecondsSinceEpoch ~/ 1000;
  }

  void archiveThisNote() {
    is_archived = 1;
  }
}
