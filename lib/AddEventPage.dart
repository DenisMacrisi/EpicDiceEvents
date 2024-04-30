

import 'dart:io';
import 'dart:math';
import 'package:epic_dice_events/Errors.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:epic_dice_events/DatabaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'HomePage.dart';

class AddEventPage extends StatefulWidget {

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {

  int capacity  = 0;

  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _eventDescriptionController = TextEditingController();
  TextEditingController _eventNumberOfParticipansController = TextEditingController();

  CollectionReference _eventsReference = FirebaseFirestore.instance.collection('events');

  GlobalKey<FormState> key = GlobalKey();

  File? _selectedImage;

  GoogleMapController? _mapController;
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _selectedLocation;
  LatLng? _currentLocation;

  Set<Marker> _markers = {};
  DateTime _selectedDateTime = DateTime.now();


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
                      TextFormField(
                        controller: _eventNumberOfParticipansController,
                        decoration: InputDecoration(hintText: 'Numar de participanti'),
                        keyboardType: TextInputType.number, // Adăugat pentru a forța tastatura numerică
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Introdu numar participanti';
                          }
                          // Adaugă validare pentru a verifica dacă este un număr întreg
                          try {
                            capacity = int.tryParse(_eventNumberOfParticipansController.text)!;
                            if (capacity <= 0) {
                              return 'Numarul de participanti trebuie sa fie mai mare decat zero';
                            }
                          } catch (e) {
                            return 'Introdu un numar valid';
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _selectedDateTime = _selectDateTime(context) as DateTime; // Adăugat funcția pentru selectarea datei și orei
                        },
                        child: Text('Selectează data și ora'),
                      ),
                      Text(
                        'Data: ${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 5), // Spațiu între textele de data și ora
                      Text(
                        'Ora: ${_selectedDateTime.hour}:${_selectedDateTime.minute}',
                        style: TextStyle(fontSize: 16),
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
                          icon: Icon(Icons.camera_alt),
                      ),
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
                      ElevatedButton(onPressed: () async{
                        if (_selectedImage != null) {
                          String? image_name = generateUniqueImageName();
                          print("image name : " + image_name);
                          String? imageUrl = await uploadImageToStorage(
                              _selectedImage!, image_name);
                          capacity = int.tryParse(_eventNumberOfParticipansController.text) ?? 0;
                          if( addNewEventToDatabase(_eventDescriptionController.text, _eventNameController.text, capacity, imageUrl!, _currentLocation!, _selectedDateTime) == 1 ) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
                          }
                        }
                        else{
                          showIncompleteDataError(context);
                        }

                      },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.5),
                          ),
                          elevation: 10.0,
                          side: BorderSide(
                            color: Colors.orangeAccent,
                            width: 3.0,
                          ),
                        ),
                        child: Text("Gata",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.black, // Culoarea textului
                        ),
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

  Future<DateTime> _selectDateTime(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    ))!;

    final TimeOfDay timePicked = (await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ))!;

    if (picked != null && timePicked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          timePicked.hour,
          timePicked.minute,
        );
      });
    }
    return _selectedDateTime;
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
          title: "Nume ",
          snippet: "Descriere ",
        ),
      ));


      _mapController?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
    });
  }

  Future _pickImageFromGallery() async {
   final returnImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = File(returnImage!.path);
    });
  }

  Future<String?> uploadImageToStorage(File imageFile, String imageName) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child(imageName);

      await ref.putFile(imageFile);


      String downloadURL = await ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Eroare la încărcarea imaginii: $e');
      return null;
    }
  }

  String generateUniqueImageName() {

    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();


    String random = Random().nextInt(1000).toString();

    return 'image_'+timestamp+'_'+random;
  }


  Future <int> addNewEventToDatabase(String Details, String Name, int Capacity, String ImageURL, LatLng Location, DateTime dateTime )async {
    
    if(Details.isEmpty || Name.isEmpty || Capacity == 0 || Location == null || ImageURL.isEmpty){
      
      showIncompleteDataError(context);
      return 0;
    }
    
    CollectionReference events = FirebaseFirestore.instance.collection('events');
    String eventId = await generateUniqueEventId();

    DocumentReference userDocRef = events.doc(eventId);

    await userDocRef.set({
      'Descriere': Details,
      'Nume': Name,
      'noOfparticipans' : 0,
      'capacity': Capacity,
      'imageURL' : ImageURL,
      'location' : GeoPoint(Location.latitude, Location.longitude),
      'date': dateTime,
    });
/*
    print("NewEventId : " + eventId);
    print("Details : " + Details);
    print(Capacity);
    print("Name : " + Name);
    print(_currentLocation);

 */
  return 1;
  }

  String generateUniqueEventId() {

    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();


    String random = Random().nextInt(1000).toString();

    return 'event_'+timestamp+'_'+random;
  }

}