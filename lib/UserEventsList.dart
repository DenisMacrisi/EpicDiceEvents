import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'UserEventWidget.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'EventWidget.dart';

class UserEventList extends StatelessWidget {
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
          List<UserEventWidget> eventWidgets = snapshot.data!.docs.map((event) {
            String eventName = event['name'];
            DateTime eventDate = event['date'].toDate();
            String eventDay = eventDate.day.toString() + '/' + eventDate.month.toString() + '/' + eventDate.year.toString();
            String eventTime = eventDate.hour.toString() + ':' + eventDate.minute.toString();

            if (eventDate.isAfter(DateTime.now())) {
              return UserEventWidget(
                eventName: eventName,
                eventDay: eventDay,
                eventTime: eventTime,
              );
            } else {
              return null;
            }
          }).whereType<UserEventWidget>().toList()..sort((a, b) {
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
