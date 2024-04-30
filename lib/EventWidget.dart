import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epic_dice_events/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'Errors.dart';

class EventWidget extends StatefulWidget {
  final String eventName;
  final LatLng location;
  late  int participansNumber;
  final int eventCapacity;
  final String eventImage;
  final String eventDetails;
  final String eventId;
  final String eventDay;
  final String eventTime;

  EventWidget({
    Key? key,
    required this.eventName,
    required this.location,
    required this.participansNumber,
    required this.eventCapacity,
    required this.eventImage,
    required this.eventDetails,
    required this.eventId,
    required this.eventDay,
    required this.eventTime,
  }) : super(key: key);

  @override
  _EventWidgetState createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {

  late String _address = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    try {
      String address = await getAddressFromCoordinates(widget.location.latitude, widget.location.longitude);
      setState(() {
        _address = address;
      });
    } catch (e) {
      setState(() {
        _address = 'Unknown';
      });
      print('Error loading address: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orangeAccent,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.eventName}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 5.0),
          Text(
            'Location: $_address',
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            'Disponibilitate: ${widget.participansNumber} / ${widget.eventCapacity} ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Image.network(
              widget.eventImage, // URL-ul imaginii
              width: 350,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            'Data: ${widget.eventDay}',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            'Ora: ${widget.eventTime}',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            '${widget.eventDetails}',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  print("S-a apasat Participa \n");
                  participateAction();
                },
                child: Text(
                  "Participa",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
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
              ),
              ElevatedButton(
                onPressed: () {
                  print("S-a apasat Retrage \n");
                  resignAction();
                },
                child: Text(
                  "Retrage",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> participateAction() async{
    if(await isUserRegistered()){
      showAlreadyRegistatedforEvent(context);
    }
    else {
      await registerUserToEvent();
      await addEventToUser();
      await increaseNumberOfParticipants();
      setState(() { widget.participansNumber++; });
    }
  }

  Future<void> resignAction() async{
    if(await isUserRegistered()){
      await unregisterUserFromEvent();
      await removeEventFromUser();
      await decreaseNumberOfParticipants();
      setState(() { widget.participansNumber--; });
    }
    else {
      showAlreadyUnRegistatedforEvent(context);
    }
  }

  Future<bool> isUserRegistered() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;

      bool subcollectionExists = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('participantsList')
          .doc(userId)
          .get()
          .then((doc) => doc.exists);

      return subcollectionExists;
    }
    return false;
  }


  Future <void> registerUserToEvent() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {

      DocumentSnapshot<
          Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
          .collection('users').doc(currentUser.uid).get();
      String userId = userSnapshot.id;

      String username = userSnapshot['username'];
      String email = userSnapshot['email'];

      print('Utilizator curent: $username, $email');

      bool subcollectionExists = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('participantsList')
          .doc(userId)
          .get()
          .then((doc) => doc.exists);

      if (!subcollectionExists) {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .collection('participantsList')
            .doc(userId)
            .set({});
      }
    }
  }

  Future<void> unregisterUserFromEvent() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;

      try {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .collection('participantsList')
            .doc(userId)
            .delete();

        print('Utilizatorul a fost deînregistrat de la eveniment cu succes.');
      } catch (error) {
        print('Eroare în timpul deînregistrării utilizatorului de la eveniment: $error');
      }
    }
  }

  Future<void> addEventToUser() async {
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
          .collection('eventsList')
          .doc(widget.eventId)
          .get()
          .then((doc) => doc.exists);

      if (!collectionExists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('eventsList')
            .doc(widget.eventId)
            .set({});
      }
    }
  }

  Future<void> removeEventFromUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('eventsList')
            .doc(widget.eventId)
            .delete();

        print('Evenimentul a fost eliminat cu succes din lista utilizatorului.');
      } catch (error) {
        print('Eroare în timpul eliminării evenimentului din lista utilizatorului: $error');
      }
    }
  }


  Future<void> increaseNumberOfParticipants() async {
    try {
      DocumentReference<Map<String, dynamic>> eventRef = FirebaseFirestore.instance.collection('events').doc(widget.eventId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction.get(eventRef);
        if (snapshot.exists) {
          int currentParticipants = snapshot['noOfparticipans'];
          transaction.update(eventRef, {'noOfparticipans': currentParticipants + 1});
        } else {
          print('Evenimentul cu ID-ul $widget.eventId nu există.');
        }
      });
    } catch (e) {
      print('Eroare la incrementarea participanților: $e');
    }
  }

  Future<void> decreaseNumberOfParticipants() async {
    try {
      DocumentReference<Map<String, dynamic>> eventRef = FirebaseFirestore.instance.collection('events').doc(widget.eventId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction.get(eventRef);
        if (snapshot.exists) {
          int currentParticipants = snapshot['noOfparticipans'];
          transaction.update(eventRef, {'noOfparticipans': currentParticipants - 1});
        } else {
          print('Evenimentul cu ID-ul $widget.eventId nu există.');
        }
      });
    } catch (e) {
      print('Eroare la incrementarea participanților: $e');
    }
  }
}

// Funcție care convertește coordonatele în adresă
Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks != null && placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      return placemark.street ?? ''; // Sau orice altă proprietate a obiectului Placemark pe care dorești să o afișezi
    }
  } catch (e) {
    print('Eroare la obținerea adresei: $e');
  }
  return '';
}