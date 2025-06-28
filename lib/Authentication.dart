import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CustomUser.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //final StreamController<User?> _authChangesController = StreamController<User?>();
  // Create user obj
  CustomUser? _customUserFromFirebase(User? user) {
    return user != null ? CustomUser(uid: user.uid) : null;
  }

  Future<User?> _getCurrentUser() async{
    return _auth.currentUser;
  }

  Future<bool> isUserAuthenticated() async{
    User? user = _auth.currentUser;
    return user != null;
  }

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
        'profileImageUrl': 'https://firebasestorage.googleapis.com/v0/b/epicdiceevents-b7754.appspot.com/o/profile.jpg?alt=media&token=0c7357c6-35e4-436e-8bb7-2d9a7e8f1e1a',
        'searches':["","",""],
        'color': 4278190080,
        'rating': 0,
        'stars': 0,
        'reviews': 0,
      });
    } else {
      print('Utilizatorul curent nu poate fi înregistrat');
    }
  }
/* Just for debugg
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
*/
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

      return user;
    }catch(e){
      print(e.toString());
      return null;
    }
  }

// register email & pass
  Future<User?> registerNewUser(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if(user != null){
        await user.sendEmailVerification();
      }

      return user;
    } catch (e) {
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

  /// Function used to delete user account
  /// Delete user and all data associated
  Future<bool> deleteCurrentUserAccount(String password) async{
    bool success =false;
    try{
      User? user = _auth.currentUser;
      if(user != null){
        AuthCredential credentials = EmailAuthProvider.credential(
            email: user.email!,
            password: password
        );

        await user.reauthenticateWithCredential(credentials);
        await deleteCurrentUserFromEveryEvent();
        await deleteEventsCreatedByCurrentUser();
        await deleteCurrentUserFromCollectionUsers();
        await deleteUser();
        await _auth.signOut();
        success = true;
      }
      return success;
    }
    catch(e){
      print("Eroare la stergerea utilizatorului");
      success = false;
    }
    return success;
  }
  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print("Email de verificare trimis.");
    } else {
      print("Utilizatorul este deja verificat sau nu este autentificat.");
    }
  }

//delete
  Future<void> deleteUser() async{
    try{
      User? user = _auth.currentUser;

      if(user != null){
        user.delete();
      }
    } catch(e){
      print("Eroare la stergerea contului");
    }
  }

  /// Function used to delete a subcollection
  /// This function is very usefull for deleting documents
  /// collectionPath - parent collection
  /// docId - Id of the document from we want to delete a sub-collection
  /// subcollectionList -
  Future<void> deleteSubcollectionsFromParentCollection(String collectionPath, String docId, List<String> subcollectionList) async {
    DocumentReference docRef = FirebaseFirestore.instance.collection(collectionPath).doc(docId);

    for (String subcollection in subcollectionList) {
      CollectionReference subcollectionRef = docRef.collection(subcollection);

      QuerySnapshot snapshot = await subcollectionRef.get();
      if (snapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    }
  }
  ///Function Used to delete all data associated with the current account
  Future<void> deleteCurrentUserFromCollectionUsers() async{
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    try{
      User? user = _auth.currentUser;
      if(user != null){
        String userId = user.uid;

        deleteSubcollectionsFromParentCollection("users", userId,['eventsList']);
        await users.doc(userId).delete();
        await Future.delayed(const Duration(seconds: 2)); // Așteaptare pentru orice eventualitate
      }
    }catch(e){
      print("Eroare la stergerea datelor utilizatorului din colectia Users: $e");
    }
  }

  /// Function used to delete the events created by the current user
  Future<void> deleteEventsCreatedByCurrentUser() async {
    CollectionReference usersReference = FirebaseFirestore.instance.collection('users');
    CollectionReference eventsReference = FirebaseFirestore.instance.collection('events');
    try{
      User? user = _auth.currentUser;

      if(user != null) {
        String userId = user.uid;
        CollectionReference eventsCreatedReference = usersReference.doc(userId)
            .collection('eventsCreatedList');
        QuerySnapshot eventsCreatedSnapshot = await eventsCreatedReference
            .get();

        for(var event in eventsCreatedSnapshot.docs){
          String eventId = event.id;
          await eventsReference.doc(eventId).update({
            'isEventActive': false,
          });
        }

        for (var event in eventsCreatedSnapshot.docs) {
          await event.reference.delete();
        }
        await usersReference.doc(userId).update({
          'eventsCreatedList': FieldValue.delete()
        });
      }
    }catch(e){
      print('Eroare la stergerea evenimentelor create de utilizatorul curent: $e');
    }
  }

  /// Function used for deleting current user from every event that is registred for
  Future<void> deleteCurrentUserFromEveryEvent() async {
    CollectionReference events = FirebaseFirestore.instance.collection('events');

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        QuerySnapshot querySnapshotEvents = await events.get();
        String userId = user.uid;

        for (var doc in querySnapshotEvents.docs) {
          DocumentReference eventReference = events.doc(doc.id);
          CollectionReference participantsList = eventReference.collection('participantsList');
          DocumentSnapshot participantDoc = await participantsList.doc(userId).get();

          if (participantDoc.exists) {
            await participantsList.doc(userId).delete();
            int noOfparticipants = doc.get('noOfparticipants') ?? 0;
            noOfparticipants = (noOfparticipants > 0) ? noOfparticipants - 1 : 0;

            await eventReference.update({
              'noOfparticipants': noOfparticipants,
            });
          } else {
            //Do Nothing
          }
        }
      }
    } catch (e) {
      print("Eroare la eliminarea utilizatorului curent din evenimente: $e");
    }
  }
}