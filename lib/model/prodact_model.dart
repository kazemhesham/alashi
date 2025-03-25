class AllPrdact {
  List<Product> products;
  List<Containerss> containers;
  String error;

  AllPrdact({
    required this.products,
    required this.containers,
    required this.error,
  });

  factory AllPrdact.fromJson(Map<String, dynamic> json) => AllPrdact(
    products: List<Product>.from(
      json["Products"].map((x) => Product.fromJson(x)),
    ),
    containers: List<Containerss>.from(
      json["containers"].map((x) => Containerss.fromJson(x)),
    ),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "Products": List<dynamic>.from(products.map((x) => x.toJson())),
    "containers": List<dynamic>.from(containers.map((x) => x.toJson())),
    "error": error,
  };
}

class Containerss {
  int id;
  String contNumber;
  String contWeight;
  String contParcelsCount;
  String contRemarks;

  Containerss({
    required this.id,
    required this.contNumber,
    required this.contWeight,
    required this.contParcelsCount,
    required this.contRemarks,
  });

  factory Containerss.fromJson(Map<String, dynamic> json) => Containerss(
    id: json["id"],
    contNumber: json["cont_number"],
    contWeight: json["cont_weight"],
    contParcelsCount: json["cont_parcelsCount"],
    contRemarks: json["contRemarks"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "cont_number": contNumber,
    "cont_weight": contWeight,
    "cont_parcelsCount": contParcelsCount,
    "contRemarks": contRemarks,
  };
}

class Product {
  int id;
  String deliverynumber;
  String quantity;
  String fiQuantity;
  String type;
  DateTime receivingDate;
  int paidamount;
  int remainingaamount;
  int invoiceValue;
  String deliveryaddress;
  Shipmentlocation shipmentlocation;
  String remarks;
  String cmp;
  Dealer dealer;
  Vendor vendor;
  int skipNotifications;

  Product({
    required this.id,
    required this.deliverynumber,
    required this.quantity,
    required this.fiQuantity,
    required this.type,
    required this.receivingDate,
    required this.paidamount,
    required this.remainingaamount,
    required this.invoiceValue,
    required this.deliveryaddress,
    required this.shipmentlocation,
    required this.remarks,
    required this.cmp,
    required this.dealer,
    required this.vendor,
    required this.skipNotifications,
  });
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"] ?? 0,
    // dealerId: json["dealer_id"] ?? 0,
    deliverynumber: json["Deliverynumber"] ?? "غير متوفر",
    quantity: json["Quantity"] ?? "غير متوفر",
    fiQuantity: json["fi_Quantity"] ?? "غير متوفر",
    type: json["Type"] ?? "غير متوفر",

    // ✅ معالجة الحقول التي قد تحتوي على `null`
    receivingDate:
        json["ReceivingDate"] != null
            ? DateTime.tryParse(json["ReceivingDate"]) ?? DateTime.now()
            : DateTime.now(),

    shipmentlocation:
        json["Shipmentlocation"] != null
            ? (shipmentlocationValues.map.containsKey(json["Shipmentlocation"])
                ? shipmentlocationValues.map[json["Shipmentlocation"]]!
                : Shipmentlocation.EMPTY)
            : Shipmentlocation.EMPTY,

    paidamount: json["paidamount"] ?? 0,
    remainingaamount: json["remainingaamount"] ?? 0,
    // totalamount: json["totalamount"] ?? 0,
    invoiceValue: json["InvoiceValue"] ?? 0,
    deliveryaddress: json["Deliveryaddress"] ?? "غير متوفر",

    remarks: json["Remarks"] ?? "لا يوجد",
    cmp: json["cmp"] ?? "0",
    // vendorId: json["vendor_id"] ?? 0,

    // ✅ التأكد من عدم وجود `null` في `dealer`
    dealer:
        json["dealer"] != null
            ? Dealer.fromJson(json["dealer"])
            : Dealer(
              id: 0,
              name: "غير متوفر",
              dealerNumber: "غير متوفر",
              phone: "غير متوفر",

              dealerLang: RLang.AR,
            ),

    // ✅ معالجة `vendor` في حالة `null`
    vendor:
        json["vendor"] != null
            ? Vendor.fromJson(json["vendor"])
            : Vendor(
              id: 0,
              name: "غير متوفر",
              vendorNumber: "غير متوفر",
              phone: "غير متوفر",
              vendorLang: RLang.AR,
            ),
    skipNotifications:
        json["skip_notifications"] != null
            ? int.parse(json["skip_notifications"].toString())
            : 0,
  );

  // factory Product.fromJson(Map<String, dynamic> json) => Product(
  //   id: json["id"],
  //   deliverynumber: json["Deliverynumber"],
  //   quantity: json["Quantity"],
  //   fiQuantity: json["fi_Quantity"],
  //   type: json["Type"],
  //   receivingDate: DateTime.parse(json["ReceivingDate"]),
  //   paidamount: json["paidamount"],
  //   remainingaamount: json["remainingaamount"],
  //   invoiceValue: json["InvoiceValue"],
  //   deliveryaddress: json["Deliveryaddress"],
  //   shipmentlocation: shipmentlocationValues.map[json["Shipmentlocation"]]!,
  //   remarks: json["Remarks"],
  //   cmp: json["cmp"],
  //   dealer: Dealer.fromJson(json["dealer"]),
  //   vendor: Vendor.fromJson(json["vendor"]),
  //   skipNotifications:
  //       json["skip_notifications"] != null
  //           ? int.parse(json["skip_notifications"].toString())
  //           : 0,
  // );

  Map<String, dynamic> toJson() => {
    "id": id,
    "Deliverynumber": deliverynumber,
    "Quantity": quantity,
    "fi_Quantity": fiQuantity,
    "Type": type,
    "ReceivingDate":
        "${receivingDate.year.toString().padLeft(4, '0')}-${receivingDate.month.toString().padLeft(2, '0')}-${receivingDate.day.toString().padLeft(2, '0')}",
    "paidamount": paidamount,
    "remainingaamount": remainingaamount,
    "InvoiceValue": invoiceValue,
    "Deliveryaddress": deliveryaddress,
    "Shipmentlocation": shipmentlocationValues.reverse[shipmentlocation],
    "Remarks": remarks,
    "cmp": cmp,
    "dealer": dealer.toJson(),
    "vendor": vendor.toJson(),
    // "skip_notifications": skipNotifications
  };
}

class Dealer {
  int id;
  String dealerNumber;
  String name;
  String phone;
  RLang dealerLang;

  Dealer({
    required this.id,
    required this.dealerNumber,
    required this.name,
    required this.phone,
    required this.dealerLang,
  });

  factory Dealer.fromJson(Map<String, dynamic> json) => Dealer(
    id: json["id"],
    dealerNumber: json["dealer_number"],
    name: json["name"],
    phone: json["phone"],
    dealerLang: rLangValues.map[json["dealer_lang"]]!,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "dealer_number": dealerNumber,
    "name": name,
    "phone": phone,
    "dealer_lang": rLangValues.reverse[dealerLang],
  };
}

enum RLang { AR, EN, HE, TR }

final rLangValues = EnumValues({
  "ar": RLang.AR,
  "en": RLang.EN,
  "he": RLang.HE,
  "tr": RLang.TR,
});

enum Shipmentlocation { EMPTY, PURPLE, SHIPMENTLOCATION, FLUFFY, TENTACLED }

final shipmentlocationValues = EnumValues({
  "في المستودع": Shipmentlocation.EMPTY,
  "جارٍ تجهيزها للاستلام": Shipmentlocation.FLUFFY,
  "في الميناء": Shipmentlocation.PURPLE,
  "في الطريق إلى الميناء": Shipmentlocation.SHIPMENTLOCATION,
  "تم التسليم": Shipmentlocation.TENTACLED,
});

class Vendor {
  int id;
  String vendorNumber;
  String name;
  String phone;
  RLang vendorLang;

  Vendor({
    required this.id,
    required this.vendorNumber,
    required this.name,
    required this.phone,
    required this.vendorLang,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
    id: json["id"],
    vendorNumber: json["vendor_number"],
    name: json["name"],
    phone: json["phone"],
    vendorLang: rLangValues.map[json["vendor_lang"]]!,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "vendor_number": vendorNumber,
    "name": name,
    "phone": phone,
    "vendor_lang": rLangValues.reverse[vendorLang],
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
