import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';
import 'package:random_facts/data/colors.dart';
import 'package:random_facts/models/random_fact_model.dart';
import 'package:random_facts/providers/ad_provider.dart';
import 'package:random_facts/providers/utils_provider.dart';
import 'package:random_facts/screens/remove_ads_screen.dart';
import 'package:random_facts/utils/local_storage_facts.dart';
import 'package:random_facts/widgets/banner_ad_widget.dart';
import 'package:share_plus/share_plus.dart';

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
          factNumber: fact['factNumber'],
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
    final interstitialAdProvider =
        Provider.of<AdProvider>(context, listen: false);
    interstitialAdProvider.showInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
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
          if (!adProvider.isPremium)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const RemoveAdsScreen();
                      },
                    );
                  },
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
                  if (adProvider.shouldShowAd)
                    const Center(child: BannerAdWidget()),
                  SizedBox(
                    height: 600,
                    child: CardSwiper(
                      onSwipe: _onSwipe,
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
                  if (adProvider.shouldShowAd)
                    const Center(child: BannerAdWidget()),
                ],
              ),
            ),
    );
  }

  bool isLiked = false;

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    setState(() {
      isLiked = false;
    });
    final interstitialAdProvider =
        Provider.of<AdProvider>(context, listen: false);

    final like = Provider.of<UtilsProvider>(context, listen: false);

    final fact = facts[currentIndex!];

    if (like.likedRandomFacts.contains(fact.factName)) {
      setState(() {
        isLiked = true;
      });
    }

    if (previousIndex % 10 == 0) {
      interstitialAdProvider.showInterstitialAd();
    }
    debugPrint(
      'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
    );
    return true;
  }

  Widget _buildFactCard(RandomFact fact) {
    final fav = Provider.of<UtilsProvider>(context, listen: false);
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
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              onPressed: () {
                isLiked
                    ? fav.removeLikedRandomFact(fact.factName)
                    : fav.addLikedRandomFact(fact.factName);
                setState(() {
                  isLiked = isLiked ? false : true;
                });
              },
            ),
          ),
          Positioned(
            left: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(
                Icons.share,
                color: Colors.white,
              ),
              onPressed: () {
                Share.share(
                    'Fact:\n${fact.factName}\n\nFor more:\nhttps://play.google.com/store/apps/details?id=com.raihansk.random_facts');
              },
            ),
          ),
        ],
      ),
    );
  }
}
