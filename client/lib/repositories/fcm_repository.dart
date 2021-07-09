import 'dart:convert';

import 'package:meubitcoin/models/fcm.dart';
import 'package:http/http.dart' as http;

class FcmRepository {
  String _urlBase = "https://meubitcoin-server.herokuapp.com/fcm";
  // String _urlBase = "http://192.168.0.16:8080/fcm";
//
  Future<List<Fcm>> getAll() async {
    var response = await http.get(Uri.parse(_urlBase),
        headers: {"Content-Type": "application/json"});
    if (response.statusCode != 200) throw Exception("Not ok");
    return (jsonDecode(response.body) as List)
        .map((e) => Fcm.fromJson(e))
        .toList();
  }

  Future<Fcm> add(Fcm fcm) async {
    var json = fcmToJson(fcm);

    var response = await http.post(Uri.parse(_urlBase),
        body: json, headers: {"Content-Type": "application/json"});

    if (response.statusCode != 200) throw Exception(response.body);
    return Fcm.fromJson(jsonDecode(response.body));
  }

  Future<List<Fcm>> getByCoinIdDevice(
      {required String idDevice, required String coin}) async {
    var query =
        Uri(queryParameters: {"idDevice": idDevice, "coin": coin}).query;
    var response = await http.get(Uri.parse("${_urlBase}?$query"),
        headers: {"Content-Type": "application/json"});
    if (response.statusCode != 200) throw Exception("Not ok");
    return (jsonDecode(response.body) as List)
        .map((e) => Fcm.fromJson(e))
        .toList();
  }

  Future<Fcm> remove(String id) async {
    var response = await http.delete(Uri.parse("${_urlBase}/$id"));
    if (response.statusCode != 200) throw Exception("Not ok");
    return Fcm.fromJson(jsonDecode(response.body));
  }
}
