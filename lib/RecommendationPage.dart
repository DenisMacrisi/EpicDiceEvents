import 'package:epic_dice_events/CustomWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        title: '  Sugestia Săptămânii',
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
                    padding: const EdgeInsets.only(top: 120, left: 30,right: 30),
                    child: Text(
                      '${suggestion.data!['name']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0,
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
                    padding: const EdgeInsets.symmetric(horizontal: 30),
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
                      showFeedbackForm(context);
                    },
                    child: Text(
                      'Evaluare',
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
                            )
                          ),
                        ),
                      SizedBox(height: 50),
                      ]
                    )
                )
              ],
            );
          }),
    );
  }
}

void showFeedbackForm(BuildContext context) {
  // Controlor pentru textul comentariului
  TextEditingController suggestionCommentController = TextEditingController();

  // Variabilă pentru opțiunea Like/Dislike
  int isSuggestionLiked = 0;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
                'Feedback',
              style: customOrangeShadowTextStyle(30),
            ),
            backgroundColor:Color.fromRGBO(3, 220, 255, 50),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                            Icons.thumb_up,
                          color: isSuggestionLiked == 1 ? Colors.orangeAccent : null,
                        ),
                        onPressed: () {
                          setState(() {
                            isSuggestionLiked = 1;  // setare Like
                          });
                        },
                      ),
                      Text('Like'),
                      IconButton(
                        icon: Icon(
                            Icons.thumb_down,
                            color: isSuggestionLiked == 2 ? Colors.orangeAccent : null,
                        ),
                        onPressed: () {
                          setState(() {
                            isSuggestionLiked = 2;  // setare Dislike
                          });
                        },
                      ),
                      Text('Dislike'),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: suggestionCommentController,
                    decoration: InputDecoration(
                      labelText: 'Comentariu',
                      hintText: 'Feedback...',
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      sendFeedbackResponseToFirebase(isSuggestionLiked, suggestionCommentController.text);
                      Navigator.pop(context);
                    },
                    child: Text(
                        'Trimite',
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
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> sendFeedbackResponseToFirebase(int likeStatus, String comment) async {
  try {

    DocumentReference<Map<String, dynamic>> suggestionReferance =
    await FirebaseFirestore.instance
        .collection('suggestion')
        .doc('q4MLFWfMXNAj1E1LmFgb'); // Documentul cu id-ul 'id_no'


    DocumentSnapshot<Map<String, dynamic>> suggestionSnapshot =
    await suggestionReferance.get();

    Map<String, dynamic> data = suggestionSnapshot.data()!;

    int noLikes = data['likes'];
    int noDislikes = data['dislikes'];
    int counter = data['counter'];
    User? currentUser = FirebaseAuth.instance.currentUser;

    counter++;
    if (likeStatus == 1)
      noLikes++;
    if (likeStatus == 2)
      noDislikes++;

    await suggestionReferance.update({
      'counter': counter,
      'likes': noLikes,
      'dislikes': noDislikes,
    });

    String feedbackResponse = "feedbacker_" + counter.toString();

    await suggestionReferance.collection('feedback').doc(feedbackResponse).set({
      'comment': comment,
      'like': likeStatus == 1 ? "Da" : "Nu",
      'user': currentUser?.uid,
    });

  }
  catch (e){
    print("Eroare la acesarea documentelor Firebase");
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
