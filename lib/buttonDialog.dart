//this file will house many buttons and their actions

// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_ibdp_submission/FirebaseFirestoreClass.dart';
import 'package:restaurant_ibdp_submission/FirebaseRealtimeService.dart';
import 'package:restaurant_ibdp_submission/basicPopupDialog.dart';
import 'package:restaurant_ibdp_submission/kitchenView.dart';
import 'package:restaurant_ibdp_submission/popScopeDialog.dart';
import 'package:restaurant_ibdp_submission/teledart.dart';
import 'package:provider/provider.dart';

class buttonDialogStateless extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => dataUpdater(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        //home: StatefulDialog(),
      ),
    );
  }
}

class dataUpdater extends ChangeNotifier {
  //String selectedDocument = 'food';
  int selectedView = 0;
  void updateView(int newView) {
    selectedView = newView;
    notifyListeners();
  } //copied from navigationMenu.dart
}

class writeBlankChoice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DropDownVariables.stringChoice = "None";
    return const SizedBox(height: 10);
  }
}

class DropDownVariables {
  //for the 3 drop downs available, these are the variable accessors and mutators.
  //help of instance vs static variables with Google Bard AI

  static late String stringChoice;
  static late String stringFloor;
  static late String stringTable;
  //3 drop downs, 3 variables
}

class itemList {
  //accessor and mutator of itemData map
  static late Map<String, dynamic> itemData;
  static void writeList(Map<String, dynamic> inputList) {
    itemData = inputList;
  }

  static Map<String, dynamic> getList() {
    return itemData;
  }
}

class OptionDropDown extends StatefulWidget {
  //a stateful widget is needed as the displayed data does change
  //https://www.youtube.com/watch?v=z0ihUbwlSHs
  late String inputChoices;
  OptionDropDown({required this.inputChoices});

  @override
  _OptionDropDownState createState() =>
      _OptionDropDownState(inputChoices: splitIntoList(inputChoices));

  List<String> splitIntoList(inputChoices) {
    //since options are stored as a single string in Firebase Firestore, they need to be converted to a list for the dropdown.
    List<String> choicesList = inputChoices.split('/');
    return choicesList;
  }
}

class _OptionDropDownState extends State<OptionDropDown> {
  List<String> inputChoices;
  _OptionDropDownState({
    required this.inputChoices,
  });

  late String? selectedOption = inputChoices[0];
  late int indexDropDown;

  @override
  Widget build(BuildContext context) {
    DropDownVariables.stringChoice = selectedOption.toString();
    //make the selection accessible to the ordering dialog, through variable passthrough
    return DropdownButton<String>(
      value: selectedOption,
      items: inputChoices
          .map(
            //remaps the list items into a format compatiable with the dropdown
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: (item) => setState(() => selectedOption = item),
    );
  }
} //end of _dropdownstate

class DoubleDropDown extends StatefulWidget {
  //double dropdown is for selecting the floor, and then adapting and offering the respective tables
  //https://www.youtube.com/watch?v=z0ihUbwlSHs
  late String inputChoices;
  DoubleDropDown({required this.inputChoices});

  @override
  _DoubleDropDownState createState() =>
      _DoubleDropDownState(inputFloors: splitIntoList(inputChoices));

  List<String> splitIntoList(inputChoices) {
    List<String> choicesList = inputChoices.split('/');
    return choicesList;
  }
}

class _DoubleDropDownState extends State<DoubleDropDown> {
  List<String> inputFloors;
  _DoubleDropDownState({
    required this.inputFloors,
  });
  late String? firstSelectedOption = inputFloors[0];
  late String? previousFirstSelectedOption = inputFloors[0];
  late String? secondSelectedOption = "Table 1";
  late int indexDropDown;

  late List<String> availableSeats = ["Table 1"];

  @override
  Widget build(BuildContext context) {
    //reset second selection if first option has changed
    
    if (firstSelectedOption == "Floor 1") {
      availableSeats = ['Table 1', 'Table 2', 'Table 3', 'Table 4', 'Table 5', 'Table 6', 'Table 7', 'Table 8', 'Table 9'];
    } else if (firstSelectedOption == "Floor 2") {
      availableSeats = ['Table 1', 'Table 2', 'Table 3', 'Table 4', 'Table 5', 'Table 6', 'Table 7'];
    } else if (firstSelectedOption == "Floor 3") {
      availableSeats = ['Table 1', 'Table 2', 'Table 3', 'Table 4', 'Table 5', 'Table 6', 'Table 7', 'Table 8'];
    } else if (firstSelectedOption == "Floor 4") {
      availableSeats = ['Table 1', 'Table 2', 'Table 3', 'Table 4', 'Table 5', 'Table 6', 'Table 7'];
    } else if (firstSelectedOption == "Delivery") {
      availableSeats = [
        'Foodpanda',
        'Grab',
        'Lineman',
        'Service A',
        'Service B',
        'Service C',
        'Service D',
        'Service E',
      ];
    }
    if (previousFirstSelectedOption != firstSelectedOption) {
      //secondSelectedOption = "1";
      secondSelectedOption = availableSeats[0];
    }
    previousFirstSelectedOption = firstSelectedOption;
    DropDownVariables.stringFloor = firstSelectedOption.toString();
    DropDownVariables.stringTable = secondSelectedOption.toString();
    //whenever this is called/refreshed, the variables are available to other processes, in this case the process for writing the order into ordersSubmitted for kitchen, last step for waiter
    return Column(
      children: [
        const Text("Select floor"),
        DropdownButton<String>(
          value: firstSelectedOption,
          items: inputFloors
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: (item) => setState(() => firstSelectedOption = item),
        ),
        const Text("Select table on floor"),
        DropdownButton<String>(
          value: secondSelectedOption,
          items: availableSeats
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: (item) => setState(() => secondSelectedOption = item),
        ),
      ],
    );
  }
} //end of _doubledropdownstate

class addItemToOrderDialog {
  //called when a menu item is selected by the waiter
  late String path;
  late String name;
  late String
      choices; //choices are obtained as a string from Firebase Firestore, and will be converted to a list if needed in the dropdown functions
  late String price;
  late int initialTime;

  addItemToOrderDialog({
    required this.path,
    required this.name,
    required this.choices,
    required this.price,
    required this.initialTime,
  });

  //controllers are how the text input into the text boxes are collected
  final commentController = TextEditingController();
  final quantityController = TextEditingController();

  void dispose() {
    commentController.dispose();
    quantityController.dispose();
  }

  Future<dynamic> getDialog(BuildContext context) async {
    List<String> pathAsList =
        OptionDropDown(inputChoices: path).splitIntoList(path);
    String itemType = pathAsList[1];
    String categorySelected = pathAsList[2];

    List<String> choicesAsList =
        OptionDropDown(inputChoices: choices).splitIntoList(choices);
    List<String> availablePrices = price.split('/');

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 50,
          width: 5,
          child: AlertDialog(
            content: Column(
              children: [
                Text(
                  "Placing order of $name",
                  style: const TextStyle(fontSize: 16),
                ),
                TextField(
                  //number only help from https://stackoverflow.com/a/49578197
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(
                        //this only allows positive numbers, at least 1 (negatives or 0 are not valid entries)
                        r'^[1-9][0-9]*')), //https://stackoverflow.com/a/71841401
                  ],
                  controller: quantityController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: "Enter quantity",
                    filled: false,
                    fillColor: Colors.blueAccent,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                if (choices !=
                    "None") //if there are options available (chicken, pork, etc), then display them
                  OptionDropDown(inputChoices: choices),
                if (choices ==
                    "None") //if there are no options available, then give spacing
                  writeBlankChoice(),
                TextField(
                  controller: commentController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: "Custom comment for this item",
                    filled: false,
                    fillColor: Colors.blueAccent,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Item has been CANCELLED."),
                    ));
                  },
                  child: const Text(
                    "Cancel, go back",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                ),
                ElevatedButton(
                  onPressed: () {
                    late String quantityString;
                    quantityString = quantityController.text;
                    late String commentString = commentController.text;
                    //checks if a quantity is entered, if blank then prompt entry, else proceed
                    if (quantityString == "") {
                      basicTextDialog()
                          .getTextDialog("Please enter a quantity", context);
                    } else if (commentString.length < 3 &&
                        commentString.length != 0) {
                      //if comment length is less than 3 and is not 0 (if given comment is too short), then prompt to make it longer
                      basicTextDialog().getTextDialog(
                          "Custom comment is too short, either delete it or make it longer/more descriptive",
                          context);
                    } else {
                      String selectedChoice = DropDownVariables.stringChoice;
                      late int selectedPrice;

                      if (commentString == "") {
                        commentString = "No comment";
                      }

                      for (var i = 0; i < availablePrices.length; i++) {
                        if (selectedChoice == choicesAsList[i]) {
                          selectedPrice = int.parse(availablePrices[i]);
                        }
                      }

                      late int itemOverallPrice;
                      itemOverallPrice =
                          selectedPrice * int.parse(quantityString);

                      Navigator.pop(context);
                      int itemTime = DateTime.now()
                          .millisecondsSinceEpoch; //just like uniquely identifying orders, this helps uniquely identify specific item orders
                      //using update and not set, as set will remove all nested data and overwrite with this. updating is safer
                      FirebaseRealtimeService().updateData(
                        "ordersInProgress/$initialTime/items",
                        {
                          "$itemTime": {
                            "name": name,
                            "choice": selectedChoice,
                            "quantity": int.parse(quantityString),
                            "customComment": commentString,
                            "individualPrice": selectedPrice,
                            'itemOverallPrice': itemOverallPrice,
                            'itemTime': itemTime,
                            'firestorePath': path,
                            'itemType': itemType,
                            'itemMade': false,
                            'categorySelected': categorySelected,
                          }
                        },
                      );
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Item has been added!"),
                      ));
                    }
                  },
                  child: const Text(
                    "Save into order",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class floorAndTableSelector extends StatelessWidget {
  late int initialTime;
  late int levels;
  floorAndTableSelector({
    required this.initialTime,
    required this.levels,
  });

  Future<dynamic> getDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 50,
          width: 50,
          child: AlertDialog(
            content: Column(
              children: [
                tableSpecificToFloor(),
                ElevatedButton(
                    onPressed: () async {
                      String selectedFloor = DropDownVariables.stringFloor;
                      String selectedTable = DropDownVariables.stringTable;
                      String oldPath = "ordersInProgress/$initialTime";
                      String newPath = "ordersSubmitted/$initialTime";
                      String shortOrderID = (initialTime -
                              ((initialTime ~/ 1000000000) * 1000000000))
                          .toRadixString(16);
                      FirebaseRealtimeService()
                          .updateData("$oldPath/extraInfo", {
                        "table": selectedTable,
                        "floor": selectedFloor,
                        "initialTime": initialTime,
                        "shortOrderID": shortOrderID,
                      });

                      FirebaseRealtimeService().copyData(
                          "ordersInProgress/$initialTime",
                          "ordersForPOS/$initialTime");

                      teledartService().sendTelegramMessagePreparer(
                          "A new order has been submitted!");

                      FirebaseRealtimeService()
                          .moveData(oldPath, newPath, initialTime);
                      //navigator pop?
                      navigatorPop(context, levels);

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Order has been submitted!"),
                      ));
                    },
                    child: const Text("Submit to kitchen")),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget build(BuildContext context) {
    throw const Text("you're not meant to see this tabeSelector");
  }
}

class viewCurrentOrder {
  //called with floatingactionbutton on waiter screen
  late int initialTime;
  late int levels;
  viewCurrentOrder({
    required this.initialTime,
    required this.levels,
  });
  Future<dynamic> getDialog(BuildContext context) async {
    return FirebaseRealtimeService()
        .viewCurrentOrder(context, initialTime, levels, "");
  }
}

class tableSpecificToFloor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DoubleDropDown(
        inputChoices: "Floor 1/Floor 2/Floor 3/Floor 4/Delivery");
  }
}

class modifyItemDialog {
  //called on viewCurrentOrder, from floating action button on waiter, to modify selected item property
  //as reference, use the class for placing an item into an order for a waiter, that will help for modifying items
  late String inputChoice;
  late int inputQuantity;
  late String inputComment;
  late int initialTime;
  late int itemTime;
  late String path;
  late int individualPrice;
  late int levels;

  modifyItemDialog({
    required this.inputChoice,
    required this.inputQuantity,
    required this.inputComment,
    required this.initialTime,
    required this.itemTime,
    required this.path,
    required this.individualPrice,
    required this.levels,
  });

  final commentController = TextEditingController();
  final quantityController = TextEditingController();

  void dispose() {
    commentController.dispose();
    quantityController.dispose();
  }

  Widget buttonForChoice(BuildContext context) {
    if (inputChoice != "None") {
      return ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          modifyChoice(context);
        },
        child: const Text("Choice"),
      );
    } else {
      return SizedBox();
    }
  }

  Future<dynamic> selectPropertyDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          width: 0.4 * MediaQuery.of(context).size.width,
          height: 0.2 * MediaQuery.of(context).size.height,
          child: AlertDialog(
            content: Column(
              children: [
                const Text("what property would you like to modify?"),
                const Divider(),
                buttonForChoice(context),
                SizedBox(height: 0.03 * MediaQuery.of(context).size.height),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    modifyQuantity(context);
                  },
                  child: const Text("Quantity"),
                ),
                SizedBox(height: 0.03 * MediaQuery.of(context).size.height),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    //modifyQuantity(context);
                    modifyComment(context);
                  },
                  child: const Text("Custom comment"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<dynamic>> getOptionsPrices(String path) async {
    List<String> pathAsList =
        OptionDropDown(inputChoices: path).splitIntoList(path);

    Future<String> availableOptions = FirebaseFirestoreClass()
        .readDocsString(pathAsList[1], pathAsList[2], pathAsList[3], "options");

    Future<String> availablePrices = FirebaseFirestoreClass()
        .readDocsString(pathAsList[1], pathAsList[2], pathAsList[3], "prices");

    Future<Map<dynamic, dynamic>> itemRealtimeData =
        FirebaseRealtimeService().getCurrentOrderInfo(initialTime, itemTime);

    final Future<List<dynamic>> combinedFuture =
        Future.wait({availableOptions, availablePrices, itemRealtimeData});
    return combinedFuture;
  }

  dynamic modifyChoice(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<dynamic>>(
          future: getOptionsPrices(path),
          builder: (context, snapshot) {
            if (snapshot.data == null || snapshot.data?[0] == null) {
              return const CircularProgressIndicator();
            } else {
              final availableOptions = snapshot.data?[0];
              final availablePrices = snapshot.data?[1];
              Map<dynamic, dynamic> itemRealtimeData = snapshot.data?[2];
              List<String> optionsAsList = availableOptions.split('/');
              List<String> pricesAsList = availablePrices.split('/');

              return SizedBox(
                child: AlertDialog(
                  content: Column(
                    children: [
                      const Text("Select desired option"),
                      OptionDropDown(
                        inputChoices: availableOptions,
                      ),
                      ElevatedButton(
                        child: const Text("Update"),
                        onPressed: () {
                          int quantity = itemRealtimeData['quantity'];

                          String selectedChoice =
                              DropDownVariables.stringChoice;

                          late int selectedPrice;
                          late int itemOverallPrice;

                          for (var i = 0; i < pricesAsList.length; i++) {
                            print('index is $i');
                            if (selectedChoice == optionsAsList[i]) {
                              print("we got it");
                              selectedPrice = int.parse(pricesAsList[i]);
                            }
                          }
                          itemOverallPrice = selectedPrice * quantity;
                          print('before sending to rtdb');
                          FirebaseRealtimeService().updateData(
                            "ordersInProgress/$initialTime/items/$itemTime",
                            {
                              "choice": selectedChoice,
                              "individualPrice": selectedPrice,
                              'itemOverallPrice': itemOverallPrice,
                            },
                          );
                          navigatorPop(context,
                              2); //we use 2 and bring waiter back to the menu, because only 1 would show the outdated data

                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Choice has been updated!"),
                          ));
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  dynamic modifyQuantity(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          child: AlertDialog(
            content: Column(
              children: [
                const Text("Enter new quantity"),
                TextField(
                  //number only help from https://stackoverflow.com/a/49578197
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    //FilteringTextInputFormatter.digitsOnly
                    FilteringTextInputFormatter.allow(RegExp(
                        r'^[0-9][0-9]*')), //https://stackoverflow.com/a/71841401
                  ],
                  controller: quantityController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: "Enter quantity",
                    filled: false,
                    fillColor: Colors.blueAccent,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      late String quantityString = quantityController.text;

                      late int itemOverallPrice;
                      itemOverallPrice =
                          individualPrice * int.parse(quantityString);

                      FirebaseRealtimeService().updateData(
                        "ordersInProgress/$initialTime/items/$itemTime",
                        {
                          "quantity": int.parse(quantityString),
                          "itemOverallPrice": itemOverallPrice,
                        },
                      );
                      navigatorPop(context, 2);

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Quantity has been updated!"),
                      ));
                    },
                    child: const Text("Save")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
              ],
            ),
          ),
        );
      },
    );
  }

  dynamic modifyComment(BuildContext context) {
    commentController.text = "";
    //to implement
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          child: AlertDialog(
            content: Column(
              children: [
                const Text("Edit custom comment"),
                TextField(
                  controller: commentController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: "Custom comment for this item",
                    filled: false,
                    fillColor: Colors.blueAccent,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      late String commentString = commentController.text;
                      FirebaseRealtimeService().updateData(
                        "ordersInProgress/$initialTime/items/$itemTime",
                        {
                          "customComment": commentString,
                        },
                      );
                      navigatorPop(context, 2);

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Comment has been updated!"),
                      ));
                    },
                    child: const Text("Save")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
              ],
            ),
          ),
        );
      },
    );
  }
}

class selectOrderViewDialog {
  //called on viewCurrentOrder, from floating action button on waiter, to modify selected item property
  //as reference, use the class for placing an item into an order for a waiter, that will help for modifying items
  Future<dynamic> selectViewDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          width: 0.4 * MediaQuery.of(context).size.width,
          height: 0.2 * MediaQuery.of(context).size.height,
          child: AlertDialog(
            content: Column(
              children: [
                const Text("What view would you like to see?"),
                const Divider(),
                SizedBox(height: 0.03 * MediaQuery.of(context).size.height),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            newKitchenViewOrderPageState(selectedView: "food")
                                .kitchenViewOrders(),
                      ),
                    );
                  },
                  child: const Text("Kitchen [food items only]"),
                ),
                SizedBox(height: 0.03 * MediaQuery.of(context).size.height),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            newKitchenViewOrderPageState(selectedView: "drinks")
                                .kitchenViewOrders(),
                      ),
                    );
                  },
                  child: const Text("Barista [drink items only]"),
                ),
                SizedBox(height: 0.03 * MediaQuery.of(context).size.height),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            newKitchenViewOrderPageState(selectedView: "all")
                                .kitchenViewOrders(),
                      ),
                    );
                  },
                  child: const Text("All items"),
                ),
                SizedBox(height: 0.03 * MediaQuery.of(context).size.height),
                const Divider(
                  thickness: 3,
                  color: Color.fromARGB(255, 58, 58, 58),
                ),
                SizedBox(height: 0.03 * MediaQuery.of(context).size.height),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            newKitchenViewOrderPageState(selectedView: "POS")
                                .kitchenViewOrders(),
                      ),
                    );
                  },
                  child: const Text("POS data entry"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
