import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

import 'CustomWidgets.dart';
import 'Errors.dart';
import 'HomePage.dart';

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
  final String eventCategory;
  final bool isEventActive;

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
    required this.eventCategory,
    required this.isEventActive,
  }) : super(key: key);

  @override
  _EventWidgetState createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {

  late String _address = 'Loading...';
  late bool _isUserRegistered = false;
  late bool _isCurrentUserHost = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
    _checkRegistrationForEvent();
    _checkIfUserIsHost();
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
  Future<void> _checkIfUserIsHost() async {
    try {
      bool hostStatus = await isCurrentUserTheHost();
      setState(() {
        _isCurrentUserHost = hostStatus;
      });
    } catch (e) {
      print('Eroare la verificarea hostului: $e');
    }
  }

  Future<void> _checkRegistrationForEvent() async{
    try {
      bool i = await isUserRegisteredForEvent();
      setState(() {
        _isUserRegistered = i;
      });
    }catch(e){
      print('Eroare');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (){
          _showParticipantsDialog(context);
      },
      child: Container(
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
            InkWell(
              onTap:() async {
                String encodedAddress = Uri.encodeComponent(_address);
                String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$encodedAddress";

                if (await canLaunch(googleMapsUrl)) {
                  await launch(googleMapsUrl);
                } else {
                  throw 'Nu s-a putut deschide harta';
                }
              },
              child: Text(
                'Locatie: $_address',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  //decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Participare: ${widget.participansNumber} / ${widget.eventCapacity} ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(12.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orangeAccent.withOpacity(0.5),
                        blurRadius: 10.0,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                 padding: EdgeInsets.symmetric(horizontal: 10.0),
                 child: Text(
                    '${widget.eventCategory}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                    Icons.check,
                  color: _isUserRegistered? Colors.green: Colors.transparent,
                  size: 40,
                ),
              ]
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
            Row(
              children: [
                Text(
                  'Data: ${widget.eventDay}',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "               ",
                ),
                Text(
                  'Ora: ${formatTime(widget.eventTime)}',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
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
      ),
    );
  }

  /// Function to perform participate from event actions
  Future<void> participateAction() async{
    if(await isUserRegisteredForEvent()){
      showAlreadyRegistatedforEvent(context);
    }
    else {
      if(await checkForCapacity()) {
        await registerUserToEvent();
        await addEventToUser();
        await increaseNumberOfParticipants();
        setState(() {
          widget.participansNumber++;
          _isUserRegistered = true;
        });
        askToAddEventToCalendar();
      }
      else{
        showSimpleError(context, "Eveniment Indisponibil", "Capacitatea maxima a fost atinsă pentru acest eveniment");
      }
    }
  }
  /// Function used to add the current event to the Calendar App
  /// It will open the Calendar App and complete data with details
  Future<void> addEventToCalendar() async{

    String formattedDateTime = '${widget.eventDay} ${widget.eventTime}';
    DateTime selectedDateTime = DateFormat("d/M/yyyy H:m").parse(formattedDateTime);
    final Event event = Event(
      title:  '${widget.eventName}',
      startDate: selectedDateTime,
      endDate: selectedDateTime.add(Duration(hours: 1)),
    );
    try{
      await Add2Calendar.addEvent2Cal(event);
    }catch(e){
      print("Eroare la adaugarea evenimentului in Calendar");
    }
  }

  /// Function used to show dialog and appeal addEventToCalendar()
  void askToAddEventToCalendar(){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                "Adauga in calendar",
              style: customOrangeShadowTextStyle(26),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                          "Nu",
                        style: customBasicTextStyle(18,true),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 10.0,
                        side: BorderSide(
                          color: Colors.orangeAccent,
                          width: 3.0,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        addEventToCalendar();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Da",
                        style: customBasicTextStyle(18,true),
                      ),
                      style: ElevatedButton.styleFrom(
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
            backgroundColor: Color.fromRGBO(3, 220, 252,100),
          );

        }
    );
  }

  /// Function to perform resign from event actions
  Future<void> resignAction() async{
    if(await isUserRegisteredForEvent()){
      await unregisterUserFromEvent();
      await removeEventFromUser();
      await decreaseNumberOfParticipants();
      setState(() {
        widget.participansNumber--;
        _isUserRegistered = false;
      });
    }
    else {
      showAlreadyUnRegistatedforEvent(context);
    }
  }

  Future<bool> isUserRegisteredForEvent() async {
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
  Future<bool> isCurrentUserTheHost() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser == null) {
      return false;
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference eventRef = firestore.collection('events').doc(widget.eventId);

    final snapshotEventData = await eventRef.get();
    String? host = snapshotEventData.get('host');

    if(host == currentUser.uid) {
      return true;
    } else {
      return false;
    }

  }


  /// Function used to register user to an Event
  Future <void> registerUserToEvent() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {

      DocumentSnapshot<
          Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
          .collection('users').doc(currentUser.uid).get();
      String userId = userSnapshot.id;

      String username = userSnapshot['username'];
      String email = userSnapshot['email'];


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

  /// Function used to delete an user from an Event
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

  /// Function used to add an Event to an User
  /// Function will add event id to eventList Collection
  /// If eventListCollection is not created for the current user the function will create it
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



  Future<void> _showParticipantsDialog(BuildContext context) async {
    List<Widget> participantWidgets = [];
    int colorCodeForUsername;

    //Obtinem organizatorul
    DocumentSnapshot currentEvent = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();

    String hostId = currentEvent['host'];

    // Obținem lista de participanți
    QuerySnapshot participantsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('participantsList')
        .get();

    // Obținem datele despre organizator
    DocumentSnapshot hostSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(hostId)
        .get();

    String hostName = hostSnapshot['username'];
    String? hostImageUrl = hostSnapshot['profileImageUrl'];
    int hostColor = hostSnapshot['color'];
    int hostStars = hostSnapshot['stars'];
    int hostReviews = hostSnapshot['reviews'];

    Widget hostWidget = Row(
      children: [
        Icon(
          Icons.home,
          color: Colors.orangeAccent,
        ),
        SizedBox(height: 5,),
        CircleAvatar(
          radius: 20,
          child: Image(
            image: hostImageUrl != null
                ? NetworkImage(hostImageUrl) as ImageProvider<Object>
                : AssetImage("images/profile.jpg"),
          ),
        ),
        SizedBox(width: 10),
        Text(
          hostName,
          style: TextStyle(
              color: Color(hostColor),
              fontSize: 16.0,
              fontWeight: FontWeight.w800
          ),
        ),
        SizedBox(width: 5),
        Text(
         hostStars > 0.01?(hostStars/hostReviews).toStringAsFixed(2):'-',
          style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w800
          ),
        ),
        SizedBox(width: 5),
        Icon(
          Icons.star,
          color: Colors.orangeAccent,
        ),
        SizedBox(height: 100,),
      ],
    );

    participantWidgets.add(hostWidget);

    // Extragem informațiile despre participanți
    if (participantsSnapshot.docs.isNotEmpty) {
      for (DocumentSnapshot participantDoc in participantsSnapshot.docs) {
        String userId = participantDoc.id;
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        String participantName = userSnapshot['username'];
        String? participantImageUrl = userSnapshot != null ? userSnapshot['profileImageUrl'] : null;
        colorCodeForUsername = userSnapshot['color'];

        Widget participantWidget = Row(
          children: [
            Icon(
              Icons.man,
              color: Colors.orangeAccent,
            ),
            SizedBox(height: 5,),
            CircleAvatar(
              radius: 20,
              child: Image(
                image: participantImageUrl != null
                    ? NetworkImage(participantImageUrl) as ImageProvider<Object>
                    : AssetImage("images/profile.jpg"),
              ),
            ),
            SizedBox(width: 10),
            Text(
              participantName,
              style: TextStyle(
                color: Color(colorCodeForUsername),
                fontSize: 16.0,
                fontWeight: FontWeight.w800
              ),
            ),
          ],
        );

        participantWidgets.add(participantWidget);
      }
    } else {
      participantWidgets.add(Text(
        'Nu există participanți',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.0,
        ),
      ));
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Participanți',
              style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 20.0,
                  color: Colors.orangeAccent,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: participantWidgets,
          ),
          actions: [

            if(_isCurrentUserHost)
              TextButton(
                  onPressed: (){
                    ShowDeleteEventDialog(context, widget.eventId);
                  },
                  child: Text(
                    "Șterge",
                      style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 20.0,
                          color: Colors.red,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Închide',
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20.0,
                      color: Colors.orangeAccent,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ],
          backgroundColor: Color.fromRGBO(3, 220, 252,100),
        );
      },
    );
  }
  Future<void> ShowDeleteEventDialog(BuildContext context, String eventId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
              'Șterge eveniment',
              style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 20.0,
                  color: Colors.orangeAccent,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                  'Anulează',
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20.0,
                      color: Colors.orangeAccent,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setEventAsInvalid(eventId);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: const Text(
                  'Șterge',
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20.0,
                      color: Colors.red,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ],
          backgroundColor: Color.fromRGBO(3, 220, 252,100),
        );
      },
    );
  }

  ///Function used to remove the current event from an User list
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
          int currentParticipants = snapshot['noOfparticipants'];
          transaction.update(eventRef, {'noOfparticipants': currentParticipants + 1});
        } else {
          print('Evenimentul cu ID-ul $widget.eventId nu există.');
        }
      });
    } catch (e) {
      print('Eroare la incrementarea participanților: $e');
    }
  }
  ///Function used to set an event as Invalid
  Future<void> setEventAsInvalid(String eventId) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final DocumentReference eventRef = firestore.collection('events').doc(eventId);
      await eventRef.update({
        'isEventActive': false
      });
    }
    catch(e){
      throw("Eroare: $e");
    }
  }

  Future<void> decreaseNumberOfParticipants() async {
    try {
      DocumentReference<Map<String, dynamic>> eventRef = FirebaseFirestore.instance.collection('events').doc(widget.eventId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction.get(eventRef);
        if (snapshot.exists) {
          int currentParticipants = snapshot['noOfparticipants'];
          transaction.update(eventRef, {'noOfparticipants': currentParticipants - 1});
        } else {
          print('Evenimentul cu ID-ul $widget.eventId nu există.');
        }
      });
    } catch (e) {
      print('Eroare la incrementarea participanților: $e');
    }
  }
  /// Function used to check if an event is still available for register
  /// If the capacity is full this function will throw false
  /// If the capacity is NOT full this function will throw true
  Future<bool>checkForCapacity() async{
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference eventRef = firestore.collection('events').doc(widget.eventId);
    final snapshotEventData = await eventRef.get();

    int noOfparticipants = snapshotEventData['noOfparticipants'];
    int capacity = snapshotEventData['capacity'];

    if(noOfparticipants == capacity) {
      return false;
    } else {
      return true;
    }
  }
}



// Funcție care convertește coordonatele în adresă
Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks != null && placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      String street = placemark.street ?? '';
      String locality = placemark.locality ?? '';
      return '$locality , $street';
    }
  } catch (e) {
    print('Eroare la obținerea adresei: $e');
  }
  return '';
}

String formatTime(String time) {
  List<String> parts = time.split(':');
  String hours = parts[0];
  String minutes = parts[1];
  if(minutes.length == 1)
    minutes = minutes + '0';
  if(hours.length == 1)
    hours = '0' + hours;

  return "$hours:$minutes";
}
