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
      storageBucket: "epicdiceevents-b7754.appspot.com"
    ),
  )
      :await Firebase.initializeApp(); // Inițializează Firebase

  runApp(MyApp());
}



