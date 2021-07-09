import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:meubitcoin/models/Coin.dart';
import 'package:meubitcoin/models/fcm.dart';
import 'package:meubitcoin/repositories/fcm_firebase_repository.dart';
import 'package:meubitcoin/repositories/fcm_repository.dart';
import 'package:meubitcoin/services/firebase_notification_service.dart';
import 'package:meubitcoin/utils/api.dart';
import 'package:meubitcoin/utils/loading.dart';
import 'package:meubitcoin/utils/util.dart';
import 'package:meubitcoin/views/home.dart';

class TickerDetail extends StatefulWidget {
  String pair;

  TickerDetail({Key? key, required this.pair}) : super(key: key);

  @override
  _TickerDetailState createState() => _TickerDetailState();
}

class _TickerDetailState extends State<TickerDetail> {
  Ticker? ticker = null;
  final _formAlertaCtrl = GlobalKey<FormState>();
  Status status = Status.none;
  Status statusAddAlert = Status.none;
  Status statusRemoveAlert = Status.none;

  final f = DateFormat('dd/MM/yyyy HH:mm:ss');
  Timer? timer = null;
  TextEditingController _textConversorController = TextEditingController()
    ..text = "0.0000";
  TextEditingController _txtPriceAlert = TextEditingController()
    ..text = "0.0000";

  String idDevice = FirebaseNotificaitonService.instance.token;
  List<Fcm> fcms = [];
  Set<String?> fcmsRemoved = Set();

  bool isAbove = true;

  Map alert = {};

  final FcmFirebaseRepository _fcmFbRepository = FcmFirebaseRepository();
  final FcmRepository _fcmRepository = FcmRepository();

  @override
  void initState() {
    // TODO: implement initState

    loadResources();
  }

  Future init() async {}

  @override
  void dispose() {
    // TODO: implement dispose
    try {
      timer?.cancel();
    } catch (e) {}
    super.dispose();
  }

  Future loadTicker() async {
    ticker = (await Api.instance.getTicker(widget.pair)).first;
  }

  Future loadResources() async {
    try {
      if (status == Status.loading) return;
      status = Status.loading;
      setState(() {});
      await loadTicker();
      try {
        fcms = await _fcmRepository.getByCoinIdDevice(
            idDevice: idDevice, coin: widget.pair);
      } catch (e) {}
      _execTimer();
      status = Status.ok;
      setState(() {});
    } catch (e) {
      status = Status.error;
      setState(() {});
    }
  }

  void _execTimer() {
    if (timer == null)
      timer = Timer.periodic(Duration(seconds: 5), (timer) async {
        try {
          await loadTicker();
          setState(() {});
        } catch (e) {}
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.pair.substring(3)}"),
        actions: [
          btAddAlert(context),
        ],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            if (Navigator.canPop(context))
              Navigator.pop(context);
            else
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Home(),
                ),
              );
          },
        ),
      ),
      body: _buildBody(),
    );
  }

  IconButton btAddAlert(BuildContext context) {
    return IconButton(
      onPressed: () async {
        _txtPriceAlert.text = "0.0000";
        isAbove = true;
        Util.instance.removeFocus(context);
        await showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setStateIn) {
                return AlertDialog(
                  title: Text("Valor para receber o alerta"),
                  content: Container(
                    constraints: BoxConstraints(maxHeight: 150),
                    child: Form(
                      key: _formAlertaCtrl,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _txtPriceAlert,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.attach_money_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                            inputFormatters: [
                              CurrencyTextInputFormatter(
                                decimalDigits: 4,
                                symbol: "",
                                turnOffGrouping: true,
                              )
                            ],
                            keyboardType: TextInputType.numberWithOptions(),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return "Não pode ser vazio";
                              try {
                                var doubleVal = double.parse(value);
                                if (!(doubleVal > 0))
                                  return "Precisa ser maior que 0";
                              } catch (e) {
                                return "Não é um número";
                              }
                              return null;
                            },
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Quando for mais alto?",
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              Switch(
                                  value: isAbove,
                                  onChanged: (v) {
                                    setStateIn(() {
                                      isAbove = !isAbove;
                                    });
                                  })
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.cancel,
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                    ),
                    statusAddAlert == Status.loading
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formAlertaCtrl.currentState!.validate()) {
                                try {
                                  if (statusAddAlert == Status.loading) return;

                                  setStateIn(() {
                                    statusAddAlert = Status.loading;
                                  });

                                  var currFcm = await _fcmRepository.add(Fcm(
                                      idDevice: idDevice,
                                      coin: widget.pair,
                                      price: double.parse(_txtPriceAlert.text),
                                      above: isAbove));

                                  fcms = await _fcmRepository.getByCoinIdDevice(
                                      idDevice: idDevice, coin: widget.pair);
                                  statusAddAlert = Status.ok;
                                  setStateIn(() {});
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Alerta de ${Util.instance.toReal(currFcm.price)} adicionado")));
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  print(e);
                                  setStateIn(() {
                                    statusAddAlert = Status.none;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Não foi possivel adicionar o alerta.")));
                                  });
                                }
                              }
                            },
                            child: Icon(Icons.send),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                            ),
                          ),
                  ],
                );
              },
            );
          },
        );
      },
      icon: Icon(Icons.add_alarm),
    );
  }

  Widget _buildBody() {
    if (status == Status.loading || status == Status.none)
      return Center(
        child: CircularProgressIndicator(),
      );
    else if (status == Status.ok)
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              _tickerInformation(),
              Divider(),
              _converterField(),
              _fcmList(),
            ],
          ),
        ),
      );
    else
      return Center(
        child: Text(
          "Algo deu errado.",
          style: TextStyle(fontSize: 33),
        ),
      );
  }

  Widget _tickerInformation() {
    return Column(
      children: [
        Row(
          children: [
            Util.instance.imgOrPlaceholder(
                "assets/images/coin_image/" + widget.pair.substring(3) + ".png",
                50,
                "assets/images/coin_image/placeholder.png",
                50),
            SizedBox(
              width: 15,
            ),
            Text(
              widget.pair.substring(3),
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
        SizedBox(),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            f.format(DateTime.fromMillisecondsSinceEpoch(ticker!.date * 1000)),
          ),
        ),
        Divider(),
        Row(
          children: [
            Expanded(child: Text("Compra")),
            Text(Util.instance.toReal(ticker?.buy))
          ],
        ),
        Divider(),
        Row(
          children: [
            Expanded(child: Text("Venda")),
            Text(Util.instance.toReal(ticker?.sell))
          ],
        ),
        Divider(),
        Row(
          children: [
            Expanded(child: Text("Último")),
            Text(Util.instance.toReal(ticker?.last))
          ],
        ),
        Divider(),
        Row(
          children: [
            Expanded(child: Text("Maior")),
            Text(Util.instance.toReal(ticker?.high))
          ],
        ),
        Divider(),
        Row(
          children: [
            Expanded(child: Text("Menor")),
            Text(Util.instance.toReal(ticker?.low))
          ],
        ),
        Divider(),
        Row(
          children: [
            Expanded(child: Text("Volume")),
            Text(Util.instance.toReal(ticker?.vol))
          ],
        ),
      ],
    );
  }

  Widget _converterField() {
    return Container(
      child: Column(
        children: [
          TextFormField(
            controller: _textConversorController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              setState(() {});
            },
            inputFormatters: [
              CurrencyTextInputFormatter(
                decimalDigits: 4,
                symbol: "",
                turnOffGrouping: true,
              )
            ],
            decoration: InputDecoration(
              labelText: widget.pair.substring(3),
              prefixIcon: Icon(Icons.attach_money_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          (_textConversorController.text.isEmpty)
              ? SizedBox()
              : Container(
                  padding: EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.swap_vertical_circle),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        _convertCoin(
                            _textConversorController.text, ticker!.buy),
                        style: TextStyle(fontSize: 22),
                      )
                    ],
                  ),
                )
        ],
      ),
    );
  }

  Widget _fcmList() {
    if (fcms.length < 1)
      return Column(children: [
        Divider(),
        Text("Nenhum alerta"),
      ]);

    var _fcmList = [
      Divider(),
      Text(
        "Lista de Alertas",
        textAlign: TextAlign.start,
        style: TextStyle(fontSize: 30),
      ),
      Divider(),
    ];
    _fcmList.addAll(fcms.map<Widget>((e) {
      return ListTile(
        dense: true,
        leading: e.above
            ? Icon(Icons.arrow_upward, color: Colors.green)
            : Icon(Icons.arrow_downward, color: Colors.red),
        title: Text(Util.instance.toReal(e.price)),
        trailing: statusRemoveAlert == Status.loading &&
                fcmsRemoved.contains(e.id)
            ? CircularProgressIndicator()
            : IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  var proceed = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Tem certeza?"),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: Text("Não"),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: Text("Sim"),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  if (proceed != true) return;
                  try {
                    if (statusRemoveAlert == Status.loading) return;
                    setState(() {
                      statusRemoveAlert = Status.loading;
                      fcmsRemoved.add(e.id);
                    });

                    await _fcmRepository.remove(e.id ?? "");

                    fcms = await _fcmRepository.getByCoinIdDevice(
                        idDevice: idDevice, coin: widget.pair);
                    statusRemoveAlert = Status.ok;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "Alerta de ${Util.instance.toReal(e.price)} removido")));
                    fcmsRemoved.remove(e.id);
                    setState(() {});
                  } catch (err) {
                    setState(() {
                      statusRemoveAlert = Status.none;
                      fcmsRemoved.remove(e.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Não foi possivel deletar o alerta")));
                    });
                  }
                },
              ),
      );
    }).cast());

    return Container(
      child: Column(
        children: _fcmList,
      ),
    );
  }

  String _convertCoin(String money, String coin) {
    return (double.parse(money) / double.parse(coin)).toStringAsFixed(5);
  }
}
