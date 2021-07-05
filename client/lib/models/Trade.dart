// To parse this JSON data, do
//
//     final trade = tradeFromJson(jsonString);

import 'dart:convert';

Trade tradeFromJson(String str) => Trade.fromJson(json.decode(str));

String tradeToJson(Trade data) => json.encode(data.toJson());

class Trade {
  Trade({
    required this.tid,
    required this.date,
    required this.type,
    required this.price,
    required this.amount,
  });

  int tid;
  int date;
  String type;
  double price;
  double amount;

  factory Trade.fromJson(Map<String, dynamic> json) => Trade(
        tid: json["tid"],
        date: json["date"],
        type: json["type"],
        price: json["price"].toDouble(),
        amount: json["amount"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "tid": tid,
        "date": date,
        "type": type,
        "price": price,
        "amount": amount,
      };
}
