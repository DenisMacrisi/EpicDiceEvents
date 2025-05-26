import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'CustomWidgets.dart';

class EventWidgetSummary extends StatelessWidget {
  final String eventName;
  final String eventId;
  final LatLng location;
  final String eventDay;
  final String eventTime;
  final double eventRating;

  const EventWidgetSummary({
    Key? key,
    required this.eventName,
    required this.eventId,
    required this.location,
    required this.eventDay,
    required this.eventTime,
    required this.eventRating,
  }) : super(key: key);

  bool _isEventInFuture() {

    try {
      final eventDateTime = DateFormat("dd/MM/yyyy HH:mm").parse('$eventDay $eventTime');
      return eventDateTime.isAfter(DateTime.now());
    } catch (e) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFuture = _isEventInFuture();
    print("isFuture:  $isFuture");

    if (isFuture) {
      return Card(
        color: Colors.lightBlue[50],
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eventName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Location: $location",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 6),
              Text(
                "Date: $eventDay at $eventTime",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        color: Colors.grey[200],
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eventName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.orangeAccent,size: 24.0,),
                  SizedBox(width: 4),
                  Text(
                    eventRating.toStringAsFixed(1),
                    style: TextStyle(fontSize: 20, color: Colors.grey[700], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  openEvaluateEventWindow(context, eventId);
                },
                style: SimpleButtonStyle(12.0, 10.0, Colors.orangeAccent, 5.0),
                child: Text(
                    "Evalueaza",
                  style: customBasicTextStyle(16.0, true),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

/// Function used to open the window for event rating
/// Function only return an AlertDialog
Future<void> openEvaluateEventWindow(BuildContext context, String eventId) async {
  int selectedRating = 0;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: Color.fromRGBO(3, 220, 255, 50),
            title: Text(
              "Evaluează evenimentul",
              style: customOrangeShadowTextStyle(24.0),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.orangeAccent,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedRating = index + 1;
                    });
                  },
                );
              }),
            ),
            actions: [
              ElevatedButton(
                style: SimpleButtonStyle(12.5, 10.0, Colors.orangeAccent, 3),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                    "Anulează",
                  style: customBasicTextStyle(14, false),
                ),
              ),
              ElevatedButton(
                style: SimpleButtonStyle(12.5, 10.0, Colors.orangeAccent, 3),
                onPressed: () {
                  if(selectedRating == 0){
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Nu ai selectat o evaluare pentru eveniment. Te rugăm să repeți acțiunea",
                          style: customSnackBoxTextStyle(20, Colors.white),
                        ),
                        backgroundColor: Colors.orangeAccent,
                      ),
                    );
                    return;
                  }
                  else {
                    submitRatingToFirebase(eventId, selectedRating, context);
                  }
                },
                child: Text(
                    "Trimite",
                  style: customBasicTextStyle(14, false),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
/// Function used to submit rating to Firebase
Future<void> submitRatingToFirebase(String eventId, int rating, BuildContext context) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String? userId = auth.currentUser?.uid;

  final DocumentReference eventRef = firestore.collection('events').doc(eventId);

  try {
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(eventRef);

      final data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> evaluators = data['evaluators'] ?? [];
      int noReviewers = data['noReviewers'];
      int totalStars = data['totalStars'];
      String host = data['host'];

      if (evaluators.contains(userId)) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Ai evaluat deja acest eveniment. Mulțumim !",
              style: customSnackBoxTextStyle(20, Colors.white),
            ),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        return;
      }

      evaluators.add(userId);

      transaction.update(eventRef, {
        'evaluators': evaluators,
        'noReviewers': noReviewers + 1,
        'totalStars': totalStars + rating,
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Evaluare trimisă cu succes! Mulțumim !",
            style: customSnackBoxTextStyle(20, Colors.white),
          ),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    });
  } catch (e) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "A apărut o eroare la trimiterea evaluării: $e",
          style: customSnackBoxTextStyle(20, Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
