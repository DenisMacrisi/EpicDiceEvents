import 'package:cloud_firestore/cloud_firestore.dart';
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
    _currentLocation = LatLng(0, 0);
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
      if(distance <= selectedDistance) {
        if (eventTime.isAfter(today) &&
            eventTime.isBefore(today.add(Duration(days: 1)))) {
          print("Eveniment data: $eventTime");
          Marker marker = Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: doc['Nume'],
              snippet: doc['Descriere'],
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Text(
              'Harta',
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
        backgroundColor: Color.fromRGBO(3, 220, 255, 100),
        elevation: 100,

      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 82),
            child: GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(45.9432, 24.9668), // Coordonatele centrului României
                zoom: 5.9, // Nivelul de zoom potrivit pentru a afișa întreaga țară
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: _markers,
            ),
          ),
          Positioned(
              bottom: 0,
              right: 50,
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
                          _getLocationMarkers(); // Reafisăm markerele când se schimbă distanța
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

double calculateDistanceBetweenEventLocationAndUserLocation(double lat1, double lon1, double lat2, double lon2) {
  const double R = 6371; // Raza Pământului în kilometri
  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);
  double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
          math.sin(dLon / 2) * math.sin(dLon / 2);
  double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  double distance = R * c;
  return distance;
}
double _toRadians(double degree) {
  return degree * math.pi / 180;
}
