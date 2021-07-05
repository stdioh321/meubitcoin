// To parse this JSON data, do
//
//     final contato = contatoFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

Contato contatoFromJson(String str) => Contato.fromJson(json.decode(str));

String contatoToJson(Contato data) => json.encode(data.toJson());

class Contato {
  Contato({
    this.id,
    required this.nome,
    required this.idade,
  });

  int? id;
  String nome;
  int idade;

  factory Contato.fromJson(Map<String, dynamic> json) => Contato(
        id: json["_id"],
        nome: json["nome"],
        idade: json["idade"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "nome": nome,
        "idade": idade,
      };
}
