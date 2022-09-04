import 'dart:convert';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:qr_code_scanner_example/main.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner_example/model/data_model.dart';
import 'package:qr_code_scanner_example/model/header_model.dart';
import 'package:qr_code_scanner_example/model/qr_model.dart';
import 'package:qr_code_scanner_example/widget/button_widget.dart';

class QRCreatePage extends StatefulWidget {
  @override
  _QRCreatePageState createState() => _QRCreatePageState();
}

class _QRCreatePageState extends State<QRCreatePage> {
  final controller = TextEditingController();
  final controller2 = TextEditingController();
  final controller3 = TextEditingController();
  String qr = "-1";

  bool _validate = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: Text(MyApp.title),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                textDirection: TextDirection.ltr,
                children: [
                  BarcodeWidget(
                    barcode: Barcode.qrCode(),
                    color: Colors.black,
                    data: qr,
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(height: 40),
                  Column(
                    children: <Widget>[
                      TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Enter your account/card number',
                          errorText: _validate
                              ? 'Account/card number Can\'t Be Empty'
                              : null,
                        ),
                      ),

                      SizedBox(height: 20),
                      TextField(
                        maxLength: 9,
                        controller: controller2,
                        decoration: InputDecoration(
                          labelText: 'Enter your amount',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp('^[0-9]*\$')),
                        ],
                      ),

                      SizedBox(height: 20),
                      TextField(
                        controller: controller3,
                        maxLines: 3,
                        maxLength: 100,
                        decoration: InputDecoration(
                          labelText: 'Enter your content transfer',
                        ),
                      ),

                      SizedBox(height: 20),
                      ButtonWidget(
                          text: 'Generate',
                          onClicked: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            setState(() {
                              if (controller.text.isEmpty)
                                _validate = true;
                              else {
                                _validate = false;
                                genQR();
                              }
                            });
                          }
                      ),

                    ],

                  ),
                ],
              ),
            ),
          ),
        )
    );
  }

  Future<void> genQR() async {
    print('------------------------');
    print(controller.text);
    print(controller2.text);
    print(controller3.text);

    String json =
        '{"header": {"bankCd": "KEBHANA","brCd": "HN"} ,"data":{"accountNumber" : "${controller
        .text}","amount":"${controller2.text}","contentTransfer":"${controller3
        .text}"}}';
    Map<String, String> headers = {"Content-type": "application/json"};
    try {
      final Response response = await http.put(
          Uri.parse('http://103.160.89.20:9797/qr/generate'),
          headers: headers,
          body: json);
      if (response.statusCode == 200) {
        setState(() {
          qr = response.body;
        });
      } else {
        setState(() {
          qr = '-1';
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        qr = '-1';
      });
    }
    print(qr);
  }
}
