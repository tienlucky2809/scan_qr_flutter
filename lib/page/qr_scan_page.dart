import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner_example/model/qr_respon.dart';
import 'package:qr_code_scanner_example/page/transfer_page.dart';
import 'package:qr_code_scanner_example/widget/button_widget.dart';

import '../main.dart';

class QRScanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  String respon = 'Please scan QR code';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(MyApp.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 8),
              Text(
                '$respon',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 200),
              ButtonWidget(
                text: 'Start QR scan',
                onClicked: () => scanQRCode(),
              ),
            ],
          ),
        ),
      );

  Future<void> scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );
      print("qrstr-------------------------- $qrCode");
      if(qrCode != '-1'){
        final Response response = await http.get(Uri.parse('http://103.160.89.20:9796/qr/valid?strQR=$qrCode'));
        print("---------------------------------------- ${response.statusCode}");
        if(response.statusCode == 200){
          QRRespon qrRespon = QRRespon.fromJson(jsonDecode(response.body));
          if(qrRespon.accCode != null){
            setState(() {
              respon = '';
            });
            Navigator.push( context, MaterialPageRoute(builder: (context) => Transfer(qrRespon: qrRespon,)), );
          } else {
            setState(() {
              respon = "QR code is not correct format";
            });
          }
        } else {
          throw new Exception("Error system!!");
        }
      } else {
        setState(() {
          respon = 'Please scan QR code';
        });
      }
       if (!mounted) return;
    } catch (e) {
      setState(() {
        respon = e.toString();
      });
    }

  }
}
