import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_facts/common/colors.dart';
import 'package:random_facts/providers/utils_provider.dart';

class LikedFactsScreen extends StatefulWidget {
  const LikedFactsScreen({super.key});

  @override
  State<LikedFactsScreen> createState() => _LikedFactsScreenState();
}

class _LikedFactsScreenState extends State<LikedFactsScreen> {
  List<String> _likedFacts = [];

  void getLikedFacts() {
    final like = Provider.of<UtilsProvider>(context, listen: false);
    setState(() {
      _likedFacts = like.likedRandomFacts;
    });
  }

  @override
  void initState() {
    super.initState();
    getLikedFacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primaryColor,
        title: Text(
          _likedFacts.isEmpty
              ? 'Liked Facts'
              : 'Liked Facts (${_likedFacts.length})',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _likedFacts.isEmpty
          ? const Center(
              child: Text(
                'No liked facts yet.',
                style: TextStyle(fontSize: 18.0),
              ),
            )
          : ListView.builder(
              itemCount: _likedFacts.length,
              itemBuilder: (context, index) {
                final reversedIndex = _likedFacts.length - index - 1;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4.0,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        _likedFacts[reversedIndex],
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () {
                          final like = Provider.of<UtilsProvider>(context,
                              listen: false);
                          like.removeLikedRandomFact(
                              _likedFacts[reversedIndex]);
                          setState(() {});
                        },
                      ),
                      onTap: () {},
                    ),
                  ),
                );
              },
            ),
    );
  }
}
