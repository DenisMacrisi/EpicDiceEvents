import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'EventWidget.dart';

class SearchWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(50.0),
        border: Border.all(
          color: Colors.orangeAccent,
          width: 5.0,
        ),
      ),
      child: Center(
        child: IconButton(
          icon: Icon(Icons.search,
            color: Colors.orangeAccent,
            size: 25.0,
          ),
          onPressed: () {
            showSearch(context: context,
                delegate: CustomSearchDelegate()
            );
          },
        ),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {

  final List<String> sugestiiFiltrate = [];

  @override
  Widget buildSearchField(BuildContext context) {
    print('buildSearchField called');
    return TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Caută...",
        hintStyle: TextStyle(color: Colors.grey),
      ),
      onChanged: (value) {
        query = value;
      },
      onSubmitted: (value) {
        print('S-a apasat search');
        //showResults(context);
      },
    );
  }


  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return Container(
       child: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          close(context, '');
        },
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    print('S-a apasat search');
    saveSearch(query);
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
          final List<EventWidget> searchResults = snapshot.data!.docs.where((event) => event['Nume'].toLowerCase().contains(query.toLowerCase()) || event['Descriere'].toLowerCase().contains(query.toLowerCase())).map((event) {
            GeoPoint location = event['location'];
            String eventName = event['Nume'];
            int participansNumber = event['noOfparticipants'];
            int eventCapacity = event['capacity'];
            String eventImage = event['imageURL'];
            String eventDetails = event['Descriere'];
            String eventId = event.id;
            DateTime eventDate = event['date'].toDate();
            String eventDay = eventDate.day.toString() + '/' + eventDate.month.toString() + '/' + eventDate.year.toString();
            String eventTime = eventDate.hour.toString() + ':' + eventDate.minute.toString();
            String eventCategory = event['category'];
            bool isEventActive = event['isEventActive'];

            if (eventDate.isAfter(DateTime.now())) {
              return EventWidget(
                eventName: eventName,
                location: LatLng(location.latitude, location.longitude),
                participansNumber: participansNumber,
                eventCapacity: eventCapacity,
                eventImage: eventImage,
                eventDetails: eventDetails,
                eventId: eventId,
                eventDay: eventDay,
                eventTime: eventTime,
                eventCategory: eventCategory,
                isEventActive: isEventActive,
              );
            } else {
              return null;
            }
          }).whereType<EventWidget>().toList()..sort((a, b) {
            DateFormat dateFormat = DateFormat('dd/MM/yyyy');
            DateTime aDate = dateFormat.parse(a.eventDay);  // Aici presupunem că ai data în formatul 'dd/MM/yyyy'
            DateTime bDate = dateFormat.parse(b.eventDay);  // Aceeași logică pentru b

            if (aDate.compareTo(bDate) != 0 )
              return aDate.compareTo(bDate);
            else
              return a.eventTime.compareTo(b.eventTime);  // Compară datele
          });
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/Color.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: searchResults.isNotEmpty
            ? ListView(
              children: searchResults,
            )
            : Center(
              child: Text(
              'Nu exista rezultate pentru: ' + query,
              ),
            )
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.hasData && snapshot.data!.exists) {
          Map<String, dynamic>? userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData != null && userData.containsKey('searches')) {
            List<String> sugestii = List<String>.from(userData['searches']);
            List<String> sugestiiFiltrate = sugestii.where((sugestie) =>
                sugestie.toLowerCase().contains(query.toLowerCase())).toList();

            return ListView.builder(
              itemCount: sugestiiFiltrate.length,
              itemBuilder: (context, index) {
                final sugestie = sugestiiFiltrate[index];
                return ListTile(
                  title: Text(sugestie),
                  onTap: () {
                    query = sugestie;
                    //showResults(context);
                  },
                );
              },
            );
          }
        }
        return Center(
          child: Text('Nu există sugestii disponibile.'),
        );
      },
    );
  }
  Future<void> saveSearch(String query) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(currentUser?.uid);
    DocumentSnapshot userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null && query != '') {
        List<dynamic> searches = userData['searches'];
        searches[2] = searches[1];
        searches[1] = searches[0];
        searches[0] = query;

        await userRef.update({'searches': searches});
      }
      print('Cautare Salvata');
    }
    else{
      print('Eroare');
    }
  }

}

