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

Future exportCompleteFirebaseCollectionToCSV(
  String collectionName,
  List<String> rowTitles,
  List<String> fieldNames,
) async {
  // Add your function code here!

// Query for the documents
  final CollectionReference myCollection =
      FirebaseFirestore.instance.collection(collectionName);
  final QuerySnapshot querySnapshot = await myCollection.get();
  final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

// Convert the data into CSV format
  final List<List<dynamic>> rows = [];
  List<dynamic> values = [];
  rows.add(rowTitles); // Add header row
  for (final document in documents) {
    final id = document.id;
    final data = document.data() as Map<String, dynamic>;
    for (var field in fieldNames) {
      values.add(data[field]);
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
