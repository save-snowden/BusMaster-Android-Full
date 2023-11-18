// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, unused_field

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'qr_code_result_page.dart';
import 'model_process.dart'; // Import the ModelProcess class

class QRCodeScannerPage extends StatefulWidget {
  const QRCodeScannerPage({Key? key}) : super(key: key);

  @override
  _QRCodeScannerPageState createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  String _scanResult = '';
  bool isScanCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (barcode, args) {
              if (!isScanCompleted) {
                String code = barcode.rawValue ?? '---';

                // Get current timestamp
                String timestamp = DateTime.now().toString();

                // Send timestamp to ModelProcess
                ModelProcess().setTimestamp(timestamp);

                isScanCompleted = true;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRCodeResultPage(
                      scanResult: code,
                      onBack: () {
                        setState(() {
                          isScanCompleted = false;
                        });
                      },
                    ),
                  ),
                );
              }
            },
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: ClipRect(
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Text(
                      'Put the QR code through the camera area',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
