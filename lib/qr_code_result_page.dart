import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ratings.dart';
import 'feedback_msg.dart';
import 'data_provider.dart';
import 'model_process.dart';
import 'package:provider/provider.dart';

class QRCodeResultPage extends StatefulWidget {
  final String scanResult;
  final VoidCallback? onBack;

  const QRCodeResultPage({Key? key, required this.scanResult, this.onBack})
      : super(key: key);

  @override
  _QRCodeResultPageState createState() => _QRCodeResultPageState();
}

class _QRCodeResultPageState extends State<QRCodeResultPage> {
  bool _ratingsSubmitted = false;
  late Future<Map<String, dynamic>> _futureBuses;
  late ModelProcess _modelProcess;

  @override
  void initState() {
    super.initState();
    _modelProcess = ModelProcess();
    _futureBuses = _getBuses(widget.scanResult);

    // Set the bus number in the provider
    Future.delayed(Duration(seconds: 3), () {
      Provider.of<BusNumberProvider>(context, listen: false)
          .setBusNumber(widget.scanResult);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to the main page when the back button is pressed
        Navigator.pushNamedAndRemoveUntil(
            context, '/', (Route<dynamic> route) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<Map<String, dynamic>>(
          future: _futureBuses,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: _buildLoadingWithQuotes(),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No Data found'));
            } else {
              Map<String, dynamic> busDetails = snapshot.data!;
              return FutureBuilder<void>(
                future: _loadModelAndPredict(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                'Scroll down for more details',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontFamily: 'Ubuntu',
                                ),
                              ),
                            ),
                            Image.asset(
                              'images/bus-image.gif',
                              width: 200,
                              height: 100,
                            ),
                            _buildSectionBox(
                                'Bus Number', busDetails['busNumber']),
                            _buildSectionBox(
                                'Starting Point', busDetails['startingPoint']),
                            _buildSectionBoxPRED(
                              'Estimated Arrival to Kandy',
                              _formatTime(_modelProcess.prediction),
                            ),
                            _buildSectionBoxPRED(
                              'Weather Prediction',
                              _modelProcess.weatherEncoded ??
                                  'Check your internet connection and try again',
                            ),
                            _buildSectionBoxPRED(
                              'Traffic Level Prediction',
                              _modelProcess.trafficEncoded ??
                                  'Check your internet connection and try again',
                            ),
                            _buildSectionBox(
                                'Driver Name', busDetails['driverName']),
                            _buildSectionBox(
                                'Driver NIC No', busDetails['driverID']),
                            _buildSectionBox(
                                'Conductor Name', busDetails['conductorName']),
                            _buildSectionBox(
                                'Conductor NIC No', busDetails['conductorID']),
                            _buildSectionBox(
                                'Chassi Number', busDetails['chassiNumber']),
                            const SizedBox(height: 0.5),
                            const SizedBox(height: 0.5),
                            Container(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RatingsPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 7.0),
                                ),
                                child: Text(
                                  'Rate the Ride',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _loadModelAndPredict() async {
    // Set initial placeholder values
    _modelProcess.prediction = null;
    _modelProcess.trafficEncoded = 'Calculating...';
    _modelProcess.weatherEncoded = 'Calculating...';

    // Trigger the asynchronous operations
    await _modelProcess.setTimestamp(widget.scanResult);
  }

  Widget _buildLoadingWithQuotes() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            _modelProcess.prediction != null
                ? 'Data fetched and predictions completed!'
                : 'Fetching the data and predicting few things for you',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Ubuntu',
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(double? time) {
    if (time == null) {
      return 'N/A';
    }

    int hours = time ~/ 60;
    int minutes = (time % 60).round();
    return '$hours hours and $minutes minutes after the departure';
  }

  Widget _buildSectionBox(String title, String? value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value ?? 'N/A',
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionBoxPRED(String title, String? value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value ?? 'N/A',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getBuses(String busNumber) async {
    try {
      final response = await http.get(Uri.parse(
          'https://firebasestorage.googleapis.com/v0/b/bus-time-prediction-20aba.appspot.com/o/data.json?alt=media&token=a88ee3a0-ab46-44f6-a668-132ab81cbd39'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        // Find the data for the matching bus number
        Map<String, dynamic>? buses = data['buses'][busNumber];

        if (buses != null) {
          // Return details for UI display
          return buses;
        } else {
          return {};
        }
      } else {
        print('HTTP Request Error - Status Code: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }
}
