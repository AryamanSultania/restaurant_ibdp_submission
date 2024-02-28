//some functions for the kitchen are stored here

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_ibdp_submission/FirebaseRealtimeService.dart';
import 'package:restaurant_ibdp_submission/buttonDialog.dart';
import 'package:restaurant_ibdp_submission/popScopeDialog.dart';
import 'package:restaurant_ibdp_submission/teledart.dart';
import 'package:intl/intl.dart';

class newKitchenViewOrderPage extends StatefulWidget {
  @override
  State<newKitchenViewOrderPage> createState() =>
      newKitchenViewOrderPageState(selectedView: "all");
}

class newKitchenViewOrderPageState extends State<newKitchenViewOrderPage> {
  late bool itemToShow;
  late String selectedView;
  late String rootPath;
  newKitchenViewOrderPageState({
    required this.selectedView,
  });

  late DatabaseReference usedRef;

  DatabaseReference ordersSubmittedRef =
      FirebaseRealtimeService.database.ref("ordersSubmitted");
  DatabaseReference ordersPOSRef =
      FirebaseRealtimeService.database.ref("ordersForPOS");
  late bool isKitchen;

  Future<List<dynamic>> getFutureData() async {
    if (selectedView == "POS") {
      rootPath = "ordersForPOS";
      isKitchen = false;
    } else {
      rootPath = "ordersSubmitted";
      isKitchen = true;
    }

    final Future<List<String>> gettingCollection =
        FirebaseRealtimeService().getCombinedCollection();
    final Future<DataSnapshot> gettingCurrentOrders =
        FirebaseRealtimeService.database.ref().child(rootPath).get();
    final Future<List<dynamic>> combinedFuture =
        Future.wait([gettingCurrentOrders, gettingCollection]);
    return combinedFuture;
  }

  Widget loadingDataPlaceholder(String message) {
    return Center(child: Text(message, style: const TextStyle(fontSize: 55)));
  }

  Widget kitchenViewOrders() {
    if (selectedView == "POS") {
      usedRef = ordersPOSRef;
      isKitchen = false;
    } else {
      usedRef = ordersSubmittedRef;
      isKitchen = true;
    }

    bool itemToShow = true;
    FirebaseRealtimeService().manageSnapshot();
    FirebaseRealtimeService().writeCombinedCollection();

//help of getting two futures in a single futurebuilder is from google gemini

    return Scaffold(
      appBar: AppBar(
          leading: popScopeDialog(
            levels: 2,
            category: "viewer",
          ), //return to home screen
          title: Text(
              "Viewing all active submitted orders of type $selectedView")),
      body: FutureBuilder<List<dynamic>>(
        future: getFutureData(),
        builder: (context, snapshot) {
          usedRef.onValue.listen((DatabaseEvent event) {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => kitchenViewOrders()));
          });
          print(snapshot.connectionState);

          if (snapshot.data == null || snapshot.data?[0].value == null) {
            if (snapshot.connectionState == "done") {
              return loadingDataPlaceholder("No orders have been found.");
            } else {
              return loadingDataPlaceholder("Loading orders, please wait.");
            }
          } else if (snapshot.hasData) {
            final orderItems = snapshot.data?[0].value;
            final foodItemList = snapshot.data?[1];
            final orders = orderItems as Map<dynamic, dynamic>;
            final orderList = orders.entries.map(
              (entry) {
                return entry.value;
              },
            ).toList();
            return Column(
              children: [
                ElevatedButton(
                    onPressed: () {
                      reloadAvailableOrders(context, selectedView);
                    },
                    child: const Text("Manual reload")),
                SizedBox(
                  width: 0.95 * MediaQuery.of(context).size.width,
                  height: 0.8 * MediaQuery.of(context).size.height,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    //help from google bard
                    itemCount: orderList.length,
                    itemBuilder: (context, index) {
                      //print("itembuilder index is $index"); //how many separate table orders are there?
                      final order = orderList[index];
                      List<Map<String, dynamic>> allItemData = [];
                      final List<Map<String, dynamic>> alwaysBlankData = [];

                      try {
                        for (int foodOrder = 0;
                            foodOrder < foodItemList.length;
                            foodOrder++) {
                          for (var entry in order["items"].entries) {
                            //going through each item in a order
                            //this for loop is from google bard

                            Map<String, dynamic> itemData = entry.value;

                            if (itemData['itemType'].compareTo(selectedView) ==
                                    0 ||
                                selectedView.compareTo("all") == 0 ||
                                selectedView.compareTo("POS") == 0) {
                              //https://www.tutorialkart.com/dart/dart-how-to-check-if-two-strings-are-equal/#gsc.tab=0
                              {
                                if ((itemData['categorySelected']
                                        .compareTo(foodItemList[foodOrder])) ==
                                    0) {
                                  itemList.writeList(itemData);
                                  allItemData.add(itemData);
                                  itemToShow = true;
                                }
                              }
                            }
                          }
                        }
                      } catch (e) {
                        allItemData =
                            alwaysBlankData; //delete orders that don't have any items remaining
                        FirebaseRealtimeService().remove(
                            '$rootPath/${order['extraInfo']['initialTime']}');
                      }
                      print("i have been run.");

                      if (itemToShow == false) {
                        allItemData = alwaysBlankData;
                      }
                      if (allItemData.toString() == "[]") {
                        return loadingDataPlaceholder(
                            "No orders have been found.");
                      } else {
                        //help from google gemini to convert the initialTime into HH:mm
                        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                            DateTime.now().millisecondsSinceEpoch);
                        final formatter = DateFormat('HH:mm');
                        String timeInHuman = formatter.format(dateTime);

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //whole (general) order info
                                  Text(
                                    'ID: ${order['extraInfo']["shortOrderID"]}',
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  Text(
                                    'Time submitted: $timeInHuman',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  Text(
                                    '${order['extraInfo']["floor"]} — Table ${order['extraInfo']["table"]}',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  Text(
                                    'items to fulfill: ${allItemData.length}',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  //info for each item
                                  manageCard().textForCard(
                                      allItemData,
                                      "$rootPath/${order['extraInfo']['initialTime']}",
                                      context,
                                      isKitchen,
                                      order['extraInfo']['initialTime'],
                                      0,
                                      selectedView,
                                      rootPath,
                                      order['extraInfo']["shortOrderID"],
                                      order['extraInfo']["floor"],
                                      order['extraInfo']["table"]),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          } else {
            return loadingDataPlaceholder("Loading orders, please wait!");
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError(
        "Don't build this! Call on kitchenViewOrders(String selectedView)!");
    //this is due to passing arguments
  }
}

class manageCard {
  Widget textForCard(
    List<Map<String, dynamic>> allItemData,
    String pathToRemove,
    BuildContext context,
    bool isKitchen,
    int initialTime,
    int levels,
    String selectedView,
    String rootPath,
    String shortOrderID,
    String floor,
    String table,
  ) {
    return Column(
      children: <Widget>[
        //run for each item in an order
        for (int i = 0; i < allItemData.length; i++)
          processCards(
              allItemData[i],
              i + 1,
              pathToRemove,
              context,
              isKitchen,
              initialTime,
              levels,
              selectedView,
              rootPath,
              shortOrderID,
              floor,
              table),
      ],
    );
  }

  Widget processCards(
    Map<String, dynamic> specificData,
    int count,
    String pathToRemove,
    BuildContext context,
    bool isKitchen,
    int initialTime,
    int levels,
    String selectedView,
    String rootPath,
    String shortOrderID,
    String floor,
    String table,
  ) {
    //only show prices if view is for POS data entry

    return Column(
      children: <Widget>[
        const Divider(),
        Text("Item #$count"),
        Text("Name: ${specificData["name"]}"),
        FirebaseRealtimeService().showChoice(specificData["choice"]),
        Text("Quantity: ${specificData["quantity"]}"),
        FirebaseRealtimeService()
            .showCustomComment(specificData["customComment"]),
        FirebaseRealtimeService().showIndividualPrices(
            specificData["individualPrice"], selectedView),
        FirebaseRealtimeService().showOverallPrices(
            specificData["individualPrice"],
            specificData["itemOverallPrice"],
            selectedView),
        manageCard().dismissCardDialog(
            "$rootPath/$initialTime/items/${specificData['itemTime']}",
            specificData["name"],
            context,
            isKitchen,
            initialTime,
            0,
            selectedView,
            shortOrderID,
            floor,
            table),
      ],
    );
  }

  Widget dismissCardDialog(
      String pathToRemove,
      String foodName,
      //String shortOrderID,
      BuildContext context,
      bool isKitchen,
      int initialTime,
      int levels,
      String selectedView,
      String shortOrderID,
      String floor,
      String table) {
    //when this is called, a button widget is returned, the button then opens the "are you sure" dialog
    return ElevatedButton(
        onPressed: () {
          dismissCardDialogUltra(pathToRemove, foodName, context, isKitchen,
              initialTime, levels, selectedView, shortOrderID, floor, table);
        },
        child: const Text("Dismiss this item",
            style: TextStyle(color: Colors.red)));
  }

  Future<dynamic> dismissCardDialogUltra(
      String pathToRemove,
      String foodName,
      BuildContext context,
      bool isKitchen,
      int initialTime,
      int levels,
      String selectedView,
      String shortOrderID,
      String floor,
      String table) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Dismiss this item?"),
          content: const Text("This can't be undone!"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text("Remove entry",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                print(
                    "selectedview is $selectedView, order is is $shortOrderID");
                //if (selectedView != "POS") {
                if (isKitchen == true) {
                  teledartService().sendTelegramMessageWaiter(
                      "The item $foodName is ready to be picked up. Order ID $shortOrderID, for $floor at $table");

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Item marked as completed!"),
                  ));
                }
                FirebaseRealtimeService().remove(pathToRemove);
                Navigator.pop(context);

                if (isKitchen == true || selectedView == "POS") {
                  reloadAvailableOrders(context, selectedView);
                } else {
                  navigatorPop(context, 1);
                  viewCurrentOrder(initialTime: initialTime, levels: levels)
                      .getDialog(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
}

void reloadAvailableOrders(BuildContext context, String selectedView) {
  Navigator.pop(context);
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              newKitchenViewOrderPageState(selectedView: selectedView)
                  .kitchenViewOrders()));
}
