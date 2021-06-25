import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meubitcoin/models/Coin.dart';
import 'package:meubitcoin/models/Trade.dart';
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

  Status status = Status.none;
  final f = DateFormat('dd/MM/yyyy HH:mm:ss');
  Timer? timer;

  @override
  void initState() {
    // TODO: implement initState

    loadTicker().then((value) {
      timer = Timer.periodic(Duration(seconds: 3), (timer) async {
        try {
          print("Timer: ${timer.tick}");
          await getTicker();
          setState(() {});
        } catch (e) {}
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    try {
      timer?.cancel();
    } catch (e) {}
    super.dispose();
  }

  Future getTicker() async {
    ticker = (await Api.instance.getTicker(widget.pair)).first;
  }

  Future loadTicker() async {
    try {
      if (status == Status.loading) return;
      status = Status.loading;
      setState(() {});
      await getTicker();
      status = Status.ok;
      setState(() {});
    } catch (e) {
      status = Status.error;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.pair.substring(3)}"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
              Row(
                children: [
                  Util.instance.imgOrPlaceholder(
                      "assets/images/coin_image/" +
                          widget.pair.substring(3) +
                          ".png",
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
              Divider(),
              Row(
                children: [
                  Expanded(child: Text("Compra")),
                  Text("R\$ ${ticker?.buy}")
                ],
              ),
              Divider(),
              Row(
                children: [
                  Expanded(child: Text("Venda")),
                  Text("R\$ ${ticker?.sell}")
                ],
              ),
              Divider(),
              Row(
                children: [
                  Expanded(child: Text("Último")),
                  Text("R\$ ${ticker?.last}")
                ],
              ),
              Divider(),
              Row(
                children: [
                  Expanded(child: Text("Maior")),
                  Text("R\$ ${ticker?.high}")
                ],
              ),
              Divider(),
              Row(
                children: [
                  Expanded(child: Text("Menor")),
                  Text("R\$ ${ticker?.low}")
                ],
              ),
              Divider(),
              Row(
                children: [
                  Expanded(child: Text("Volume")),
                  Text("R\$ ${ticker?.vol}")
                ],
              ),
              Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  f.format(
                      DateTime.fromMillisecondsSinceEpoch(ticker!.date * 1000)),
                ),
              ),
            ],
          ),
        ),
      );
    else
      return Center(
        child: Text("Algo deu errado."),
      );
  }
}
