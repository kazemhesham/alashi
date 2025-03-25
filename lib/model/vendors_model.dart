class Vendors {
  List<Vendor1> vendors;
  Lang lang;
  String error;

  Vendors({required this.vendors, required this.lang, required this.error});

  factory Vendors.fromJson(Map<String, dynamic> json) => Vendors(
    vendors: List<Vendor1>.from(
      json["Vendors"].map((x) => Vendor1.fromJson(x)),
    ),
    lang: Lang.fromJson(json["lang"]),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "Vendors": List<dynamic>.from(vendors.map((x) => x.toJson())),
    "lang": lang.toJson(),
    "error": error,
  };
}

class Lang {
  String ar;
  String en;
  String tr;
  String he;

  Lang({
    required this.ar,
    required this.en,
    required this.tr,
    required this.he,
  });

  factory Lang.fromJson(Map<String, dynamic> json) =>
      Lang(ar: json["ar"], en: json["en"], tr: json["tr"], he: json["he"]);

  Map<String, dynamic> toJson() => {"ar": ar, "en": en, "tr": tr, "he": he};
}

class Vendor1 {
  int id;
  String name;
  String vendorNumber;
  String phone;
  String email;
  String adress;
  int productCount;
  VendorLang vendorLang;

  Vendor1({
    required this.id,
    required this.name,
    required this.vendorNumber,
    required this.phone,
    required this.email,
    required this.adress,
    required this.productCount,
    required this.vendorLang,
  });

  factory Vendor1.fromJson(Map<String, dynamic> json) => Vendor1(
    id: json["id"] ?? 0,
    name: json["name"] ?? "غير معروف",
    vendorNumber: json["vendor_number"]?.toString() ?? "غير متوفر",
    phone: json["phone"] ?? "غير متوفر",
    email: json["email"] ?? "غير متوفر",
    adress: json["adress"] ?? "غير متوفر",
    productCount: json["product_count"] ?? 0,
    vendorLang:
        json["vendor_lang"] != null
            ? vendorLangValues.map[json["vendor_lang"]] ?? VendorLang.AR
            : VendorLang.AR,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "vendor_number": vendorNumber,
    "phone": phone,
    "email": email,
    "adress": adress,
    "product_count": productCount,
    "vendor_lang": vendorLangValues.reverse[vendorLang],
  };
}

enum VendorLang { AR, EN, HE, TR }

final vendorLangValues = EnumValues({
  "ar": VendorLang.AR,
  "en": VendorLang.EN,
  "he": VendorLang.HE,
  "tr": VendorLang.TR,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
