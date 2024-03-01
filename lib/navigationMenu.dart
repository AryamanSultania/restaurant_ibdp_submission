//for waiters when placing orders

// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:provider/provider.dart';
import 'popScopeDialog.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_ibdp_submission/CustomImage.dart';
import 'package:restaurant_ibdp_submission/buttonDialog.dart';

//there are 3 main stages, firstNavigator -> collectionNavigator -> finalNavigator
//firstNavigator is very similar to finalNavigator

class navigationMenuStateless extends StatelessWidget {
  const navigationMenuStateless({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => dataUpdater(),
      child: MaterialApp(
        title: 'Order system',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const StatefulNavigator(),
      ),
    );
  }
}

class dataUpdater extends ChangeNotifier {
  String selectedDocument = 'food';
  int selectedView = 0;
  void updateView(int newView) {
    selectedView = newView;
    notifyListeners();
  }
}

class StatefulNavigator extends StatefulWidget {
  const StatefulNavigator({super.key});

  @override
  myNavigatorState createState() => myNavigatorState();
}

class myNavigatorState extends State<StatefulNavigator> {
  int selectedView = 0;
  late int selectedIndex;
  late String selectedSecond = "";
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: const firstNavigator(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void setViewCollection(String selection) {
    selectedSecond = selection;
  }
}

//end of myNavigatorState

class firstNavigator extends StatelessWidget {
  const firstNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    //time help from https://stackoverflow.com/a/13110669
    int initialTime = DateTime.now().millisecondsSinceEpoch;

    //initialTime is used as a uniqueID to identify the waiter order, and is passed through the whle process
    //for each order, it is defined the moment a waiter opens the menu, this is how orders are identified in firebase realtime database
    return Scaffold(
      appBar: AppBar(
          leading: popScopeDialog(
            levels: 2,
            category: "waiter",
          ), //home icon, the "are you sure you want to go home and abandon order" button
          title: const Text("Select a category")),
      floatingActionButton: floatingButtonReviewOrder(
          initialTime: initialTime, levels: 2), //function used, reuse code
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<QuerySnapshot>(
              //SUPPORT FROM GOOGLE BARD
              future: FirebaseFirestore.instance
                  .collection('items_2')
                  .get(), //menu stored on items_2 on firebase firestore
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final documents = snapshot.data!.docs;
                  return SizedBox(
                    width: 1 *
                        MediaQuery.of(context)
                            .size
                            .width, //adjust as ratio if needed
                    height: 0.9 * MediaQuery.of(context).size.height,
                    //using 0.9 because 1 would be scrollable, potential for items to be behind the appbar
                    child: ListView.builder(
                      //for each availaboe document, make a new entry to be displayed
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final document = documents[index];
                        final itemName = document.id;

                        return ListTile(
                          leading: const SizedBox(
                            width: 50,
                            height: 50,
                            child:
                                SizedBox(), //for the future, if an image is needed to be added, then it can be inserted here
                          ),
                          title: Text(itemName),
                          trailing: ElevatedButton(
                            onPressed: () {
                              myNavigatorState().setViewCollection(itemName);
                              //support for pushing data towards next screen: https://stackoverflow.com/a/53861303
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => collectionNavigator(
                                    inputDocument: itemName,
                                    initialTime: initialTime,
                                  ),
                                ),
                              );
                            },
                            child: const Text("Enter"),
                          ),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text("Error fetching item count: ${snapshot.error}");
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class floatingButtonReviewOrder extends StatelessWidget {
  floatingButtonReviewOrder({
    super.key,
    required this.initialTime,
    required this.levels,
  });

  int initialTime;
  int levels;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 150,
      child: FloatingActionButton(
        onPressed: () {
          viewCurrentOrder(
            initialTime: initialTime,
            levels: levels,
          ).getDialog(context);
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 6, 0),
              child: Icon(Icons.receipt),
            ),
            Text("Review order")
          ],
        ),
      ),
    );
  }
}

class collectionNavigator extends StatelessWidget {
  late String inputDocument;
  late int initialTime;
  collectionNavigator({
    super.key,
    required this.inputDocument,
    required this.initialTime,
  });
  Future<Map<String, dynamic>> collectData() async {
    var selectedDocument = inputDocument;
    final ref1 =
        FirebaseFirestore.instance.collection("items_2").doc(selectedDocument);
    final doc = await ref1.get(); // Await the Future here
    final data = doc.data() as Map<String, dynamic>;
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: collectData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final outputData = snapshot.data as Map<String, dynamic>;
          final availableCollections = outputData['availableDocuments'];
          final collectionsList = availableCollections.split('/');
          final iterateCount = collectionsList.length;

          return Scaffold(
            appBar: AppBar(title: Text(inputDocument)),
            floatingActionButton:
                floatingButtonReviewOrder(initialTime: initialTime, levels: 3),
            body: ListView.builder(
              itemCount: iterateCount,
              itemBuilder: (context, index) {
                final itemName = collectionsList[index];
                return ListTile(
                  leading: //Text("this is another placeholder"),
                      const SizedBox(),
                  title: Text(itemName),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => finalNavigator(
                            inputDocument: inputDocument,
                            inputCollection: itemName,
                            initialTime: initialTime,
                          ),
                        ),
                      );
                    },
                    child: const Text("Enter"),
                  ),
                );
              },
            ),
          );
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class finalNavigator extends StatelessWidget {
  late String inputDocument;
  late String inputCollection;
  late int initialTime;
  finalNavigator(
      {super.key,
      required this.inputDocument,
      required this.inputCollection,
      required this.initialTime});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(inputCollection),
      ),
      floatingActionButton:
          floatingButtonReviewOrder(initialTime: initialTime, levels: 4),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<QuerySnapshot>(
              //SUPPORT FROM GOOGLE BARD
              future: FirebaseFirestore.instance
                  .collection('items_2/$inputDocument/$inputCollection')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final documents = snapshot.data!.docs;
                  return SizedBox(
                    width: 1 * MediaQuery.of(context).size.width,
                    height: 0.9 * MediaQuery.of(context).size.height,
                    child: ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final document = documents[index];
                        final itemName = document['itemName'];
                        final String documentChoices = document['options'];
                        final documentPrice = document['prices'];
                        //final sampleDocument2 = documents;
                        String documentPath = document.reference.path;
                        List<String> pathComponents = documentPath.split('/');
                        String largeDocument = pathComponents[1];
                        String subCollection = pathComponents[2];
                        String specificDocument = pathComponents[3];

                        return ListTile(
                          leading: SizedBox(
                            width: 50,
                            height: 50,
                            child: CustomImage().finalInternetImage(
                                largeDocument, subCollection, specificDocument),
                          ),
                          title: Text(itemName ?? 'Unknown Item'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              addItemToOrderDialog(
                                choices: documentChoices,
                                name: itemName,
                                path: documentPath,
                                price: documentPrice,
                                initialTime: initialTime,
                              ).getDialog(context);
                            },
                            child: const Text("Order"),
                          ),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text("Error fetching item count: ${snapshot.error}");
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
