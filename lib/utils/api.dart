import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:meubitcoin/models/Coin.dart';

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
  String urlBase = "https://cdn.mercadobitcoin.com.br/api";
  Future<Response> getTicker([String? coin = null]) async {
    List<String> tmpCoins = coins.toList();
    if (coin != null)
      tmpCoins = tmpCoins
          .where((e) => "$coin".toLowerCase() == e.toLowerCase())
          .toList();
    return get(Uri.parse("$urlBase/tickers?pairs=" + tmpCoins.join(",")));
  }

  Future<bool> hasConnection() async {
    try {
      return (await InternetAddress.lookup("www.google.com")).isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
