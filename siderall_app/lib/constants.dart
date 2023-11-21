import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//const kTextColor = Color(0xFF535353);
const kTextColor = Color(0xFF46B0B4);
//const kTextLightColor = Color(0xFFACACAC);
const kTextLightColor = Color(0xFF4B7576);

const kDefaultPaddin = 20.0;
const int b=0;

Future<String> sendPay(String a, String ticket) async {
  final response =
  await http.post("http://192.168.68.106/Transbank/transbank.php", body: {
    'pay': a,
    'ticket': ticket,
  });

  print(response.body);
  return response.body;
}
Future<String> sendPayRedelcom2(String a, String ticket) async {
  final response =
  await http.post("http://192.168.68.106/Redelcom/Redelcom/redelcom.php", body: {
    'pay': a,
    'ticket': ticket,
  });

  print(response.body);
  return response.body;
}
//C:\xampp\tomcat\webapps\Redelcom\SiderallPayAPIWS\SiderallPayAPIWS\build\web\WEB-INF\classes\siderall
//http://192.168.0.8:8080/Redelcom/SiderallPayAPIWS/SiderallPayAPIWS/src/java/siderall/enviarpago.java

/*Future<String> sendPayRedelcom(Map<String, String> a) async {
  final response =
  await http.post("http://192.168.0.8:8080/Redelcom/Redelcom/redelcom.php", body: a);

  print(response.body);
  return response.body;
}*/


class Redelcom {
  String _canal;
  String _monto;
  String _boleta;
  String _impresion;
  String _mensajes;

  Redelcom(this._canal, this._monto, this._boleta, this._impresion, this._mensajes,);

  get getCanal => this._canal;
  get getMonto => this._monto;
  get getBoleta => this._boleta;
  get getImpresion => this._impresion;
  get getMensajes => this._mensajes;

  set setMonto(String value) => this._monto = value;
  set setBoleta(String value) => this._boleta = value;
  set setImpresion(String value) => this._impresion = value;
  set setMensajes(String value) => this._mensajes = value;

  Map<String, String> toJson() {
    return {
      'canal': this._canal,
      'monto': this._monto,
      'boleta': this._boleta,
      'impresion': this._impresion,
      'mensajes': this._mensajes,
    };
  }

  factory Redelcom.fromJson(Map<String, String> json) {
    return Redelcom(
      json['id'],
      json['user'],
      json['monto'],
      json['boleta'],
      json['mensajes'],
    );
  }
}