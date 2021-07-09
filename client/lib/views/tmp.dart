import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:intl/intl.dart';
import 'package:meubitcoin/controllers/tmp_controller.dart';
import 'package:meubitcoin/models/Coin.dart';
import 'package:meubitcoin/utils/loading.dart';

class TmpPage extends StatefulWidget {
  const TmpPage({Key? key}) : super(key: key);

  @override
  _TmpPageState createState() => _TmpPageState();
}

class _TmpPageState extends State<TmpPage> {
  final TmpController _tmpController = Get.put(TmpController());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TMP"),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _tmpController.increment();
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return GetBuilder<TmpController>(
      builder: (_) {
        return Text("Count: ${_.count}");
      },
    );
  }
}
