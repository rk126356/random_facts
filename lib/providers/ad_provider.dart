import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdProvider extends ChangeNotifier {
  bool _shouldShowAd = false;
  bool _isPremium = false;

  bool get shouldShowAd => _shouldShowAd;
  bool get isPremium => _isPremium;

  AdProvider() {
    getPremium();
  }

  void setShouldShowAd(bool value) {
    _shouldShowAd = value;
    notifyListeners();
  }

  void setIsPremium(bool value) {
    _isPremium = value;
    _savePremium();
    notifyListeners();
  }

  Future<void> _savePremium() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('premium', _isPremium);
  }

  Future<bool> getPremium() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? savedPremium = prefs.getBool('premium');

    if (savedPremium != null) {
      _isPremium = savedPremium;

      notifyListeners();
    }
    return savedPremium ?? false;
  }

  InterstitialAd? _interstitialAd;

  void initializeInterstitialAd() {
    if (_shouldShowAd) {
      const AdRequest request = AdRequest();
      InterstitialAd.load(
        adUnitId: 'ca-app-pub-3442981380712673/3527294423',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            if (kDebugMode) {
              print('$ad loaded');
            }
            _interstitialAd = ad;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            if (kDebugMode) {
              print('InterstitialAd failed to load: $error.');
            }
            _interstitialAd = null;
          },
        ),
      );
    }
  }

  void showInterstitialAd() {
    if (_shouldShowAd) {
      if (_interstitialAd != null) {
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (InterstitialAd ad) {
            if (kDebugMode) {
              print('ad onAdShowedFullScreenContent.');
            }
          },
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
            if (kDebugMode) {
              print('$ad onAdDismissedFullScreenContent.');
            }
            ad.dispose();
            initializeInterstitialAd();
          },
          onAdFailedToShowFullScreenContent:
              (InterstitialAd ad, AdError error) {
            if (kDebugMode) {
              print('$ad onAdFailedToShowFullScreenContent: $error');
            }
            ad.dispose();
            initializeInterstitialAd();
          },
        );
        _interstitialAd!.show();
        _interstitialAd = null;
      }
    }
  }
}
