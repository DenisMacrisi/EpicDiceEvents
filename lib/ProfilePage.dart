import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:epic_dice_events/DatabaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class ProfilePage extends StatefulWidget {

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>{

  File? _selectedImage;

  Widget build(BuildContext context){

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('Profil',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25.0,
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
            backgroundColor: Colors.transparent,
            elevation: 100,
            centerTitle: true,
        ),
      body: FutureBuilder(
        future: getUserData(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          String imageUrl = snapshot.data!.get('profileImageUrl') ?? '';
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
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                left: MediaQuery.of(context).size.width * 0.5 - 50,
                child: GestureDetector(
                  onTap: () async {
                    await _pickImageFromGallery();
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_selectedImage != null || imageUrl.isNotEmpty)
                          ClipOval(
                            child: _selectedImage != null
                                ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            )
                                : imageUrl.isNotEmpty
                                ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 1200,
                            )
                                : Container(),
                          ),
                        Icon(
                          Icons.camera_alt,
                          size: 30,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                left: MediaQuery.of(context).size.width * 0.5 - 50,
                child: ElevatedButton(
                  onPressed: () async {
                    String? image_name = generateUniqueImageName();
                    String? imageUrl = await uploadImageToStorage(_selectedImage!, image_name);
                    changeProfilePicture(imageUrl!);
                    print("S-a apasat buton");
                  },
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
                  child: Text('Încarcă',style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
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
                  ),),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<DocumentSnapshot> getUserData() async {
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

  Future _pickImageFromGallery() async {
    final returnImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = File(returnImage!.path);
    });
  }

}

Future<String?> getProfileImageUrl() async {

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    String userId = currentUser.uid;
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(userId)
        .get();
    return snapshot.data()!['profileImageUrl'];
  }
  return null;
}

Future<String?> uploadImageToStorage(File imageFile, String imageName) async {
  try {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child(imageName);

    await ref.putFile(imageFile);

    String downloadURL = await ref.getDownloadURL();

    return downloadURL;
  } catch (e) {
    print('Eroare la încărcarea imaginii: $e');
    return null;
  }
}

Future <void> changeProfilePicture(String imageUrl)async {
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {

    String userId = currentUser.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'profileImageUrl': imageUrl});
  }

}

String generateUniqueImageName() {

  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();


  String random = Random().nextInt(1000).toString();

  return 'image_'+timestamp+'_'+random;
}
