import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:epic_dice_events/CustomWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'EventSummaryGenericList.dart';

class EventListFuturePage extends StatelessWidget {

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
                  return EventSummaryGenericList(filter: (eventDate, isActive) => eventDate.isAfter(DateTime.now()) && isActive);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
