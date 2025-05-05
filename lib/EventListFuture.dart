import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'EventWidgetSummary.dart';

class EventListFuture extends StatelessWidget {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // Functie care returnează evenimentele
  Future<List<EventWidgetSummary>> _loadEvents() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('events').get();

    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    List<EventWidgetSummary> result = [];

    print('UID-ul curent este: $currentUserId');  // Debug: UID-ul utilizatorului curent

    for (var doc in snapshot.docs) {
      DateTime eventDate = doc['date'].toDate();

      // Verificăm dacă evenimentul este în viitor
      if (eventDate.isAfter(now)) {
        // Debug: Afișăm ID-ul evenimentului și data acestuia
        print('Eveniment: ${doc.id}, Data evenimentului: $eventDate');

        // Verificăm dacă utilizatorul este în subcolecția participantsList
        var participantsDoc = await doc.reference
            .collection('participantsList')
            .doc(currentUserId) // Verificăm dacă documentul cu ID-ul utilizatorului există
            .get();

        // Debug: Afișăm subcolectia participantsList si documentul curent
        var participantsSnapshot = await doc.reference.collection('participantsList').get();
        print('Subcolectia participantsList pentru evenimentul ${doc.id}:');
        participantsSnapshot.docs.forEach((participant) {
          print('UID participant: ${participant.id}');
        });

        if (participantsDoc.exists) {
          // Debug: Afișăm un mesaj când utilizatorul este găsit în subcolecția participantsList
          print('Utilizatorul $currentUserId este participant la evenimentul ${doc.id}');

          GeoPoint location = doc['location'];
          String eventName = doc['Nume'];
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
          ));
        } else {
          // Debug: Afișăm un mesaj când utilizatorul nu este găsit în subcolecția participantsList
          print('Utilizatorul $currentUserId NU este participant la evenimentul ${doc.id}');
        }
      }
    }

    // Sortează lista în ordine descrescătoare
    result.sort((a, b) {
      DateTime aDate = dateFormat.parse('${a.eventDay} ${a.eventTime}');
      DateTime bDate = dateFormat.parse('${b.eventDay} ${b.eventTime}');
      return bDate.compareTo(aDate); // DESC
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
          return Center(child: Text('Nu ai participat la niciun eveniment viitor.'));
        } else {
          return ListView(children: snapshot.data!);
        }
      },
    );
  }
}
