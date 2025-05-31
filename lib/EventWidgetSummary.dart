import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'CustomWidgets.dart';
import 'EventWidget.dart';

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
      final eventDateTime = DateFormat("dd/MM/yyyy HH:mm").parse(
          '$eventDay $eventTime');
      return eventDateTime.isAfter(DateTime.now());
    } catch (e) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFuture = _isEventInFuture();
    print("isFuture:  $isFuture");

    return FutureBuilder<String>(
      future: getAddressFromCoordinates(location.latitude, location.longitude),
      builder: (context, snapshot) {
        String addressText = "Locație necunoscută";
        if (snapshot.connectionState == ConnectionState.waiting) {
          addressText = "Se încarcă adresa...";
        } else if (snapshot.hasError) {
          addressText = "Eroare la încărcarea adresei";
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          addressText = snapshot.data!;
        }

        if (isFuture) {
          return Card(
            color: Colors.lightBlue[50],
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventName,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.orangeAccent,
                        size: 40,
                      ),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          "Location: $addressText",
                          style: customBasicTextStyle(18, true, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        color: Colors.orangeAccent,
                        size: 40,
                      ),
                      Text(
                        " Date: $eventDay at $eventTime",
                        style: customBasicTextStyle(20, true, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          // Evenimentul trecut, UI rămâne neschimbat
          return Card(
            color: Colors.grey[200],
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventName,
                    style: customBasicTextStyle(30, true, color: Colors.black)
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orangeAccent, size: 40.0),
                      SizedBox(width: 4),
                      Text(
                        eventRating.toStringAsFixed(1),
                        style: customBasicTextStyle(30, true),
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
                      style: customBasicTextStyle(20.0, true),
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
