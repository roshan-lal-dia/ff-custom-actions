// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

//import '/backend/schema/structs/index.dart';
//import '/actions/actions.dart' as action_blocks;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

String formatFirestoreTimestamp(Timestamp timestamp) {
  // Convierte el Timestamp en un objeto DateTime
  DateTime dateTime = timestamp.toDate();

  // Formatea la fecha en el formato deseado
  String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);

  return formattedDate;
}

Future exportFirebaseCollectionToCSVTimeFilter(
  String collectionName,
  List<String> rowTitles,
  List<String> fieldNames,
  DateTime? start,
  DateTime? end,
  String dateFieldName,
) async {
  // Add your function code here!

  if (start == null) {
    start = DateTime.now().subtract(Duration(
        hours: DateTime.now().hour,
        minutes: DateTime.now().minute,
        seconds: DateTime.now().second,
        milliseconds: DateTime.now().millisecond));
  }

  if (end == null) {
    end = start
        .add(Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
  }

// Query for the documents
  final CollectionReference myCollection =
      FirebaseFirestore.instance.collection(collectionName);
  //final QuerySnapshot querySnapshot = await myCollection.get();
  final QuerySnapshot querySnapshot = await myCollection
      .where(dateFieldName, isGreaterThanOrEqualTo: start)
      .where(dateFieldName, isLessThanOrEqualTo: end)
      .get();
  final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

// Convert the data into CSV format
  final List<List<dynamic>> rows = [];
  List<dynamic> values = [];
  rows.add(rowTitles); // Add header row
  for (final document in documents) {
    final id = document.id;
    final data = document.data() as Map<String, dynamic>;
    for (var field in fieldNames) {
      if (data[field] is Timestamp) {
        print("Entra");

        values.add(formatFirestoreTimestamp(data[field]));
      } else {
        print("no Entra");
        values.add(data[field]);
      }
    }

    rows.add(values);
    values = [];
  }
  final csvData = const ListToCsvConverter().convert(rows);

// Download the CSV file
  final bytes = utf8.encode(csvData);
  final base64Data = base64Encode(bytes);
  final uri = 'data:text/csv;base64,$base64Data';
  await launch(uri);
}
