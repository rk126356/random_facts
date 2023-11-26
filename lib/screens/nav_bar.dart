import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:random_facts/screens/give_rating_screen.dart';
import 'package:random_facts/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Random Facts'),
            accountEmail: const Text('Version: 1.0.0'),
            currentAccountPicture: CachedNetworkImage(
              height: 90,
              width: 90,
              imageUrl:
                  'https://static.zooniverse.org/www.zooniverse.org/assets/simple-avatar.png',
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF512DA8),
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/images/profile-bg3.jpg')),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.home,
              color: Color(0xFF512DA8),
            ),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.favorite,
              color: Color(0xFF512DA8),
            ),
            title: const Text('Liked Facts'),
            onTap: () => Navigator.pushNamed(context, '/students'),
          ),
          ListTile(
            leading: const Icon(
              Icons.hide_image_rounded,
              color: Color(0xFF512DA8),
            ),
            title: const Text('Remove Ads'),
            onTap: () => Navigator.pushNamed(context, '/payments'),
          ),
          ListTile(
            leading: const Icon(
              Icons.help,
              color: Color(0xFF512DA8),
            ),
            title: const Text('Help & Support'),
            onTap: () => Navigator.pushNamed(context, '/upcoming-payments'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.star,
              color: Color(0xFF512DA8),
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
              color: Color(0xFF512DA8),
            ),
            title: const Text(
              'Settings',
            ),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          const Divider(),

          // ),
          ListTile(
            title: const Text('Exit'),
            leading: const Icon(Icons.logout),
            onTap: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              await preferences.clear();
            },
          ),
        ],
      ),
    );
  }
}
