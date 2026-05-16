import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class AdsService {
  static const String _gameId = 'YOUR_UNITY_GAME_ID'; // ضع Game ID هنا
  static const String interstitialId = 'Interstitial_Android';
  static const String rewardedId = 'Rewarded_Android';
  static const String bannerId = 'Banner_Android';

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    try {
      await UnityAds.init(
        gameId: _gameId,
        testMode: true, // غيّر إلى false عند النشر الحقيقي
        onComplete: () {
          _isInitialized = true;
          debugPrint('Unity Ads initialized successfully');
          _loadAds();
        },
        onFailed: (error, message) {
          debugPrint('Unity Ads init failed: $error $message');
        },
      );
    } catch (e) {
      debugPrint('Unity Ads error: $e');
    }
  }

  static void _loadAds() {
    UnityAds.load(
      placementId: interstitialId,
      onComplete: (placementId) => debugPrint('Interstitial loaded'),
      onFailed: (placementId, error, message) =>
          debugPrint('Interstitial load failed'),
    );

    UnityAds.load(
      placementId: rewardedId,
      onComplete: (placementId) => debugPrint('Rewarded loaded'),
      onFailed: (placementId, error, message) =>
          debugPrint('Rewarded load failed'),
    );
  }

  static void showInterstitial({VoidCallback? onComplete}) {
    if (!_isInitialized) return;
    UnityAds.showVideoAd(
      placementId: interstitialId,
      onComplete: (placementId) {
        onComplete?.call();
        _loadAds();
      },
      onFailed: (placementId, error, message) {
        debugPrint('Interstitial show failed: $message');
      },
      onStart: (placementId) => debugPrint('Interstitial started'),
      onClick: (placementId) => debugPrint('Interstitial clicked'),
      onSkipped: (placementId) => debugPrint('Interstitial skipped'),
    );
  }

  static void showRewarded({
    VoidCallback? onRewarded,
    VoidCallback? onSkipped,
  }) {
    if (!_isInitialized) return;
    UnityAds.showVideoAd(
      placementId: rewardedId,
      onComplete: (placementId) {
        onRewarded?.call();
        _loadAds();
      },
      onFailed: (placementId, error, message) {
        debugPrint('Rewarded show failed: $message');
      },
      onStart: (placementId) => debugPrint('Rewarded started'),
      onClick: (placementId) => debugPrint('Rewarded clicked'),
      onSkipped: (placementId) {
        onSkipped?.call();
        _loadAds();
      },
    );
  }

  static Widget buildBannerAd() {
    if (!_isInitialized) return const SizedBox.shrink();
    return UnityBannerAd(
      placementId: bannerId,
      onLoad: (placementId) => debugPrint('Banner loaded'),
      onClick: (placementId) => debugPrint('Banner clicked'),
      onFailed: (placementId, error, message) =>
          debugPrint('Banner failed: $message'),
    );
  }
}
