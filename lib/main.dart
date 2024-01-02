import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Authentication.dart';
import 'MyApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid?
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyArOR36a93sLWW_U4uai-aLmi41u9ULpgM",
      appId: "1:401916273392:android:450f477d30735c29401835",
      messagingSenderId: "401916273392",
      projectId: "epicdiceevents-b7754",
    ),
  )
  :await Firebase.initializeApp(); // Inițializează Firebase

/*
  // Obține o referință la colecția "users"
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  // Obține toți utilizatorii din colecție
  QuerySnapshot querySnapshot = await users.get();

  // Parcurge rezultatele și afișează detaliile fiecărui utilizator
  querySnapshot.docs.forEach((doc) {
    print('User ID: ${doc.id}');
    print('Username: ${doc['username']}');
    print('Email: ${doc['email']}');
    print(' Password: ${doc['password']}');
    print( 'Location: ${doc['location']}');
    print('-----------------------');
  });
  */
  runApp(MyApp());
}




