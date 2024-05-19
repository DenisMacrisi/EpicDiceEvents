import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Authentication.dart';
import 'MyApp.dart';
import 'NoInternetApp.dart';

void main() async {


  //Stopwatch stopwatch = Stopwatch()..start(); // Pentru masurate timp

  WidgetsFlutterBinding.ensureInitialized();

  bool isConnected = await checkInternetConnection();

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
 // stopwatch.stop();
 // print('Durata conectării la baza de date: ${stopwatch.elapsedMilliseconds} ms');

  if(isConnected == true)
   runApp(MyApp());
  else
    runApp(NoInternetApp());


}

Future<bool> checkInternetConnection() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
    return true;
  } else {
    return false;
  }
}



