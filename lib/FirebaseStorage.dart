//writing csv file into firebase storage

import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class FirebaseStorageInterface {
  final storage = FirebaseStorage.instance;
  final storageRef = FirebaseStorage.instance.ref();

  void uploadCsv(String inputCsv, int initialTime) async {
    String date = DateFormat("yyyy/MM/dd").format(DateTime.now());
    //https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html

    final finalRef = storageRef.child("savedOrders/$date/$initialTime.csv");

    try {
      await finalRef.putString(inputCsv, format: PutStringFormat.raw);
    } on FirebaseException catch (e) {
      print(
          "There has been an error with writing csv to firebase storage. error is $e");
    }
  }
}
