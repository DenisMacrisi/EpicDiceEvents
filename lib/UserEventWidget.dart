import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epic_dice_events/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class UserEventWidget extends StatefulWidget{
  final String eventName;
  final String eventDay;
  final String eventTime;

  UserEventWidget({
    Key? key,
    required this.eventName,
    required this.eventDay,
    required this.eventTime,
}) : super(key: key);

  @override
  _UserEventWidgetState createState() => _UserEventWidgetState();
}

class _UserEventWidgetState extends State<UserEventWidget>{

  @override
  Widget build(BuildContext context){
    return Container(
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
              fontSize: 14.0,
            ),
          ),
          SizedBox(
            height: 3.0,
          ),
          Text(
            '${widget.eventDay}',
            style: TextStyle(
              fontSize: 12.0,
            ),
          )
        ],
      ),
    );
  }
}