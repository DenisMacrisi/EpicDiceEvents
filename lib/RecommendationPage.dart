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
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, dynamic>> suggestion) {
            if (suggestion.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (suggestion.hasError) {
              return Center(
                child: Text(
                  'Oopps! Momentat avem o prolema, te rugam revino mai tarziu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 20,
                  ),
                ),
              );
            }
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
                SingleChildScrollView(
                    child: Column(children: [
                  Container(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 120),
                    child: Text(
                      '${suggestion.data!['name']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40.0,
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
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 25,
                    ),
                    child: Builder(builder: (context) {
                      if (suggestion.data?['image'] != null) {
                        return Image.network(
                          suggestion.data!['image'],
                          height: 300,
                          width: 300,
                          fit: BoxFit.cover,
                        );
                      } else {
                        return Text('Eroare la incarcarea imaginii');
                      }
                    }),
                  ),
                  Container(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${suggestion.data!['description']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 20.0,
                            color: Colors.orangeAccent,
                          ),
                        ],
                      ),
                    ),
                  )),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      print('Buton Apasat');
                    },
                    child: Text(
                      'Feedback',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black,
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
                        )),
                  )
                ]))
              ],
            );
          }),
    );
  }
}

/// Extragere detalii pentru sugestia saptamanii
Future<Map<String, dynamic>> getSuggestionData() async {
  try {
    QuerySnapshot<Map<String, dynamic>> suggestion =
        await FirebaseFirestore.instance.collection('suggestion').get();
    if (suggestion.docs.isNotEmpty) {
      print(suggestion.docs.first.data()); //just for debbug
      return suggestion.docs.first.data();
    } else {
      throw Exception('Eroare! Colectia este goala');
    }
  } catch (e) {
    throw Exception('Eroare la accesarea Colectiei pentru sugestie');
  }
}
