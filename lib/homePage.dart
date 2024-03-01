import 'package:flutter/material.dart';
import 'package:restaurant_ibdp_submission/firebaseAuth.dart';
import 'package:restaurant_ibdp_submission/navigationMenu.dart';
import 'buttonDialog.dart';
//main page, select preparer or waiter here
//seen after auth successful, or when returning to home screen
class homePage extends StatelessWidget {
  const homePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 113, 157, 199),
          brightness: Brightness.light,
        ),
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        "Welcome",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red)),
                        //colouring help from https://stackoverflow.com/q/66835173/15997993
                        onPressed: firebaseAuth().logUserOut,
                        child: const Text("Log out",
                            style: TextStyle(color: Colors.white))),
                  )
                ],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.4,
                child: ElevatedButton(
                  onPressed: () {
                    selectOrderViewDialog().selectViewDialog(context);
                    //FirebaseRealtimeService().kitchenViewOrders(context);
                    //  FirebaseRealtimeService().trialInfiniteData(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dvr,
                          size: 0.06 * MediaQuery.of(context).size.width),
                      Flexible(
                        //wrap text assist from https://stackoverflow.com/a/55290923
                        child: Text(
                          "Preparers (View orders)",
                          textAlign: TextAlign
                              .center, //https://stackoverflow.com/a/53407050
                          style: TextStyle(
                            fontSize:
                                (0.06 * MediaQuery.of(context).size.width),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.8, //https://stackoverflow.com/a/43130622
                  child: const Divider(
                    height: 50,
                    thickness: 8,
                    color: Color.fromARGB(255, 0, 0, 0),
                  )),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.4,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const firstNavigator(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.library_add,
                          size: 0.06 * MediaQuery.of(context).size.width),
                      Padding(
                          padding: EdgeInsets.fromLTRB(
                              0.04 * MediaQuery.of(context).size.width,
                              0,
                              0,
                              0)),
                      Flexible(
                        child: Text(
                          "Waiter (Start a order)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                (0.06 * MediaQuery.of(context).size.width),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
