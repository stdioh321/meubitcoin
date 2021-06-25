import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:meubitcoin/models/Coin.dart';

class Util {
  Util._privateConstructor();

  static final Util _instance = Util._privateConstructor();

  static Util get instance => _instance;

  Future<bool> hasConnection() async {
    try {
      return (await InternetAddress.lookup("www.google.com")).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  MaterialColor toMaterialColor(Color c) {
    var mapColors = {
      50: Color.fromRGBO(136, 14, 79, .1),
      100: Color.fromRGBO(136, 14, 79, .2),
      200: Color.fromRGBO(136, 14, 79, .3),
      300: Color.fromRGBO(136, 14, 79, .4),
      400: Color.fromRGBO(136, 14, 79, .5),
      500: Color.fromRGBO(136, 14, 79, .6),
      600: Color.fromRGBO(136, 14, 79, .7),
      700: Color.fromRGBO(136, 14, 79, .8),
      800: Color.fromRGBO(136, 14, 79, .9),
      900: Color.fromRGBO(136, 14, 79, 1),
    };
    return MaterialColor(c.value, mapColors);
  }
}
