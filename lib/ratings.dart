// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, duplicate_import

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'feedback_msg.dart';

class RatingsPage extends StatefulWidget {
  @override
  _RatingsPageState createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  bool _ratingsSubmitted = false;
  int driverRating = 0;
  int conductorRating = 0;
  String overallExperience = '';
  bool gifLoaded = false;

  @override
  void initState() {
    super.initState();

    // Load the GIF for 2.5 seconds during initialization
    Future.delayed(Duration(milliseconds: 2400), () {
      setState(() {
        gifLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent navigation back if ratings are submitted
        return !_ratingsSubmitted;
      },
      child: Scaffold(
        body: gifLoaded
            ? _buildPageContent()
            : Center(
                child: Image.asset(
                  'images/bus_turning.gif',
                ),
              ),
      ),
    );
  }

  Widget _buildPageContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildRatingSection(
            title: 'Rate the Driver',
            onRatingChanged: (rating) {
              setState(() {
                driverRating = rating;
              });
            },
            selectedRating: driverRating,
          ),
          SizedBox(height: 16),
          _buildRatingSection(
            title: 'Rate the Conductor',
            onRatingChanged: (rating) {
              setState(() {
                conductorRating = rating;
              });
            },
            selectedRating: conductorRating,
          ),
          SizedBox(height: 16),
          Text(
            'Overall Experience',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _buildExperienceInput(),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // Save ratings and overall experience
              // You can use these values for further processing or sending to an API
              print('Driver Rating: $driverRating');
              print('Conductor Rating: $conductorRating');
              print('Overall Experience: $overallExperience');

              // Set _ratingsSubmitted to true after successful submission.
              setState(() {
                _ratingsSubmitted = true;
              });

              String submitTimestampString =
                  DateTime.now().toUtc().toIso8601String();
              print(submitTimestampString);

              var payload = {'feedback': overallExperience};

              // Make the POST request
              final response = await http.post(
                Uri.parse('http://15.206.84.13:80/predict'),
                body: json.encode(payload),
                headers: {'Content-Type': 'application/json'},
              );
              // Check if the request was successful (status code 200)
              if (response.statusCode == 200) {
                // Parse the JSON response
                var jsonResponse = json.decode(response.body);

                // Extract feedback and predicted class
                String feedback = _toString(jsonResponse['feedback']);
                String predictedClass =
                    _toString(jsonResponse['predicted_class']);

                // Print the feedback and predicted class
                print('Feedback: $feedback');
                print('Predicted Class: $predictedClass');

                // Navigate to the next screen using pushReplacement
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedbackMsgPage(
                      feedback: feedback,
                      predictedClass: predictedClass,
                      submitTimestampString: submitTimestampString,
                    ),
                  ),
                );
              } else {
                // Print an error message if the request was not successful
                print('Error: ${response.statusCode}');
              }
            },
            child: Text('Submit Ratings'),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection({
    required String title,
    required ValueChanged<int> onRatingChanged,
    required int selectedRating,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => IconButton(
              iconSize: 50,
              icon: Icon(
                index < selectedRating ? Icons.star : Icons.star_border,
                color: index < selectedRating ? Colors.amber : null,
              ),
              onPressed: () {
                onRatingChanged(index + 1);
              },
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          _getRatingText(selectedRating),
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Very Poor';
      case 2:
        return 'Poor';
      case 3:
        return 'Good';
      case 4:
        return 'Great';
      case 5:
        return 'Wonderful';
      default:
        return '';
    }
  }

  Widget _buildExperienceInput() {
    return TextFormField(
      onChanged: (value) {
        overallExperience = value;
      },
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Write your overall experience...',
        border: OutlineInputBorder(),
      ),
    );
  }

  String _toString(dynamic value) {
    if (value is String) {
      return value;
    }
    return '';
  }
}
