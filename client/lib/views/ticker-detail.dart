import 'dart:async';
import 'dart:math';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:meubitcoin/controllers/ticker_detail_controller.dart';
import 'package:meubitcoin/services/firebase_notification_service.dart';
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
  String tag = Random().nextInt(9999999).toString();

  late TickerDetailController tDCtrl;
  final _formAlertaCtrl = GlobalKey<FormState>();

  TextEditingController _txtConversorController = TextEditingController()
    ..text = "0.0000";
  TextEditingController _txtPriceAlert = TextEditingController()
    ..text = "0.0000";
  _TickerDetailState() {
    tDCtrl = Get.put(TickerDetailController(), tag: tag);
  }
  @override
  void initState() {
    // TODO: implement initState
    tDCtrl
      ..init(widget.pair, FirebaseNotificaitonService.instance.token)
      ..loadResources();
  }

  Future init() async {}

  @override
  void dispose() {
    // TODO: implement dispose
    try {
      tDCtrl.timer?.cancel();
    } catch (e) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: GetBuilder<TickerDetailController>(
        tag: tag,
        builder: (controller) => btAddAlert(context),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      appBar: _buildAppBar(),
      body: GetBuilder<TickerDetailController>(
        tag: tag,
        builder: (controller) => _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("${widget.pair}"),
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
    );
  }

  FloatingActionButton btAddAlert(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        tDCtrl.resetAddAlertDate();
        _txtPriceAlert.text = "0.0000";

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
                            onChanged: (value) =>
                                tDCtrl.addAlertData["price"] = value,
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
                                  value: tDCtrl.addAlertData["above"],
                                  onChanged: (v) {
                                    tDCtrl.addAlertData["above"] = v;
                                    setStateIn(() {});
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
                    tDCtrl.statusAddFcm == Status.loading
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formAlertaCtrl.currentState!.validate()) {
                                tDCtrl.statusAddFcm = Status.loading;
                                setStateIn(() {});
                                if (await tDCtrl.addFcm()) {
                                  Util.instance.defaultSnackBar(context,
                                      "Alerta de ${Util.instance.toReal(tDCtrl.addAlertData["price"])} adicionado");

                                  Navigator.pop(context);
                                } else {
                                  Util.instance.defaultSnackBar(context,
                                      "Não foi possivel adicionar o alerta");
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
      child: Icon(
        Icons.add_alarm,
      ),
    );
  }

  Widget _buildBody() {
    if (tDCtrl.status == Status.loading || tDCtrl.status == Status.none)
      return Center(
        child: CircularProgressIndicator(),
      );
    else if (tDCtrl.status == Status.ok)
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
                "assets/images/coin_image/${tDCtrl.coin}.png",
                50,
                "assets/images/coin_image/placeholder.png",
                50),
            SizedBox(
              width: 15,
            ),
            Text(
              tDCtrl.coin!,
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
        SizedBox(),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            Util.instance.defaultDateFormat().format(
                DateTime.fromMillisecondsSinceEpoch(
                    tDCtrl.ticker!.date * 1000)),
          ),
        ),
        Divider(),
        Row(
          children: [
            Expanded(child: Text("Compra")),
            Text(Util.instance.toReal(tDCtrl.ticker?.buy))
          ],
        ),
        Divider(),
        Row(
          children: [
            Expanded(child: Text("Venda")),
            Text(Util.instance.toReal(tDCtrl.ticker!.sell))
          ],
        ),
        Divider(),
        Row(
          children: [
            Expanded(child: Text("Último")),
            Text(Util.instance.toReal(tDCtrl.ticker!.last))
          ],
        ),
        Divider(),
        Row(
          children: [
            Expanded(child: Text("Maior")),
            Text(Util.instance.toReal(tDCtrl.ticker!.high))
          ],
        ),
        Divider(),
        Row(
          children: [
            Expanded(child: Text("Menor")),
            Text(Util.instance.toReal(tDCtrl.ticker!.low))
          ],
        ),
        Divider(),
        Row(
          children: [
            Expanded(child: Text("Volume")),
            Text(Util.instance.toReal(tDCtrl.ticker!.vol))
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
            controller: _txtConversorController,
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
              labelText: tDCtrl.coin,
              prefixIcon: Icon(Icons.attach_money_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          (_txtConversorController.text.isEmpty)
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
                            _txtConversorController.text, tDCtrl.ticker!.buy),
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
    if (tDCtrl.fcms.length < 1)
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
    _fcmList.addAll(tDCtrl.fcms.map<Widget>((currentFcm) {
      return ListTile(
        dense: true,
        leading: currentFcm.above
            ? Icon(Icons.arrow_upward, color: Colors.green)
            : Icon(Icons.arrow_downward, color: Colors.red),
        title: Text(Util.instance.toReal(currentFcm.price)),
        trailing: tDCtrl.statusRemoveFcm == Status.loading &&
                tDCtrl.removedFcms.contains(currentFcm.id)
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
                  if (await tDCtrl.removeFcm(currentFcm.id ?? "")) {
                    Util.instance.defaultSnackBar(context,
                        "Alerta de ${Util.instance.toReal(currentFcm.price)} removido");
                  } else {
                    Util.instance.defaultSnackBar(
                        context, "Não foi possivel remover o alerta");
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
