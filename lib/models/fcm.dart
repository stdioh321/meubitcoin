// To parse this JSON data, do
//
//     final fcm = fcmFromJson(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

Fcm fcmFromJson(String str) => Fcm.fromJson(json.decode(str));

String fcmToJson(Fcm data) => json.encode(data.toJson());

class Fcm {
  Fcm({
    this.id,
    required this.idDevice,
    required this.price,
    required this.date,
  });

  String? id;
  String idDevice;
  double price;
  int date;

  factory Fcm.fromSnap(DocumentSnapshot snap) => Fcm(
        id: snap.id,
        idDevice: snap.get("idDevice"),
        price: snap.get("price") is int
            ? (snap.get("price") as int).toDouble()
            : snap.get("price"),
        date: snap.get("date"),
      );
  factory Fcm.fromJson(Map<String, dynamic> json) => Fcm(
        id: json["id"],
        idDevice: json["idDevice"],
        price: json["price"].toDouble(),
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "idDevice": idDevice,
        "price": price,
        "date": date,
      };
}
