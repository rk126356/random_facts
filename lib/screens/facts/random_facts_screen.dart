import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:random_facts/data/colors.dart';
import 'package:random_facts/models/random_fact_model.dart';
import 'package:random_facts/utils/local_storage_facts.dart';
import 'package:random_facts/widgets/banner_ad_widget.dart';

class RandomFactsScreen extends StatefulWidget {
  const RandomFactsScreen({super.key});

  @override
  State<RandomFactsScreen> createState() => _RandomFactsScreenState();
}

class _RandomFactsScreenState extends State<RandomFactsScreen> {
  final String path = 'random_facts';
  List<RandomFact> facts = [];
  bool _isLoading = false;
  int currentPage = 0;

  Future<void> fetchFacts() async {
    setState(() {
      _isLoading = true;
    });

    List<RandomFact> localFacts = await getLocalFactsRandom(path);

    if (localFacts.isNotEmpty) {
      debugPrint('Fetched facts from local');
      setState(() {
        facts = localFacts;
        _isLoading = false;
      });
      return;
    }

    final CollectionReference factsCollection =
        FirebaseFirestore.instance.collection(path);

    try {
      debugPrint('Fetched facts from Firebase');
      QuerySnapshot querySnapshot =
          await factsCollection.orderBy('createdAt').get();

      facts = querySnapshot.docs.map((fact) {
        return RandomFact(
          factName: fact['factName'],
          color: predefinedColors[Random().nextInt(predefinedColors.length)],
        );
      }).toList();

      await saveLocalFactsRandom(facts, path);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error getting facts: $e");
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void fetchNumber() async {
    currentPage = await getPageNumber(path);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchFacts();
    fetchNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Random Facts',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.hide_image),
                label: const Text('Remove Ads')),
          )
        ],
        backgroundColor: const Color(0xFF512DA8),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 56, 17, 147),
                    Color.fromARGB(255, 39, 27, 146),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(child: BannerAdWidget()),
                  SizedBox(
                    height: 600,
                    child: CardSwiper(
                      initialIndex: currentPage,
                      cardsCount: facts.length,
                      cardBuilder: (context, index, percentThresholdX,
                          percentThresholdY) {
                        savePageNumber(index, path);
                        final fact = facts[index];
                        return _buildFactCard(fact);
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Center(child: BannerAdWidget()),
                ],
              ),
            ),
    );
  }

  Widget _buildFactCard(RandomFact fact) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: fact.color,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SingleChildScrollView(
                  child: Text(
                    fact.factName,
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(
                Icons.favorite_border, // Change this to your favorite icon
                color: Colors.white,
              ),
              onPressed: () {
                // Add your favorite button logic here
              },
            ),
          ),
          Positioned(
            left: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(
                Icons.share, // Change this to your favorite icon
                color: Colors.white,
              ),
              onPressed: () {
                // Add your favorite button logic here
              },
            ),
          ),
        ],
      ),
    );
  }
}
