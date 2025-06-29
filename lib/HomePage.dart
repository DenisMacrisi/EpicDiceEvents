import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:epic_dice_events/AddEventPage.dart';
import 'package:epic_dice_events/CustomWidgets.dart';
import 'package:epic_dice_events/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'EventList.dart';
import 'FilterWidget.dart';
import 'Map.dart';
import 'SearchWidget.dart';

class HomePage extends StatelessWidget {

  Future<ConnectivityResult> checkConnectivity() async {
    return Future.delayed(Duration(seconds: 5), () async {
      return await Connectivity().checkConnectivity();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar:const CustomAppBar(
        title: 'EpicDiceEvents',
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.delayed(Duration(seconds: 1));
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/Color.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            StreamBuilder<ConnectivityResult>(
              stream: Connectivity().onConnectivityChanged,
              builder: (context, snapshot) {
              if (snapshot.hasError || snapshot.data == ConnectivityResult.none) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nu Exista Conexiune',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            SystemNavigator.pop(); // Închide aplicația
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
                          child: Container(
                            width: 90.0,
                            height: 50.0,
                            alignment: Alignment.center,
                            child: Text(
                              'Ieșire',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return EventList();
                }
              },
            ),
            //EventList(),
            Positioned(
                bottom: 70.0,
                right: 20.0,
                child: SearchWidget(),
            ),
            Positioned(
                bottom: 10.0,
                right: 20.0,
                child: FilterWidget(),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: Color.fromRGBO(0, 222, 250, 60),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: InkWell(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MapPage()),
                      );
                    },
                    child: Ink(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.5),
                        boxShadow: [BoxShadow(
                          color: Colors.orangeAccent,
                          spreadRadius: 2,
                        ),
                        ],
                        border: Border.all(
                          color: Colors.orangeAccent,
                          width: 2.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '  Harta  ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.map),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MapPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: InkWell(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddEventPage()),
                      );
                    },
                    child: Ink(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.5),
                        color: Colors.white,
                        boxShadow: [BoxShadow(
                          color: Colors.orangeAccent,
                          spreadRadius: 2,
                        ),
                        ],
                        border: Border.all(
                          color: Colors.orangeAccent,
                          width: 2.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Adaugă',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AddEventPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: MyDrawer(),
    );
  }
}