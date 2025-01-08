import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CustomUser.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StreamController<User?> _authChangesController = StreamController<User?>();
  // Create user obj
  CustomUser? _customUserFromFirebase(User? user) {
    return user != null ? CustomUser(uid: user.uid) : null;
  }

  Future<User?> _getCurrentUser() async{
    return _auth.currentUser;
  }

  Future<bool> isUserAuthenticated() async{
    User? user = await _auth.currentUser;
    return user != null;
  }

/*
  Future <Int> getNextUserId(String uid) async{
      CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
      DocumentReference userDocRef = userCollection.doc(userId);
      QuerySnapshot collectionSnapshot = await userDocRef.collections();
  }
*/

  Future <void> addNewUserToDatabase(String username, String email, String location) async {

    User? user = await _getCurrentUser();

    if (user != null) {
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      String userId = user.uid;

      DocumentReference userDocRef = users.doc(userId);

      await userDocRef.set({
        'username': username,
        'email': email,
        'location': location,
        'profileImageUrl': null,
        'searches':[null,null,null],
        'color': 4278190080,

      });

      print('User added successfully with ID: $userId');
    } else {
      print('Utilizatorul nu este autentificat.');
    }
  }
/*
  Future<String> getNextUserId() async{
    int counter_users = 0;
    String userId ="";

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await users.get();

    querySnapshot.docs.forEach((doc) {
      userId = doc.id;
    });

    int newUserId = int.parse(userId);

    newUserId++;

    return newUserId.toString();

   // return  counter_users.toString();
  }
*/
  Future afisare() async{
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await users.get();

    // Parcurge rezultatele și afișează detaliile fiecărui utilizator
    querySnapshot.docs.forEach((doc) {
      print('User ID: ${doc.id}');
      print('Username: ${doc['username']}');
      print('Email: ${doc['email']}');
      print( 'Location: ${doc['location']}');
      print('-----------------------');
    });
  }

// auth change stream
  Stream<CustomUser?> get user{
    return _auth.authStateChanges()
        //.map((User? user) => _customUserFromFirebase(user));
        .map(_customUserFromFirebase);
  }



// sign in anon
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _customUserFromFirebase(user);

    } catch (e) {
      print(e.toString());
      return null;
    }
  }

// sign in email & pass
  Future logIn(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      return _customUserFromFirebase(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

// register email & pass
Future registerNewUser(String email, String password) async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      return _customUserFromFirebase(user);
    }catch(e){
        print(e.toString());
        return null;
    }
}
// sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
      return null;

    }
  }

}