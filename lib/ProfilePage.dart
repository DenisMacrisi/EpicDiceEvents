import 'dart:io';
import 'dart:math';
import 'package:epic_dice_events/CustomWidgets.dart';
import 'package:epic_dice_events/EventListFuturePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:epic_dice_events/Authentication.dart';
import 'package:epic_dice_events/Authenticate.dart';

import 'EventListPassedPage.dart';

class ProfilePage extends StatefulWidget {

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>{

  File? _selectedImage;
  Color selectedColor = Colors.black;
  List<Color> colorOptions = [Colors.black, Colors.red, Colors.green, Colors.yellow, Colors.blue, Colors.pink];
  User? currentUser = FirebaseAuth.instance.currentUser;
  Color newColorToUpdate = Color(0);
  final AuthenticationService _authService = AuthenticationService();


  @override
  void initState() {
    super.initState();
    loadUserColor();
  }

  Widget build(BuildContext context){

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        title: 'Profil',
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
          String username = snapshot.data!.get('username') ?? 'User';

          /// Used for future calculation
          double screenHeight = MediaQuery.of(context).size.height;
          double screenWidth = MediaQuery.of(context).size.width;

          print('Username: $username');
          print('Selected color: $selectedColor');
          print('Snapshot data: ${snapshot.data}');

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
                top: screenHeight * 0.15,
                left: (screenWidth - 120) / 2,
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
                top: screenHeight * 0.30,
                left: (screenWidth - 240) / 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<Color>(
                        icon: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedColor,
                          ),
                        ),
                        items: colorOptions.map((Color color) {
                          return DropdownMenuItem<Color>(
                            value: color,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (Color? newColor) {
                          setState(() {
                            selectedColor = newColor!;
                          });
                          newColorToUpdate = newColor!;
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      username,
                      style: TextStyle(
                        color: selectedColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: screenHeight * 0.35,
                left: (screenWidth - 145) / 2,
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () async {
                      String? image_name = generateUniqueImageName();
                      if(_selectedImage != null) {
                        String? imageUrl = await uploadImageToStorage(
                            _selectedImage!, image_name);
                        changeProfilePicture(imageUrl!);
                      }
                      updateUserColor(newColorToUpdate);
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
                    child: Text('Modifică',style: TextStyle(
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
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.50,
                left: (screenWidth - 270) / 2,

                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>EventListFuturePage()),
                      );
                    },
                    child: Text(
                      "Evenimente viitoare",
                      style: customBasicTextStyle(13.5, true),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 75),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.5),
                      ),
                      elevation: 10.0,
                      side: BorderSide(
                        color: Colors.orangeAccent,
                        width: 3.0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 100,
              ),
              Positioned(
                top: screenHeight * 0.65,
                left: (screenWidth - 270) / 2,
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>EventListPassedPage()),
                      );
                    },
                    child: Text(
                      "Evenimente trecute",
                      style:customBasicTextStyle(13.5,true) ,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 75),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.5),
                      ),
                      elevation: 10.0,
                      side: BorderSide(
                        color: Colors.orangeAccent,
                        width: 3.0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 100,
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.90,
                left: MediaQuery.of(context).size.width * 0.36,
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Esti sigur ?",
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
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  bool isDeletionSuccessfully = await askUserForPasswordandDelete();
                                  if(isDeletionSuccessfully == true) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Authenticate()),
                                          (Route<dynamic> route) => false,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Contul a fost sters',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white
                                            ),
                                          ),
                                          backgroundColor: Colors.orangeAccent,
                                        )
                                    );
                                  }
                                  if(isDeletionSuccessfully == false){
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Parola incorecta',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white
                                          ),
                                        ),
                                        backgroundColor: Colors.orangeAccent,
                                      ),
                                    );
                                  }
                                },
                                child: Text('Sterge',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28.0,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10.0,
                                        color: Colors.redAccent,
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
                              ),
                            ],
                            backgroundColor: Color.fromRGBO(3, 220, 252,100),
                          );
                        },
                      );
                    },
                    child: Text(
                      "Stergere Cont",
                      style: TextStyle(
                          color: Colors.red
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.5),
                      ),
                      elevation: 10.0,
                      side: BorderSide(
                        color: Colors.orangeAccent,
                        width: 3.0,
                      ),
                    ),
                  ),
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

  Future<void> loadUserColor() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      if (userDoc.exists) {
        int colorValue = userDoc['color'] ?? Colors.black.value;
        setState(() {
          selectedColor = Color(colorValue);
        });
      }
    }
  }
  Future<void> updateUserColor(Color color) async {
    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'color': color.value,
      });
    }
  }
  Future<bool> askUserForPasswordandDelete() async{
    TextEditingController passwordController = TextEditingController();
    bool success = false;
    await showDialog<String>(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            backgroundColor: Colors.cyan,
            title: Text(
              "Confirma parola",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
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
            content: Container(
              height: 200,
              child: Column(
                children: [
                  TextField(
                    controller: passwordController,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        String pass = passwordController.text;
                        success = await _authService.deleteCurrentUserAccount(pass);
                        Navigator.of(context).pop();
                      }
                      catch(e){
                        success = false;
                        print("Eroare la Stergerea userului curent");
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      "Sterge",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
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

                  ),
                ],
              ),
            ),
          );
        }
    );
    return success;
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