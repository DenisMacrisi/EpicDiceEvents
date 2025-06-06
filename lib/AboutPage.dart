import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'CustomWidgets.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: CustomAppBar(title: 'Despre'),
      body: Stack(
        children: [
          Container(
            decoration: CustomBoxDecoration(),
            child: Center(
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Card(
                  color: Colors.lightBlue[50],
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.orangeAccent,
                      width: 4.0,
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: CircleAvatar(
                              radius: 80,
                              backgroundImage: AssetImage('images/Author.jpg'),
                            ),
                        ),
                        SizedBox(height: 40),
                        Text(
                            '"Aplicația EpicDiceEvents a fost concepută pentru a facilita organizarea și participarea pasionaților de jocuri la diferite evenimente. Personal, cred cu tărie, că o astfel de inițiativă ar fi de bun augur pentru toți împătimiții acestui hobby, putând ajuta la dezvoltarea și consolidarea unei comunități extrem de unite"',
                          style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),

                        ),
                        SizedBox(height: 40),
                        Row(
                          children: [
                            const Icon(
                              Icons.copyright_outlined,
                              color: Colors.orangeAccent,
                              size: 40,
                            ),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                " Denis-Constantin Macriși",
                                style: customBasicTextStyle(20, true, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.alternate_email_outlined,
                              color: Colors.orangeAccent,
                              size: 40,
                            ),
                            Text(
                              " denis.macrisi905@gmail.com",
                              style: customBasicTextStyle(20, true, color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ),
        ],
      ),
    );
  }
}

