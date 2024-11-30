import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import 'EventWidget.dart';

class EventListFiltredPage extends StatelessWidget {
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final bool underTenParticipansCondition;
  final bool betweenTenTwentyParticipansCondition;
  final bool overTwentyParticipansCondition;
  final String selectedCounty;

  EventListFiltredPage({
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.underTenParticipansCondition,
    required this.betweenTenTwentyParticipansCondition,
    required this.overTwentyParticipansCondition,
    required this.selectedCounty,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(right: 60.0),
          child: Center(
            child: Text(
              'Rezultate',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.orangeAccent,
                    offset: Offset(0, 0),
                  ),
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.orangeAccent,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 100,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/Color.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('events').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Eroare în încărcarea evenimentelor',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.orangeAccent,
                  ),
                ),
              );
            } else if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('Nu există evenimente disponibile.'),
              );
            } else {
              bool thereAreNoEvents = true;
              List<Widget> eventWidgets = [];
              for (int index = 0; index < snapshot.data!.docs.length; index++) {
                final event = snapshot.data!.docs[index];
                GeoPoint location = event['location'];
                String eventName = event['Nume'];
                int participansNumber = event['noOfparticipans'];
                int eventCapacity = event['capacity'];
                String eventImage = event['imageURL'];
                String eventDetails = event['Descriere'];
                String eventId = event.id;
                DateTime eventDate = event['date'].toDate();
                String eventDay = eventDate.day.toString() + '/' +
                    eventDate.month.toString() + '/' +
                    eventDate.year.toString();
                String eventTime = eventDate.hour.toString() + ':' +
                    eventDate.minute.toString();


                if (eventDate.isAfter(selectedStartDate) &&
                    eventDate.isBefore(selectedEndDate) &&
                    noOfParticipansFilterConditon(eventCapacity) &&
                    locationFilterCondition(location, selectedCounty)) {
                  thereAreNoEvents = false;
                  eventWidgets.add(
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 3,
                        child: EventWidget(
                          eventName: eventName,
                          location: LatLng(
                              location.latitude, location.longitude),
                          participansNumber: participansNumber,
                          eventCapacity: eventCapacity,
                          eventImage: eventImage,
                          eventDetails: eventDetails,
                          eventId: eventId,
                          eventDay: eventDay,
                          eventTime: eventTime,
                        ),
                      ),
                    ),
                  );
                }
              }
              if (thereAreNoEvents) {
                eventWidgets.add(
                  Center(child: Text('Nu există evenimente')),
                );
              }

              return ListView(
                children: eventWidgets,
              );
            }
          },
        ),
      ),
    );
  }

  bool noOfParticipansFilterConditon(int eventCapacity) {
    if (underTenParticipansCondition)
      if (eventCapacity < 10)
        return true;
    if (betweenTenTwentyParticipansCondition)
      if (10 <= eventCapacity && eventCapacity <= 20)
        return true;
    if (overTwentyParticipansCondition)
      if (eventCapacity > 20)
        return true;

    return false;
  }

  bool locationFilterCondition(GeoPoint location, String county) {
    // Definire Harta Judete Romania
    final Map<String, Map<String, dynamic>> countyData = {
      'Alba': {'latitude': 46.07, 'longitude': 23.58, 'radius': 40.0},
      'Arad': {'latitude': 46.17, 'longitude': 21.32, 'radius': 50.0},
      'Argeș': {'latitude': 44.86, 'longitude': 24.87, 'radius': 55.0},
      'Bacău': {'latitude': 46.58, 'longitude': 26.92, 'radius': 80.0},
      'Bihor': {'latitude': 47.18, 'longitude': 21.38, 'radius': 70.0},
      'Bistrița-Năsăud': {'latitude': 47.29, 'longitude': 24.40, 'radius': 65.0},
      'Botoșani': {'latitude': 47.74, 'longitude': 26.67, 'radius': 60.0},
      'Brăila': {'latitude': 45.27, 'longitude': 27.97, 'radius': 50.0},
      'Brașov': {'latitude': 45.65, 'longitude': 25.60, 'radius': 60.0},
      'București': {'latitude': 44.43, 'longitude': 26.10, 'radius': 25.0},
      'Buzău': {'latitude': 45.15, 'longitude': 26.81, 'radius': 50.0},
      'Călărași': {'latitude': 44.21, 'longitude': 27.33, 'radius': 45.0},
      'Caraș-Severin': {'latitude': 45.29, 'longitude': 21.86, 'radius': 60.0},
      'Cluj': {'latitude': 46.77, 'longitude': 23.60, 'radius': 60.0},
      'Constanța': {'latitude': 44.17, 'longitude': 28.63, 'radius': 70.0},
      'Covasna': {'latitude': 45.86, 'longitude': 26.18, 'radius': 40.0},
      'Dâmbovița': {'latitude': 44.93, 'longitude': 25.46, 'radius': 40.0},
      'Dolj': {'latitude': 44.31, 'longitude': 23.82, 'radius': 85.0},
      'Galați': {'latitude': 45.43, 'longitude': 28.05, 'radius': 60.0},
      'Giurgiu': {'latitude': 43.92, 'longitude': 25.97, 'radius': 40.0},
      'Gorj': {'latitude': 45.05, 'longitude': 23.39, 'radius': 65.0},
      'Harghita': {'latitude': 46.35, 'longitude': 25.80, 'radius': 50.0},
      'Hunedoara': {'latitude': 45.78, 'longitude': 22.91, 'radius': 60.0},
      'Ialomița': {'latitude': 44.59, 'longitude': 27.37, 'radius': 45.0},
      'Iași': {'latitude': 47.17, 'longitude': 27.57, 'radius': 60.0},
      'Ilfov': {'latitude': 44.54, 'longitude': 26.13, 'radius': 35.0},
      'Maramureș': {'latitude': 47.66, 'longitude': 24.67, 'radius': 65.0},
      'Mehedinți': {'latitude': 44.62, 'longitude': 22.71, 'radius': 60.0},
      'Mureș': {'latitude': 46.54, 'longitude': 24.57, 'radius': 60.0},
      'Neamț': {'latitude': 47.17, 'longitude': 26.36, 'radius': 60.0},
      'Olt': {'latitude': 44.58, 'longitude': 24.53, 'radius': 45.0},
      'Prahova': {'latitude': 44.94, 'longitude': 26.02, 'radius': 55.0},
      'Satu Mare': {'latitude': 47.80, 'longitude': 22.87, 'radius': 40.0},
      'Sălaj': {'latitude': 47.20, 'longitude': 23.06, 'radius': 45.0},
      'Sibiu': {'latitude': 45.80, 'longitude': 24.15, 'radius': 50.0},
      'Suceava': {'latitude': 47.63, 'longitude': 26.25, 'radius': 80.0},
      'Teleorman': {'latitude': 43.99, 'longitude': 25.34, 'radius': 45.0},
      'Timiș': {'latitude': 45.75, 'longitude': 21.23, 'radius': 70.0},
      'Tulcea': {'latitude': 45.18, 'longitude': 28.80, 'radius': 80.0},
      'Vaslui': {'latitude': 46.64, 'longitude': 27.73, 'radius': 65.0},
      'Vâlcea': {'latitude': 45.09, 'longitude': 24.36, 'radius': 50.0},
      'Vrancea': {'latitude': 45.69, 'longitude': 27.19, 'radius': 70.0},
    };
    if (!countyData.containsKey(county)) {
      throw Exception('Județul $county nu a fost găsit în datele disponibile.');
    }

    final countyInfo = countyData[county];

    final double distance = calculateDistance(
      location.latitude,
      location.longitude,
      countyInfo!['latitude'],
      countyInfo['longitude'],
    );

    print('distance: $distance');
    print('radius $countyInfo[radius]');
    print('location: $location');
    print('selectedCounty: $county');
    return distance <= countyInfo['radius'];
  }
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = pow(sin(dLat / 2), 2) +
        pow(sin(dLon / 2), 2) * cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2));
    double c = 2 * asin(sqrt(a));
    double distance = earthRadius * c;

    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}

