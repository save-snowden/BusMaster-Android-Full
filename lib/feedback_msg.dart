// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'data_provider.dart';
import 'dart:io';

class FeedbackMsgPage extends StatefulWidget {
  final String feedback;
  final String predictedClass;
  final String submitTimestampString;

  FeedbackMsgPage({
    required this.feedback,
    required this.predictedClass,
    required this.submitTimestampString,
  });

  @override
  _FeedbackMsgPageState createState() => _FeedbackMsgPageState();
}

class _FeedbackMsgPageState extends State<FeedbackMsgPage> {
  bool _dataUploaded = false;

  String formattedTimestamp = '';
  String busNumber = '';

  @override
  void initState() {
    super.initState();
    _uploadFeedbackData();
  }

  Future<void> _uploadFeedbackData() async {
    try {
      busNumber =
          Provider.of<BusNumberProvider>(context, listen: false).busNumber;

      DateTime submitTimestamp =
          DateTime.parse(widget.submitTimestampString).toLocal();
      submitTimestamp = submitTimestamp.subtract(
        Duration(milliseconds: submitTimestamp.millisecond),
      );

      formattedTimestamp = submitTimestamp.toString().split('.')[0];

      Map<String, dynamic> jsonData = {
        'data': {
          'busNumber': busNumber,
          'timestamp': formattedTimestamp,
          'feedback': widget.feedback,
          'predictedClass': widget.predictedClass,
        }
      };

      var url =
          'https://script.google.com/macros/s/AKfycbx2W-6CViBI1QKs9bHhHGBzztQqdITLALxH6fqOjIPUbs7xF-w6yGfhTlweBTx12hwO/exec';

      var response =
          await http.post(Uri.parse(url), body: jsonEncode(jsonData));

      if (response.statusCode == 200 || response.statusCode == 302) {
        setState(() {
          _dataUploaded = true;
        });

        if (widget.predictedClass.toLowerCase() == 'emergency') {
          // Send SMS to admin
          await _sendEmergencySMS();
        }
      }
    } catch (e) {
      // Handle exceptions
      print('Error uploading data: $e');
    }
  }

  Future<void> _sendEmergencySMS() async {
    try {
      var smsUrl = 'https://y34zrj.api.infobip.com/sms/2/text/advanced';
      var apiKey =
          '60150c13abcb0e5f0c66afb8d19c5464-af3ef6fc-560f-438e-922b-6afffa7014fe';

      Map<String, dynamic> smsData = {
        'messages': [
          {
            'destinations': [
              {
                'to': '+94770687841', // Replace with the admin's phone number
              }
            ],
            'from': 'InfoSMS',
            'text':
                'Feedback Given by passenger from $busNumber at $formattedTimestamp was identified as an EMERGENCY. Please take the necessary actions.',
          }
        ]
      };

      var smsResponse = await http.post(
        Uri.parse(smsUrl),
        headers: {
          'Authorization': 'App $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(smsData),
      );

      if (smsResponse.statusCode == 200) {
        print('Emergency SMS sent successfully.');
      } else {
        print(
            'Failed to send Emergency SMS. Status code: ${smsResponse.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Error sending Emergency SMS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _dataUploaded
          ? _buildThankYouScreen()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Your feedback is really appreciated.',
                    textScaleFactor: 1.5,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildThankYouScreen() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center the content vertically
        children: [
          SizedBox(height: 50),
          Text(
            'Thank you for riding with us.',
            textAlign: TextAlign.center,
            textScaleFactor: 1.5, // Increase the text size
          ),
          SizedBox(height: 50),
          Icon(
            Icons.check_circle, // You can use your own tick/right logo
            color: Colors.green,
            size: 100,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context);
              exit(0);
            },
            child: Text('Close the App'),
          ),
        ],
      ),
    );
  }
}
