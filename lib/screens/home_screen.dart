import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:random_facts/common/colors.dart';
import 'package:random_facts/providers/ad_provider.dart';
import 'package:random_facts/screens/facts/inside_facts_screen.dart';
import 'package:random_facts/screens/facts/random_facts_screen.dart';
import 'package:random_facts/screens/nav_bar.dart';
import 'package:random_facts/screens/remove_ads_screen.dart';
import 'package:random_facts/utils/check_app_update.dart';
import 'package:random_facts/widgets/banner_ad_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> categories = [
    {"name": "Random Facts", "icon": Icons.star, "color": Colors.pink},
    {
      "name": "Fun Facts",
      "icon": Icons.sentiment_very_satisfied,
      "color": Colors.orange
    },
    {
      "name": "Game Facts",
      "icon": Icons.sports_esports,
      "color": Colors.deepPurple
    },
    {"name": "Food Facts", "icon": Icons.fastfood, "color": Colors.green},
    {"name": "Tech Facts", "icon": Icons.computer, "color": Colors.blue},
    {"name": "Space Facts", "icon": Icons.satellite, "color": Colors.teal},
  ];

  bool _isloading = false;

  void checkShouldShowAd() async {
    setState(() {
      _isloading = true;
    });
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    final appInfoGet = await FirebaseFirestore.instance
        .collection('appInfo')
        .doc('iO8Yck5WE3uvfxiKxT6E')
        .get();

    final appInfoData = appInfoGet.data();

    final isPremium = await adProvider.getPremium();

    if (appInfoData?['shouldShowAd'] && !isPremium) {
      adProvider.setShouldShowAd(true);
      adProvider.initializeInterstitialAd();
      if (kDebugMode) {
        print(appInfoData?['shouldShowAd']);
      }
    } else {
      if (kDebugMode) {
        print(appInfoData?['shouldShowAd']);
      }
    }
    setState(() {
      _isloading = false;
    });
  }

  void initializeOneSignal() {
    //Remove this method to stop OneSignal Debugging
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize("f857a6c6-c50a-437a-9914-274ca1a9e5ea");

// // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.Notifications.requestPermission(true);
  }

  @override
  void initState() {
    super.initState();
    updateAppLaunched(context);
    checkShouldShowAd();
    initializeOneSignal();
  }

  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Image.asset(
            'assets/images/logo.png',
            height: 60,
          ),
          backgroundColor: AppColors.primaryColor,
          actions: <Widget>[
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
                    label: const Text(
                      'ADS',
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                      ),
                    )),
              )
          ]),
      body: _isloading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor,
                      Color(0xFF311B92),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        !adProvider.isPremium ? 'Real Facts' : 'Real Facts Pro',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    // Categories
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              if (categories[index]['name'] == 'Random Facts') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RandomFactsScreen(),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => InsideFactsScreen(
                                      name: categories[index]['name'],
                                      color: categories[index]['color'],
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: categories[index]["color"],
                                borderRadius: BorderRadius.circular(12.0),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    categories[index]["color"]!,
                                    categories[index]["color"]!
                                        .withOpacity(0.8),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    categories[index]["icon"],
                                    size: 40.0,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    categories[index]["name"],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (adProvider.shouldShowAd)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: BannerAdWidget(),
                      ),
                    if (!adProvider.isPremium)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 45, vertical: 8),
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
                    if (!adProvider.isPremium) const SizedBox(height: 40),
                    const SizedBox(height: 140)
                  ],
                ),
              ),
            ),
    );
  }
}
