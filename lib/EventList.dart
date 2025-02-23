import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'EventWidget.dart';

class EventList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
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
            int participansNumber = event['noOfparticipants'];
            int eventCapacity = event['capacity'];
            String eventImage = event['imageURL'];
            String eventDetails = event['Descriere'];
            String eventId = event.id;
            DateTime eventDate = event['date'].toDate();
            String eventDay = eventDate.day.toString() + '/' + eventDate.month.toString() + '/' + eventDate.year.toString();
            String eventTime = eventDate.hour.toString() + ':' + eventDate.minute.toString();
            String eventCategory = event['category'];

            if (eventDate.isAfter(DateTime.now())) {
              return EventWidget(
                eventName: eventName,
                location: LatLng(location.latitude, location.longitude),
                participansNumber: participansNumber,
                eventCapacity: eventCapacity,
                eventImage: eventImage,
                eventDetails: eventDetails,
                eventId: eventId,
                eventDay: eventDay,
                eventTime: eventTime,
                eventCategory: eventCategory,
              );
            } else {
              return null;
            }
          }).whereType<EventWidget>().toList()..sort((a, b) {
            DateFormat dateFormat = DateFormat('dd/MM/yyyy');
            DateTime aDate = dateFormat.parse(a.eventDay);  // Aici presupunem că ai data în formatul 'dd/MM/yyyy'
            DateTime bDate = dateFormat.parse(b.eventDay);  // Aceeași logică pentru b

           if (aDate.compareTo(bDate) != 0 )
             return aDate.compareTo(bDate);
           else
             return a.eventTime.compareTo(b.eventTime);  // Compară datele
          });
          return ListView(
            children: eventWidgets,
          );
        }
      },
    );
  }
}
