import 'package:epic_dice_events/CustomWidgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendationPage extends StatefulWidget {

  @override
  _RecommendationPage createState() => _RecommendationPage();
}

class _RecommendationPage extends State<RecommendationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        title: 'Sugestia Saptamanii',
      ),
      body: FutureBuilder(
          future: getSuggestionData(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/Color.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            );
          }
      ),

    );
  }

}

Future<DocumentSnapshot> getSuggestionData() async {
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    return userData;
  } else {
    return FirebaseFirestore.instance.collection('users').doc().snapshots().first;
  }
}