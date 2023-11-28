import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UtilsProvider with ChangeNotifier {
  List<String> _likedRandomFacts = [];
  List<String> get likedRandomFacts => _likedRandomFacts;

  // SharedPreferences key for storing liked random facts
  static const String likedRandomFactsKey = 'likedRandomFacts';

  // Constructor to load liked random facts from SharedPreferences on initialization
  UtilsProvider() {
    loadLikedRandomFacts();
  }

  void addLikedRandomFact(String fact) {
    if (!_likedRandomFacts.contains(fact)) {
      _likedRandomFacts.add(fact);
    }
    _saveLikedRandomFacts();
    notifyListeners();
  }

  void removeLikedRandomFact(String fact) {
    if (_likedRandomFacts.contains(fact)) {
      _likedRandomFacts.remove(fact);
    }
    _saveLikedRandomFacts();
    notifyListeners();
  }

  // Save liked random facts to SharedPreferences
  void _saveLikedRandomFacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(likedRandomFactsKey, _likedRandomFacts);
  }

  // Load liked random facts from SharedPreferences
  void loadLikedRandomFacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? likedFactsJsonList = prefs.getStringList(likedRandomFactsKey);

    if (likedFactsJsonList != null) {
      _likedRandomFacts = likedFactsJsonList;
      notifyListeners();
    }
  }
}
