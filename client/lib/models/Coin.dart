// To parse this JSON data, do
//
//     final coin = coinFromJson(jsonString);

import 'dart:convert';

Coin coinFromJson(String str) => Coin.fromJson(json.decode(str));

String coinToJson(Coin data) => json.encode(data.toJson());

class Coin {
  Coin({
    required this.ticker,
  });

  List<Ticker> ticker;

  factory Coin.fromJson(Map<String, dynamic> json) => Coin(
        ticker:
            List<Ticker>.from(json["ticker"].map((x) => Ticker.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ticker": List<dynamic>.from(ticker.map((x) => x.toJson())),
      };
}

class Ticker {
  Ticker({
    required this.high,
    required this.low,
    required this.vol,
    required this.last,
    required this.buy,
    required this.sell,
    required this.open,
    required this.date,
    required this.pair,
  });

  String high;
  String low;
  String vol;
  String last;
  String buy;
  String sell;
  String open;
  int date;
  String pair;

  factory Ticker.fromJson(Map<String, dynamic> json) => Ticker(
        high: json["high"],
        low: json["low"],
        vol: json["vol"],
        last: json["last"],
        buy: json["buy"],
        sell: json["sell"],
        open: json["open"],
        date: json["date"],
        pair: json["pair"],
      );

  Map<String, dynamic> toJson() => {
        "high": high,
        "low": low,
        "vol": vol,
        "last": last,
        "buy": buy,
        "sell": sell,
        "open": open,
        "date": date,
        "pair": pair,
      };
}
