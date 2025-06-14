import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'EventWidgetSummary.dart';

typedef EventFilter = bool Function(DateTime eventDate, bool isEventActive);

class EventSummaryGenericList extends StatelessWidget {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final EventFilter filter;
  EventSummaryGenericList({super.key, required this.filter});

  Future<List<EventWidgetSummary>> _loadEvents() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('events').get();

    DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    List<EventWidgetSummary> result = [];

    for (var doc in snapshot.docs) {
      DateTime eventDate = doc['date'].toDate();
      bool isEventActive = doc['isEventActive'];

      if (filter(eventDate, isEventActive)) {
        var participantDoc = await doc.reference
            .collection('participantsList')
            .doc(currentUserId)
            .get();

        if (participantDoc.exists) {
          GeoPoint location = doc['location'];
          String eventName = doc['name'];
          String eventId = doc.id;

          String eventDay =
              '${eventDate.day.toString().padLeft(2, '0')}/${eventDate.month.toString().padLeft(2, '0')}/${eventDate.year}';
          String eventTime =
              '${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}';

          double eventRating = doc['noReviewers'] > 0
              ? doc['totalStars'] / doc['noReviewers']
              : 0;

          result.add(EventWidgetSummary(
            eventName: eventName,
            location: LatLng(location.latitude, location.longitude),
            eventId: eventId,
            eventDay: eventDay,
            eventTime: eventTime,
            eventRating: eventRating,
            isEventActive: isEventActive,
          ));
        }
      }
    }

    result.sort((a, b) {
      DateTime aDate = dateFormat.parse('${a.eventDay} ${a.eventTime}');
      DateTime bDate = dateFormat.parse('${b.eventDay} ${b.eventTime}');
      return bDate.compareTo(aDate);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EventWidgetSummary>>(
      future: _loadEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Eroare la încărcare evenimente.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Nu există evenimente de afișat'));
        } else {
          return ListView(children: snapshot.data!);
        }
      },
    );
  }

}