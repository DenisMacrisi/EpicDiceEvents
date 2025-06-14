import 'dart:io';
import 'dart:math';
import 'package:epic_dice_events/CustomWidgets.dart';
import 'package:epic_dice_events/Errors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';

import 'HomePage.dart';

class AddEventPage extends StatefulWidget {

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {

  List<String> categoryGameList = ['Strategie', 'Zaruri', 'Gateway', 'Diverse','Party','Carti'];
  String _selectedCategory = "";
  int capacity  = 0;

  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _eventDescriptionController = TextEditingController();
  TextEditingController _eventNumberOfParticipansController = TextEditingController();



  GlobalKey<FormState> key = GlobalKey();

  File? _selectedImage;

  GoogleMapController? _mapController;
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _selectedLocation;
  LatLng? _currentLocation;

  Set<Marker> _markers = {};
  DateTime _selectedDateTime = DateTime.now();

  String eventId = "aaa";


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
      appBar: const CustomAppBar(
        title: 'Adaugare',
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
                        decoration: InputDecoration(
                          hintText: 'Descriere: maxim 100 de caractere',
                          counterText: '',
                        ),
                          maxLength: 100,
                          validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Introdu descriere';
                          }
                          if(value.length > 100){
                            return 'Descrierea ta are mai mult de 100 de caractere';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _eventNumberOfParticipansController,
                        decoration: InputDecoration(hintText: 'Numar de participanti'),
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Introdu numar participanti';
                          }
                          try {
                            capacity = int.tryParse(_eventNumberOfParticipansController.text)!;
                            if (capacity <= 0) {
                              return 'Numarul de participanti trebuie sa fie mai mare decat zero';
                            }
                            if (capacity > 99) {
                              return 'Numarul de participanti trebuie sa fie mai mic decat 100';
                            }
                          } catch (e) {
                            return 'Introdu un numar valid';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      DropdownButton<String>(
                        value: _selectedCategory.isEmpty ? null : _selectedCategory,
                        hint: Text('Alege o categorie',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20),
                        ),
                        items: categoryGameList.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                                '$category',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final DateTime selectedDateTime = await _selectDateTime(context);
                          setState(() {
                            _selectedDateTime = selectedDateTime;
                          });
                        },
                        child: Text(
                            'Selectează data și ora',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.black
                          ),
                        ),
                      ),
                      Text(
                        'Data: ${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Ora: ${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                            fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),
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
                          String? imageUrl = await uploadImageToStorage(
                              _selectedImage!, image_name);
                          capacity = int.tryParse(_eventNumberOfParticipansController.text) ?? 0;
                          addNewEventToDatabase(
                            _eventDescriptionController.text,
                            _eventNameController.text,
                            capacity,
                            imageUrl!,
                            _selectedLocation ?? _currentLocation!,
                            _selectedDateTime,
                            _selectedCategory,
                          ).then((value) {
                            if (value == 1) {
                              addEventToEventsCreatedList();
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
                            }
                          }).catchError((error) {
                            print("Error adding event: $error");
                          });
                        } else {
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
                          color: Colors.black,
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
      builder: (context, child) {
        return Theme(data: ThemeData.light().copyWith(
          primaryColor: Colors.orangeAccent,
          colorScheme: ColorScheme.light(
            primary: Colors.orangeAccent,
            onPrimary: Colors.white,
            onSurface: Colors.black,
            surface: Color.fromRGBO(3, 220, 255, 50),
          ),
          textTheme: TextTheme(
            labelLarge: TextStyle(
              fontSize: 24,
            ),
          ),
        ), child: child!,
        );
      }
    ))!;

    final TimeOfDay timePicked = (await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(data: ThemeData.light().copyWith(
            primaryColor: Colors.orangeAccent,
            colorScheme: ColorScheme.light(
              primary: Colors.orangeAccent,
              onPrimary: Colors.white,
              onSurface: Colors.black,
              surface: Color.fromRGBO(3, 220, 255, 50),
            ),
            textTheme: TextTheme(
              labelLarge: TextStyle(
                fontSize: 30,
              ),
            ),
          ), child: child!,
          );
        }
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
      _markers.clear();
      // Adăuga marker
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

/// Functie folosita pentru a adauga evenimentul in baza de date
  Future <int> addNewEventToDatabase(String Details, String Name, int Capacity, String ImageURL, LatLng Location, DateTime dateTime, String category )async {

    User? currentUser = FirebaseAuth.instance.currentUser;
    eventId = await generateUniqueEventId();

    if(Details.isEmpty || Name.isEmpty || Capacity == 0 || Location == null || ImageURL.isEmpty){
      
      showIncompleteDataError(context);
      return 0;
    }
    
    CollectionReference events = FirebaseFirestore.instance.collection('events');
    DocumentReference userDocRef = events.doc(eventId);

    await userDocRef.set({
      'description': Details,
      'name': Name,
      'noOfparticipants' : 0,
      'capacity': Capacity,
      'imageURL' : ImageURL,
      'location' : GeoPoint(Location.latitude, Location.longitude),
      'date': dateTime,
      'category': category,
      'host': currentUser?.uid,
      'totalStars': 0,
      'noReviewers': 0,
      'isEventActive': true,
      'isParticipantNotified':false
    });

  return 1;
  }

  /// Functie folosita pentru generarea unui Id unic
  String generateUniqueEventId() {

    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();


    String random = Random().nextInt(1000).toString();

    return 'event_'+timestamp+'_'+random;
  }

  /// Adauga Evenimentul in Lista de evenimente create de utilizatorul curent
  Future<void> addEventToEventsCreatedList() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      String userId = userSnapshot.id;

      bool collectionExists = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('eventsCreatedList')
          .doc(eventId)
          .get()
          .then((doc) => doc.exists);

      if (!collectionExists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('eventsCreatedList')
            .doc(eventId)
            .set({});
      }
    }
  }

}