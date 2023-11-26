import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:random_facts/models/fact_model.dart';
import 'package:random_facts/models/random_fact_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLocalFacts(List<Fact> facts, String name) async {
  if (kDebugMode) {
    print('Saving local facts $name');
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String factsJson = jsonEncode(facts.map((fact) => fact.toJson()).toList());
  prefs.setString(name, factsJson);
}

Future<List<Fact>> getLocalFacts(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? factsJson = prefs.getString(name);

  if (factsJson != null && factsJson.isNotEmpty) {
    try {
      List<dynamic> factsData = List<dynamic>.from(jsonDecode(factsJson));
      return factsData.map((data) => Fact.fromJson(data)).toList();
    } catch (e) {
      print('Error parsing JSON: $e');
    }
  }

  return [];
}

Future<void> saveLocalFactsRandom(List<RandomFact> facts, String name) async {
  if (kDebugMode) {
    print('Saving local facts $name');
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String factsJson = jsonEncode(facts.map((fact) => fact.toJson()).toList());
  prefs.setString(name, factsJson);
}

Future<List<RandomFact>> getLocalFactsRandom(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? factsJson = prefs.getString(name);

  if (factsJson != null && factsJson.isNotEmpty) {
    try {
      List<dynamic> factsData = List<dynamic>.from(jsonDecode(factsJson));
      return factsData.map((data) => RandomFact.fromJson(data)).toList();
    } catch (e) {
      print('Error parsing JSON: $e');
    }
  }

  return [];
}

Future<void> savePageNumber(int number, String name) async {
  if (kDebugMode) {
    print('Saving local page number $name');
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setInt('${name}_number', number);
}

Future<int> getPageNumber(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? number = prefs.getInt('${name}_number');

  if (number != null) {
    try {
      return number;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting saved page number: $e');
      }
    }
  }

  return 0;
}
