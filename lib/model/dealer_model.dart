class Dealers {
  List<Dealer1> dealers;
  Lang lang;
  String error;

  Dealers({
    required this.dealers,
    required this.lang,
    required this.error,
  });

  factory Dealers.fromJson(Map<String, dynamic> json) => Dealers(
        dealers:
            List<Dealer1>.from(json["dealers"].map((x) => Dealer1.fromJson(x))),
        lang: Lang.fromJson(json["lang"]),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "dealers": List<dynamic>.from(dealers.map((x) => x.toJson())),
        "lang": lang.toJson(),
        "error": error,
      };
}

class Dealer1 {
  int id;
  String name;
  String dealerNumber;
  String phone;
  String email;
  String adress;
  int productCount;
  DealerLang dealerLang;
  int paidamount;

  Dealer1({
    required this.id,
    required this.name,
    required this.dealerNumber,
    required this.phone,
    required this.email,
    required this.adress,
    required this.productCount,
    required this.dealerLang,
    required this.paidamount,
  });

  factory Dealer1.fromJson(Map<String, dynamic> json) => Dealer1(
        id: json["id"] ?? 0, // تعيين قيمة افتراضية إذا كانت `null`
        name: json["name"] ?? "غير معروف",
        dealerNumber: json["dealer_number"]?.toString() ??
            "غير متوفر", // التأكد من عدم وجود null
        phone: json["phone"] ?? "غير متوفر",
        email: json["email"] ?? "غير متوفر",
        adress: json["adress"] ?? "غير متوفر",
        productCount: json["product_count"] ?? 0,
        dealerLang: json["dealer_lang"] != null
            ? dealerLangValues.map[json["dealer_lang"]] ?? DealerLang.AR
            : DealerLang.AR,

        paidamount: json["paidamount"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "dealer_number": dealerNumber,
        "phone": phone,
        "email": email,
        "adress": adress,
        "product_count": productCount,
        "dealer_lang": dealerLangValues.reverse[dealerLang] ?? "ar",
        "paidamount": paidamount,
      };
}

enum DealerLang { AR, EN, HE, TR }

final dealerLangValues = EnumValues({
  "ar": DealerLang.AR,
  "en": DealerLang.EN,
  "he": DealerLang.HE,
  "tr": DealerLang.TR
});

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

  factory Lang.fromJson(Map<String, dynamic> json) => Lang(
        ar: json["ar"],
        en: json["en"],
        tr: json["tr"],
        he: json["he"],
      );

  Map<String, dynamic> toJson() => {
        "ar": ar,
        "en": en,
        "tr": tr,
        "he": he,
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
