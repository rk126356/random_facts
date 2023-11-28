import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:random_facts/common/colors.dart';
import 'package:random_facts/providers/ad_provider.dart';
import 'package:random_facts/providers/utils_provider.dart';
import 'package:random_facts/screens/give_rating_screen.dart';
import 'package:random_facts/screens/home_screen.dart';
import 'package:random_facts/screens/liked_facts_screen.dart';
import 'package:random_facts/screens/remove_ads_screen.dart';
import 'package:random_facts/screens/settings_screen.dart';
import 'package:random_facts/utils/url_launcher.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  String version = '1.0.0';

  void checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  void initState() {
    super.initState();
    checkVersion();
  }

  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName:
                Text(!adProvider.isPremium ? 'Real Facts' : 'Real Facts Pro'),
            accountEmail: Text('Version: $version'),
            currentAccountPicture: Image.asset('assets/images/logo.png'),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.home,
              color: AppColors.primaryColor,
            ),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.favorite,
              color: AppColors.primaryColor,
            ),
            title: const Text('Liked Facts'),
            onTap: () {
              final like = Provider.of<UtilsProvider>(context, listen: false);
              like.loadLikedRandomFacts();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LikedFactsScreen(),
                ),
              );
            },
          ),
          if (!adProvider.isPremium)
            ListTile(
                leading: const Icon(
                  Icons.hide_image_rounded,
                  color: AppColors.primaryColor,
                ),
                title: const Text('Remove Ads'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const RemoveAdsScreen();
                    },
                  );
                }),
          ListTile(
            leading: const Icon(
              Icons.help,
              color: AppColors.primaryColor,
            ),
            title: const Text('Help & Support'),
            onTap: () => open('https://raihansk.com/contact/'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.star,
              color: AppColors.primaryColor,
            ),
            title: const Text('Give Rating'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GiveRatingScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.settings,
              color: AppColors.primaryColor,
            ),
            title: const Text(
              'Settings',
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),

          // ),
          ListTile(
            title: const Text('Exit'),
            leading: const Icon(Icons.logout),
            onTap: () async {
              SystemNavigator.pop();
            },
          ),
        ],
      ),
    );
  }
}
