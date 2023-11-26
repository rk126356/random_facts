import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  late NativeAd _nativeAd;

  @override
  void initState() {
    super.initState();

    // Replace the ad unit ID with your own
    _nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-3940256099942544/2247696110	',
      factoryId: 'listTile',
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          print('Native ad loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          print('Native ad failed to load: $error');
        },
      ),
    );

    // Load the native ad
    _nativeAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Customize the appearance of the native ad container
      padding: EdgeInsets.all(8.0),
      color: Colors.grey,
      child: AdWidget(ad: _nativeAd),
    );
  }

  @override
  void dispose() {
    _nativeAd.dispose();
    super.dispose();
  }
}
