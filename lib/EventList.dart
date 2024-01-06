import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'EventWidget.dart';

class EventList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(

      future: FirebaseFirestore.instance.collection('events').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {

          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {

          return Center(
            child: Text('Error loading events'),
          );
        } else {
          List<EventWidget> eventWidgets = snapshot.data!.docs.map((event) {
            GeoPoint location = event['location'];
            String eventName = event['Nume'];

            return EventWidget(
              eventName: eventName,
              location: LatLng(location.latitude, location.longitude),
            );
          }).toList();

          return ListView(
            children: eventWidgets,
          );
        }
      },
    );
  }
}