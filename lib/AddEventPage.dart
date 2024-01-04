

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class AddEventPage extends StatefulWidget {

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {

  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _eventDescriptionController = TextEditingController();

  CollectionReference _eventsReference = FirebaseFirestore.instance.collection('events');

  GlobalKey<FormState> key = GlobalKey();

  File? _selectedImage;

  GoogleMapController? _mapController;
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _selectedLocation;
  LatLng? _currentLocation;

  Set<Marker> _markers = {}; // Folosiți un set de markere

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();

    try {
      LocationData locationData = await location.getLocation();
      setState(() {
        _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(right:60.0) ,
          child: Center(
            child: Text(
              'Adaugare',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
                color: Colors.white, // Culoarea textului
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
        elevation: 100, // Elimină umbra sub AppBar
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/Color.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: key,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _eventNameController,
                        decoration: InputDecoration(hintText: 'Nume eveniment'),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Introdu nume eveniment';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _eventDescriptionController,
                        decoration: InputDecoration(hintText: 'Descriere'),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Introdu descriere';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: 300,
                        height: 150,
                        color: Colors.white,
                        child: _selectedImage != null
                            ? Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      SizedBox(height: 20),
                      IconButton(onPressed: () async{
                        await _pickImageFromGallery();
                        print(_selectedImage);
                      },
                          icon: Icon(Icons.camera_alt),),
                      Container(
                        width: 400,
                        height: 250,
                        color: Colors.white,
                        child: GoogleMap(
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          initialCameraPosition: CameraPosition(
                            target: _currentLocation ?? LatLng(0, 0),
                            zoom: 15.0,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                            _onMapCreated(controller);
                          },
                          onTap: _onMapTap,
                          markers: _markers,
                        )
                      ),
                      SizedBox(height: 20.0,),
                      ElevatedButton(onPressed: (){

                      }, child: Text("Gata",

                      ),
                      ),

                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      print(_selectedLocation);

      // Eliminați toate markerele anterioare
      _markers.clear();

      // Adăugați un nou marker și actualizați _markers
      _markers.add(Marker(
        markerId: MarkerId(_selectedLocation.toString()),
        position: _selectedLocation!,
        infoWindow: InfoWindow(
          title: 'Locul evenimentului',
          snippet: 'Descrierea locului',
        ),
      ));

      // Actualizați widget-ul GoogleMap cu noile markere
      _mapController?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
    });
  }

  Future _pickImageFromGallery() async {
   final returnImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = File(returnImage!.path);
    });
  }
}