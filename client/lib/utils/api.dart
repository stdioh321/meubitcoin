import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:meubitcoin/models/Coin.dart';
import 'package:meubitcoin/models/Trade.dart';

class Api {
  Api._privateConstructor();

  static final Api _instance = Api._privateConstructor();

  static Api get instance => _instance;
  List<String> coins = [
    "BRLAAVE",
    "BRLACMFT",
    "BRLACORDO01",
    "BRLASRFT",
    "BRLATMFT",
    "BRLAXS",
    "BRLBAL",
    "BRLBARFT",
    "BRLBAT",
    "BRLBCH",
    "BRLBTC",
    "BRLCAIFT",
    "BRLCHZ",
    "BRLCOMP",
    "BRLCRV",
    "BRLDAI",
    "BRLDAL",
    "BRLENJ",
    "BRLETH",
    "BRLGALFT",
    "BRLGRT",
    "BRLIMOB01",
    "BRLIMOB02",
    "BRLJUVFT",
    "BRLKNC",
    "BRLLINK",
    "BRLLTC",
    "BRLMANA",
    "BRLMBCONS01",
    "BRLMBCONS02",
    "BRLMBFP01",
    "BRLMBFP02",
    "BRLMBFP03",
    "BRLMBFP04",
    "BRLMBPRK01",
    "BRLMBPRK02",
    "BRLMBPRK03",
    "BRLMBPRK04",
    "BRLMBVASCO01",
    "BRLMCO2",
    "BRLMKR",
    "BRLOGFT",
    "BRLPAXG",
    "BRLPSGFT",
    "BRLREI",
    "BRLREN",
    "BRLSNX",
    "BRLUMA",
    "BRLUNI",
    "BRLUSDC",
    "BRLWBX",
    "BRLXRP",
    "BRLYFI",
    "BRLZRX"
  ];

  Future<List<Ticker>> getTicker([String? coin = null]) async {
    String urlBase = "https://cdn.mercadobitcoin.com.br/api";
    List<String> tmpCoins = coins.toList();
    if (coin != null)
      tmpCoins = tmpCoins
          .where((e) => "$coin".toLowerCase() == e.toLowerCase())
          .toList();
    Response resp =
        await get(Uri.parse("$urlBase/tickers?pairs=" + tmpCoins.join(",")));
    if (resp.statusCode != 200) throw Exception("Something went wrong.");

    return coinFromJson(resp.body).ticker;
  }

  Future<List<Trade>> getTrade(String coin) async {
    String url = "https://www.mercadobitcoin.net/api/$coin/trades/";
    var resp = await get(Uri.parse(url));
    if (resp.statusCode != 200) throw Exception("Something went wrong.");
    List<Trade> trades = (jsonDecode(resp.body) as List<dynamic>)
        .map((e) => Trade.fromJson(e))
        .toList();
    return trades;
  }

  Future<bool> hasConnection() async {
    try {
      return (await InternetAddress.lookup("www.google.com")).isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
