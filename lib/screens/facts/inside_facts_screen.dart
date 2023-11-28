import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_facts/models/fact_model.dart';
import 'package:random_facts/providers/ad_provider.dart';
import 'package:random_facts/screens/remove_ads_screen.dart';
import 'package:random_facts/utils/local_storage_facts.dart';
import 'package:random_facts/widgets/banner_ad_widget.dart';

class InsideFactsScreen extends StatefulWidget {
  final String name;
  final Color color;
  const InsideFactsScreen({Key? key, required this.name, required this.color})
      : super(key: key);

  @override
  State<InsideFactsScreen> createState() => _InsideFactsScreenState();
}

class _InsideFactsScreenState extends State<InsideFactsScreen> {
  late String path;
  late PageController _pageController;
  int currentPage = 0;
  List<Fact> factsList = [];
  bool _isLoading = false;

  Future<void> fetchFacts() async {
    setState(() {
      _isLoading = true;
    });

    List<Fact> localFacts = await getLocalFacts(path);

    if (localFacts.isNotEmpty) {
      debugPrint('fetched facts from local');
      setState(() {
        factsList = localFacts;
        _isLoading = false;
      });
      return;
    }

    final CollectionReference factsCollection =
        FirebaseFirestore.instance.collection(path);
    try {
      debugPrint('fetched facts from firebase');
      QuerySnapshot querySnapshot =
          await factsCollection.orderBy('createdAt').get();

      for (final fact in querySnapshot.docs) {
        final para = [];
        for (final p in fact['factParagraphs']) {
          para.add(p['text']);
        }
        final item = Fact(
          title: fact['factName'],
          image: fact['factImage'],
          paragraphs: para,
        );
        factsList.add(item);
      }

      await saveLocalFacts(factsList, path);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error getting facts: $e");
      }
    }
  }

  void fetchNumber() async {
    currentPage = await getPageNumber(path);
    setState(() {
      _pageController = PageController(initialPage: currentPage);
    });
  }

  String convertToSnakeCase(String input) {
    // Add underscores before uppercase letters and convert to lowercase
    String result = input.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => "_${match.group(1)?.toLowerCase()}",
    );

    // Remove the first underscore if it exists
    if (result.startsWith('_')) {
      result = result.substring(1);
    }

    // Replace spaces with underscores
    result = result.replaceAll(' ', '');

    return result;
  }

  @override
  void initState() {
    super.initState();
    path = convertToSnakeCase(widget.name);
    fetchFacts();
    fetchNumber();
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    adProvider.showInterstitialAd();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String capitalize(String input) {
    return "${input[0].toUpperCase()}${input.substring(1)}";
  }

  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context, listen: false);

    if ((currentPage + 1) % 5 == 0) {
      adProvider.showInterstitialAd();
      if (kDebugMode) {
        print('Showing ads');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: widget.color,
        iconTheme: const IconThemeData(color: Colors.white),
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
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              itemCount: factsList.length,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
                savePageNumber(currentPage, path);
              },
              itemBuilder: (context, index) {
                return _buildFactCard(factsList[index]);
              },
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.swipe_right,
            ),
            Row(
              children: [
                Text(
                  'Fact: ${currentPage + 1}/${factsList.length}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.swipe_left,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactCard(Fact fact) {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Fact Image
          CachedNetworkImage(
            height: 200,
            imageUrl: fact.image,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                const Center(child: Text("Check your internet connection!")),
          ),
          const SizedBox(
            height: 5,
          ),
          if (adProvider.shouldShowAd) const Center(child: BannerAdWidget()),
          // Fact Content
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fact.title,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: fact.paragraphs
                      .map<Widget>((paragraph) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              paragraph,
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (adProvider.shouldShowAd)
                  const Center(child: BannerAdWidget())
              ],
            ),
          ),
        ],
      ),
    );
  }
}
