import 'package:epic_dice_events/CustomWidgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:epic_dice_events/Authenticate.dart';
import 'package:epic_dice_events/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Authentication.dart';



class NoInternetApp extends StatelessWidget {
  Future<ConnectivityResult> checkConnectivity() async {
    return Future.delayed(Duration(seconds: 5), () async {
      return await Connectivity().checkConnectivity();
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(title: "Eroare Conexiune"),
        body: RefreshIndicator(
          onRefresh: (){
            return Future.delayed(Duration(seconds: 1));
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/Color.jpg'),
                fit: BoxFit.cover,
              ),
            ),

           child: Stack(
            children: [
              FutureBuilder<ConnectivityResult>(
                future: checkConnectivity(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || snapshot.data == ConnectivityResult.none) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              runApp(NoInternetApp()); // Reîncarcă aplicația
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
                                'Reîncarcă',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.black,
                                ),
                              ),
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
                    AuthenticationService authService = AuthenticationService();
                    Future<void> checkAuthenticationAndNavigate() async {
                      bool isUserAuthenticatedVar = await authService.isUserAuthenticated();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => isUserAuthenticatedVar ? HomePage() : Authenticate(),
                        ),
                            (Route<dynamic> route) => false,
                      );
                    }

                    Future.microtask(() {
                      checkAuthenticationAndNavigate();
                    });

                    return Container();
                  }
                },
              ),
              //EventList(),
            ],
          ),
        ),
      ),
      ),
    );
  }
}