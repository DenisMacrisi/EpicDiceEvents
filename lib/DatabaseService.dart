import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService{

  Future<String?> uploadImageToStorage(File imageFile, String imageName) async {
    try {
      firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref().child(imageName);

      await ref.putFile(imageFile);


      String downloadURL = await ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Eroare la încărcarea imaginii: $e');
      return null;
    }
  }

}