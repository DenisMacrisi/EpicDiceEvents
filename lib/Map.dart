import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epic_dice_events/CustomWidgets.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'dart:math' as math;

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  late LatLng _currentLocation;

  Set<Marker> _markers = Set<Marker>(); // Set pentru a stoca marcatorii

  double selectedDistance = 100;
  List<double> distanceOptions = [5,10,15,20,100,500];
  int selectedDays = 1;
  List<int> daysOptions = [1,2,3,5,7,30];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _getLocationMarkers();
  }

  Future<void> _getCurrentLocation() async {
    _currentLocation = LatLng(45.9432, 24.9668);
    Location location = Location();

    try {
      LocationData locationData = await location.getLocation();
      setState(() {
        _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      });
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        _currentLocation = LatLng(0.0, 0.0);
      });
    }
  }

  Future<void> _getLocationMarkers() async {
    CollectionReference events = FirebaseFirestore.instance.collection('events');
    QuerySnapshot querySnapshot = await events.get();

    Set<Marker> newMarkers = Set<Marker>();

    querySnapshot.docs.forEach((doc) {
      GeoPoint location = doc['location'];
      DateTime now = DateTime.now();
      DateTime eventTime = (doc['date'] as Timestamp).toDate();
      DateTime today = DateTime(now.year, now.month, now.day);

      double distance = calculateDistanceBetweenEventLocationAndUserLocation(_currentLocation.latitude, _currentLocation.longitude, location.latitude, location.longitude);
      int days = 1;
      if(distance <= selectedDistance) {
        if (eventTime.isAfter(today) &&
            eventTime.isBefore(today.add(Duration(days: selectedDays)))) {
          print("Eveniment data: $eventTime");
          Marker marker = Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: doc['Nume'],
              snippet: doc['Descriere'],
            ),
            onTap: () {
              //_showEventDetails(doc);
            },
          );
          print("Added marker: $marker");
          newMarkers.add(marker);
        }
      }
    });


    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }

  void _showEventDetails(QueryDocumentSnapshot doc) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc['Nume'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 5.0),
              Text(
                doc['Descriere'],
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 10.0),
              Image.network(
                doc['imageURL'], // URL-ul imaginii
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        title: 'Harta',
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 82),
            child: GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(45.9432, 24.9668),
                zoom: 5.9,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: _markers,
            ),
          ),
          Positioned(
              bottom: 0,
              right: 130,
              child: Container(
                  decoration: BoxDecoration(
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distanta: ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        DropdownButton<double>(
                          value: selectedDistance,
                          items: distanceOptions.map((double distance) {
                            return DropdownMenuItem<double>(
                              value: distance,
                              child: Text('$distance km'),
                            );
                          }).toList(),
                          onChanged: (double? newValue) {
                            setState(() {
                              selectedDistance = newValue!;
                              _getLocationMarkers();
                            });
                          },
                        ),
                      ]
                  )
              )
          ),Positioned(
              bottom: 0,
              right: 240,
              child: Container(
                  decoration: BoxDecoration(
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zile: ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        DropdownButton<int>(
                          value: selectedDays,
                          items: daysOptions.map((int days) {
                            return DropdownMenuItem<int>(
                              value: days,
                              child: Text('$days zile'),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              selectedDays = newValue!;
                              _getLocationMarkers();
                            });
                          },
                        ),
                      ]
                  )
              )
          )
        ],
      ),
    );
  }
}

// source: https://www.movable-type.co.uk/sncripts/latlong.html
double calculateDistanceBetweenEventLocationAndUserLocation(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371; // Raza Pământului în kilometri
  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);
  double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
          math.sin(dLon / 2) * math.sin(dLon / 2);
  double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  double distance = earthRadius * c;
  return distance;
}
double _toRadians(double degree) {
  return degree * math.pi / 180;
}
