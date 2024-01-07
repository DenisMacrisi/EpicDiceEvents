import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventWidget extends StatelessWidget {
  final String eventName;
  final LatLng location;
  final int participansNumber;
  final int eventCapacity;
  final String eventImage;
  final String eventDetails;

  EventWidget({
    required this.eventName,
    required this.location,
    required this.participansNumber,
    required this.eventCapacity,
    required this.eventImage,
    required this.eventDetails,
  });

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
            '$eventName',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 5.0),
          Text(
            'Location: ${location.latitude}, ${location.longitude}',
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            'Disponibilitate: $participansNumber / $eventCapacity ',
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
              eventImage,  // URL-ul imaginii
              width: 350,  // Ajustează dimensiunea imaginii conform necesităților tale
              height: 200,
              fit: BoxFit.cover,  // Poate fi ajustat pentru a specifica modul în care imaginea se adaptează în container
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            '$eventDetails',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          ElevatedButton(onPressed: (){

          },
              child: Text(  "Participa",
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
          )
        ],
      ),
    );
  }
}