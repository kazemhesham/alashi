class Billofladings {
    List<Billoflading> billoflading;
    String error;

    Billofladings({
        required this.billoflading,
        required this.error,
    });

    factory Billofladings.fromJson(Map<String, dynamic> json) => Billofladings(
        billoflading: List<Billoflading>.from(json["billoflading"].map((x) => Billoflading.fromJson(x))),
        error: json["error"],
    );

    Map<String, dynamic> toJson() => {
        "billoflading": List<dynamic>.from(billoflading.map((x) => x.toJson())),
        "error": error,
    };
}

class Billoflading {
    int id;
    String billOfLadingNumber;
    String containerNum;
    String shipmentNumber;
    String shipmenWeight;
    dynamic shipmentNow;
    String outgoingClearance;
    String incomingClearance;
    String? invoice;
    dynamic policy;
    String? backingList;
    dynamic other;
    String shippingType;
    dynamic truckOne;
    dynamic phoneOne;
    dynamic truckTwo;
    dynamic phoneTwo;
    dynamic truckThree;
    dynamic phoneThree;
    String navigationCompany;
    dynamic flightNumber;
    dynamic airline;
    dynamic deliveryaddress;
    String remarks;

    Billoflading({
        required this.id,
        required this.billOfLadingNumber,
        required this.containerNum,
        required this.shipmentNumber,
        required this.shipmenWeight,
        required this.shipmentNow,
        required this.outgoingClearance,
        required this.incomingClearance,
        required this.invoice,
        required this.policy,
        required this.backingList,
        required this.other,
        required this.shippingType,
        required this.truckOne,
        required this.phoneOne,
        required this.truckTwo,
        required this.phoneTwo,
        required this.truckThree,
        required this.phoneThree,
        required this.navigationCompany,
        required this.flightNumber,
        required this.airline,
        required this.deliveryaddress,
        required this.remarks,
    });

    factory Billoflading.fromJson(Map<String, dynamic> json) => Billoflading(
        id: json["id"],
        billOfLadingNumber: json["billOfLading_number"],
        containerNum: json["container_num"],
        shipmentNumber: json["shipment_number"],
        shipmenWeight: json["Shipmen_weight"],
        shipmentNow: json["ShipmentNow"],
        outgoingClearance: json["outgoing_clearance"],
        incomingClearance: json["incoming_clearance"],
        invoice: json["Invoice"],
        policy: json["Policy"],
        backingList: json["backingList"],
        other: json["other"],
        shippingType: json["ShippingType"],
        truckOne: json["truck_one"],
        phoneOne: json["phone_one"],
        truckTwo: json["truck_two"],
        phoneTwo: json["phone_two"],
        truckThree: json["truck_three"],
        phoneThree: json["phone_three"],
        navigationCompany: json["Navigation_Company"],
        flightNumber: json["Flight_number"],
        airline: json["Airline"],
        deliveryaddress: json["Deliveryaddress"],
        remarks: json["Remarks"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "billOfLading_number": billOfLadingNumber,
        "container_num": containerNum,
        "shipment_number": shipmentNumber,
        "Shipmen_weight": shipmenWeight,
        "ShipmentNow": shipmentNow,
        "outgoing_clearance": outgoingClearance,
        "incoming_clearance": incomingClearance,
        "Invoice": invoice,
        "Policy": policy,
        "backingList": backingList,
        "other": other,
        "ShippingType": shippingType,
        "truck_one": truckOne,
        "phone_one": phoneOne,
        "truck_two": truckTwo,
        "phone_two": phoneTwo,
        "truck_three": truckThree,
        "phone_three": phoneThree,
        "Navigation_Company": navigationCompany,
        "Flight_number": flightNumber,
        "Airline": airline,
        "Deliveryaddress": deliveryaddress,
        "Remarks": remarks,
    };
}