class AllContainer {
    List<Containrs> containers;
    String error;

    AllContainer({
        required this.containers,
        required this.error,
    });

    factory AllContainer.fromJson(Map<String, dynamic> json) => AllContainer(
        containers: List<Containrs>.from(json["containers"].map((x) => Containrs.fromJson(x))),
        error: json["error"],
    );

    Map<String, dynamic> toJson() => {
        "containers": List<dynamic>.from(containers.map((x) => x.toJson())),
        "error": error,
    };
}

class Containrs {
    int id;
    String contNumber;
    String contWeight;
    String contParcelsCount;
    String contRemarks;

    Containrs({
        required this.id,
        required this.contNumber,
        required this.contWeight,
        required this.contParcelsCount,
        required this.contRemarks,
    });

    factory Containrs.fromJson(Map<String, dynamic> json) => Containrs(
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