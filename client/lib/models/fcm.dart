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
    required this.coin,
    required this.price,
    this.above: true,
    this.date,
  });

  String? id;
  String idDevice;
  String coin;
  double price;
  bool above;
  int? date;

  factory Fcm.fromJson(Map<String, dynamic> json) => Fcm(
        id: json["id"],
        idDevice: json["id_device"],
        coin: json["coin"],
        price: json["price"].toDouble(),
        above: json["above"] ?? true,
        date: json["date"],
      );
  factory Fcm.fromSnap(DocumentSnapshot snap) => Fcm(
        id: snap.id,
        idDevice: snap.get("id_device"),
        coin: snap.get("coin"),
        price: snap.get("price") is int
            ? (snap.get("price") as int).toDouble()
            : snap.get("price"),
        above: snap.get("above") ?? true,
        date: snap.get("date"),
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "id_device": idDevice,
        "coin": coin,
        "price": price,
        "above": above,
        "date": date,
      };
}
