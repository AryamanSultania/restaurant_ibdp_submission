//this file is for all operations which needs interaction with Firebase Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseFirestoreClass {
  final firestoreDatabase = FirebaseFirestore.instance;
  late List<String> optionsList;

  Future<String> getImageURL(
    String mainCategory,
    String secondaryCategory,
    String foodID,
  ) async {
    final ref1 = firestoreDatabase
        .collection("items_2")
        .doc(mainCategory) //"food"
        .collection(secondaryCategory) //"mainCourse"
        .doc(foodID); //"burrito"
    String mainPath = '';
    await ref1.get().then(
      (DocumentSnapshot doc) async {
        final data = doc.data() as Map<String, dynamic>;
        final specificImageURL = data['image'].path;
        mainPath = specificImageURL.toString().substring(
            32); //removes the firebase specific location name, and focuses on directory in firebase storage
      },
    );

    String downloadURL = await FirebaseStorage.instance
        .ref(mainPath.toString())
        .getDownloadURL();

    return downloadURL;
  }

  Future<List<String>> readOptions(
    //what options are abailable for a specific menu item?
    String mainCategory,
    String secondaryCategory,
    String foodID,
  ) async {
    final ref1 = firestoreDatabase
        .collection("items_2")
        .doc(mainCategory) //"food"
        .collection(secondaryCategory) //"mainCourse"
        .doc(foodID); //"burrito"

    var returnValue = ref1.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        final specificData = data['options'];
        List<String> optionsList = specificData.split('/');
        return optionsList;
      },
    );
    return await returnValue;
  }

  Future<String> readDocsString(
    //what options are abailable for a specific menu item?
    String mainCategory,
    String secondaryCategory,
    String foodID,
    String desiredProperty,
  ) async {
    final ref1 = firestoreDatabase
        .collection("items_2")
        .doc(mainCategory) //"food"
        .collection(secondaryCategory) //"mainCourse"
        .doc(foodID); //"burrito"

    var returnValue = ref1.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        final specificData = data[desiredProperty];
        return specificData;
      },
    );
    return await returnValue;
  }
}
