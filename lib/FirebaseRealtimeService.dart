//this file is for functions which directly need realtime from firebase

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_ibdp_submission/kitchenView.dart';
import 'package:restaurant_ibdp_submission/navigationMenu.dart';
import 'package:restaurant_ibdp_submission/popScopeDialog.dart';

import 'buttonDialog.dart';
import 'FirebaseStorage.dart';
import 'package:csv/csv.dart';

// ignore: must_be_immutable
class FirebaseRealtimeService {
  late bool itemToShow;
  static late DataSnapshot ordersSubmittedSnapshot;
  static late List<String> itemsCombinedCollection;

  static final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://restaurant-ibdp-submission-default-rtdb.asia-southeast1.firebasedatabase.app/',
  );

  List<List<Object>> dataForCsv = [];

  Future<void> writeData(String path, Map<String, dynamic> data) async {
    final ref = database.ref().child(path);
    await ref.set(data);
  }

  Future<void> updateData(String path, Map<String, dynamic> data) async {
    final ref = database.ref().child(path);
    await ref.update(data);
  }

  Future<void> remove(String path) async {
    final ref = database.ref().child(path);
    await ref.remove();
  }

  Future<void> writeOrderToCsv(int initialTime) async {
    dataForCsv.clear();
    final ref = database.ref();
    final snapshot = await ref.child("ordersInProgress/$initialTime").get();
    final orders = snapshot.value as Map<dynamic, dynamic>;
    final orderList = orders.entries.map((entry) {
      return entry.value;
    }).toList();
    final orderInfo = orderList[0];
    final snapshotItems =
        await ref.child("ordersInProgress/$initialTime/items").get();
    final ordersItems = snapshotItems.value as Map<dynamic, dynamic>;
    final orderListItems = ordersItems.entries.map((entry) {
      return entry.value;
    }).toList();

    int itemCount = orderListItems.length;

    for (int index = 0; index < itemCount; index++) {
      final order = orderListItems[index];

      dataForCsv.add([
        //this determines the order of the CSV
        orderInfo['initialTime'],
        orderInfo['shortOrderID'],
        orderInfo['floor'],
        orderInfo['table'],
        order['itemTime'],
        order['name'],
        order['choice'],
        order['customComment'],
        order['quantity'],
        order['individualPrice'],
        order['itemOverallPrice'],
        order['firestorePath']
      ]);
    }

    String convertedCsv = const ListToCsvConverter().convert(dataForCsv);
    //uses https://pub.dev/packages/csv

    FirebaseStorageInterface().uploadCsv(convertedCsv, initialTime);
  }

  Future<void> moveData(String oldPath, String newPath, int initialTime) async {
    final snapshot = await database.ref().child(oldPath).get();
    if (snapshot.exists) {
      writeOrderToCsv(initialTime);

      await database.ref().child(newPath).set(snapshot.value);
      remove(oldPath);
    }
  }

  Future<void> copyData(String oldPath, String newPath) async {
    final snapshot = await database.ref().child(oldPath).get();
    if (snapshot.exists) {
      await database.ref().child(newPath).set(snapshot.value);
    }
  }

  void reloadCurrentOrder(
      BuildContext context, int levels, int initialTime, String selectedView) {
    navigatorPop(context, levels);
    FirebaseRealtimeService()
        .viewCurrentOrder(context, initialTime, levels, selectedView);
  }

  Widget showChoice(String inputChoice) {
    //for waiter "review order", if no choice is available then it's simply not shown
    if (inputChoice == "None") {
      return SizedBox();
    } else {
      return Text('Choice: $inputChoice');
    }
  }

  Widget showCustomComment(String inputComment) {
    //for waiter "review order", if no comment is given then it's simply not shown
    if (inputComment == "No comment") {
      return SizedBox();
    } else {
      return Text('Custom Comment: $inputComment');
    }
  }

  Widget showIndividualPrices(int individualPrice, String selectedView) {
    //only show item prices to person viewing data for entry into pos billing system

    if (selectedView == "POS") {
      return Text("Individual Price: $individualPrice");
    } else {
      return SizedBox();
    }
  }

  
  Widget showOverallPrices(int individualPrice, int overallPrice, String selectedView) {
    //only show overall price if it's not different from individual
    if (selectedView == "POS" && individualPrice != overallPrice) {
      return Text("Overall item price: $overallPrice");
    } else {
      return SizedBox();
    }
  }

  Future<Map<dynamic, dynamic>> getCurrentOrderInfo(
      int initialTime, int itemTime) async {
    final ref = database.ref();
    final snapshot =
        await ref.child("ordersInProgress/$initialTime/items/$itemTime").get();
    final orders = snapshot.value as Map<dynamic, dynamic>;
    print(
        'currentorderinfo is $orders, trying to read quantity as ${orders['quantity']}');
    return orders;
  }

  Future<dynamic> viewCurrentOrder(
      //waiter sees this when presses the floating action button, all items added to order
      BuildContext context,
      int initialTime,
      int levels,
      String selectedView) async {
    try {
      final ref = database.ref();
      final snapshot =
          await ref.child("ordersInProgress/$initialTime/items").get();

      final orders = snapshot.value as Map<dynamic, dynamic>;

      final orderList = orders.entries.map((entry) {
        return entry.value;
      }).toList();

      if (snapshot.exists) {
        // ignore: use_build_context_synchronously
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: 300,
              width: 300,
              child: AlertDialog(
                content: Column(
                  children: [
                    //Text("Confirm order for ID $initialTime"),
                    SizedBox(
                      width: 0.95 * MediaQuery.of(context).size.width,
                      height: 0.75 * MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        //help from google bard
                        itemCount: orderList.length,
                        itemBuilder: (context, index) {
                          final order = orderList[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${order['name']}',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  showChoice(order['choice'].toString()),
                                  Text('Quantity: ${order['quantity']}'),
                                  showCustomComment(
                                      order['customComment'].toString()),
                                  Text(
                                      'Individual Price: ${order['individualPrice']}'),
                                  Text(
                                      'Overall price for this item: ${order['itemOverallPrice']}'),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 0.3 *
                                            MediaQuery.of(context).size.width,
                                        //height: 0.95 *MediaQuery.of(context).size.height,
                                        child: ElevatedButton(
                                            onPressed: () {
                                              modifyItemDialog(
                                                initialTime: initialTime,
                                                inputChoice: order['choice'],
                                                inputComment:
                                                    order['customComment'],
                                                inputQuantity:
                                                    order['quantity'],
                                                itemTime: order['itemTime'],
                                                path: order['firestorePath'],
                                                individualPrice:
                                                    order['individualPrice'],
                                                levels: levels,
                                              ).selectPropertyDialog(context);
                                            },
                                            child: Text("Modify item",
                                                style: const TextStyle(
                                                    color: Colors.orange))),
                                      ),
                                      //Padding(padding: EdgeInsets.fromLTRB(10,0,0,10),),
                                      SizedBox(
                                        width: 0.3 *
                                            MediaQuery.of(context).size.width,
                                        child: ElevatedButton(
                                            onPressed: () {
                                              manageCard().dismissCardDialogUltra(
                                                  "ordersInProgress/$initialTime/items/${order['itemTime']}",
                                                  order['name'],
                                                  context,
                                                  false,
                                                  initialTime,
                                                  levels,
                                                  selectedView,
                                                  "N/A",
                                                  "N/A",
                                                  "N/A");
                                            },
                                            child: const Text("Delete item",
                                                style: TextStyle(
                                                    color: Colors.red))),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        floorAndTableSelector(
                                initialTime: initialTime, levels: levels)
                            .getDialog(context);
                      },
                      child: Text("Items correct, move to table info"),
                    ),
                    Divider(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Go back to menu"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No items in order, yet!"),
      ));
    }

    //throw Text("this is being implemented please wait");
  }

  void manageSnapshot() async {
    final ref = database.ref().child("ordersSubmitted");
    final snapshot = await ref.get();
    ordersSubmittedSnapshot = snapshot;
  }

  void writeCombinedCollection() async {
    final foodItemList = await getCombinedCollection();
    itemsCombinedCollection = foodItemList;
  }

  Future<List<String>> getCombinedCollection() async {
    final foodDocument =
        await collectionNavigator(inputDocument: 'food', initialTime: 777)
            .collectData();
    final foodDocumentMapped = foodDocument as Map<String, dynamic>;
    final foodDocumentCollections = foodDocumentMapped['availableDocuments'];
    final List<String> foodItemList = foodDocumentCollections.split('/');

    final drinksDocument =
        await collectionNavigator(inputDocument: 'drinks', initialTime: 777)
            .collectData();
    final drinksDocumentMapped = drinksDocument as Map<String, dynamic>;
    final drinksDocumentCollections =
        drinksDocumentMapped['availableDocuments'];
    final List<String> drinksItemList = drinksDocumentCollections.split('/');
    final itemList = foodItemList + drinksItemList;
    return itemList;
  }

  Future<List<String>> getFoodCollection() async {
    final document =
        await collectionNavigator(inputDocument: 'food', initialTime: 777)
            .collectData();
    final documentMapped = document as Map<String, dynamic>;
    final documentCollections = documentMapped['availableDocuments'];
    final List<String> itemList = documentCollections.split('/');
    return itemList;
  }

  Future<List<String>> getDrinksCollection() async {
    final document =
        await collectionNavigator(inputDocument: 'drinks', initialTime: 777)
            .collectData();
    final documentMapped = document as Map<String, dynamic>;
    final documentCollections = documentMapped['availableDocuments'];
    final List<String> itemList = documentCollections.split('/');
    return itemList;
  }
}
