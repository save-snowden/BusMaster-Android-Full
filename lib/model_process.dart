// ignore_for_file: avoid_print, unused_import

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ModelProcess {
  String? timestamp;
  double? prediction;
  String? schoolEncoded;
  String? companyEncoded;
  String? trafficEncoded;
  String? weatherEncoded;
  int? day;
  int? hour;

  String _formatTime(double? time) {
    if (time == null) {
      return 'N/A';
    }

    int hours = time ~/ 60;
    int minutes = (time % 60).round();
    return '$hours hours and $minutes minutes after the depature';
  }

  // Singleton instance
  static final ModelProcess _instance = ModelProcess._internal();

  factory ModelProcess() {
    return _instance;
  }

  ModelProcess._internal();

  Future<void> setTimestamp(String timestamp) async {
    // Remove milliseconds from the timestamp
    timestamp = timestamp.split('.')[0];

    this.timestamp = timestamp;
    print('Timestamp: $timestamp');

    // Send timestamp to API and get predictions
    await _fetchPredictions(timestamp);

    // Format and display the predictions
    print('Predicted Travel Time: ${_formatTime(prediction)}');
    print('School Encoded: $schoolEncoded');
    print('Company Encoded: $companyEncoded');
    print('Traffic Encoded: $trafficEncoded');
    print('Weather Encoded: $weatherEncoded');
    print('Day: $day');
    print('Hour: $hour');
  }

  Future<void> _fetchPredictions(String timestamp) async {
    // API endpoint
    var apiUrl = 'https://bus-prediction.azurewebsites.net/predict';

    // Create JSON payload
    var payload = {'datetime': timestamp};

    try {
      // Send POST request to the API
      var response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(payload),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Parse JSON response
        var jsonResponse = json.decode(response.body);

        // Extract the first element of the predicted time array
        prediction = _toDouble(jsonResponse['prediction'][0]);
        schoolEncoded = _toString(jsonResponse['school_encoded']);
        companyEncoded = _toString(jsonResponse['company_encoded']);
        trafficEncoded = _toString(jsonResponse['traffic_encoded']);
        weatherEncoded = _toString(jsonResponse['weather_encoded']);
        day = _toInt(jsonResponse['day']);
        hour = _toInt(jsonResponse['hour']);
      } else {
        print(
            'Failed to fetch predictions. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching predictions: $e');
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }

  String _toString(dynamic value) {
    if (value is String) {
      return value;
    }
    return '';
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return 0;
  }
}
