import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  late LatLng _currentLocation;

  Set<Marker> _markers = Set<Marker>(); // Set pentru a stoca marcatorii

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
      Marker marker = Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(location.latitude, location.longitude),
        infoWindow: InfoWindow(
          title: doc['Nume'],
          snippet: doc['Descriere'],
        ),
      );
      print(marker.toString());
      newMarkers.add(marker);
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
            padding: const EdgeInsets.only(top: 99),
            child: GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: _currentLocation ?? LatLng(0, 0),
                zoom: 15.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: _markers,
            ),
          ),
        ],
      ),
    );
  }
}