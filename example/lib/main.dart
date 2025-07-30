import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads_async/google_mobile_ads_async.dart';

// Ad Unit IDs for testing. Replace with your own in production.
const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
const String nativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the Google Mobile Ads SDK.
  MobileAds.instance.initialize();
  // Preload ads using the cache manager.
  _preloadAds();
  runApp(const MyApp());
}

void _preloadAds() {
  final cacheManager = AdCacheManager.instance;
  cacheManager.preloadAd(interstitialAdUnitId, AdType.interstitial);
  cacheManager.preloadAd(rewardedAdUnitId, AdType.rewarded);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Mobile Ads Async Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(250, 50),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BannerAd? _bannerAd;
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadNativeAd();
  }

  // --- Ad Loading Methods ---

  void _loadBannerAd() async {
    try {
      final ad = await GoogleMobileAdsAsync.loadBannerAd(
        adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ID
        size: AdSize.banner,
      );
      setState(() {
        _bannerAd = ad;
      });
    } on AdLoadException catch (e) {
      debugPrint('Failed to load banner ad: $e');
    }
  }

  void _loadNativeAd() async {
    try {
      final ad = await GoogleMobileAdsAsync.loadNativeAd(
        adUnitId: nativeAdUnitId,
      );
      setState(() {
        _nativeAd = ad;
        _isNativeAdLoaded = true;
      });
    } on AdLoadException catch (e) {
      debugPrint('Failed to load native ad: $e');
    }
  }

  // --- Ad Showing Methods ---

  void _showInterstitialAd() {
    final ad = AdCacheManager.instance.getAd<InterstitialAd>(interstitialAdUnitId);
    if (ad != null) {
      ad.show();
      // Preload the next one.
      _preloadAds();
    } else {
      _showSnackBar('Interstitial ad is not ready yet.');
      // Optionally, try to load it now.
    }
  }

  void _showRewardedAd() {
    final ad = AdCacheManager.instance.getAd<RewardedAd>(rewardedAdUnitId);
    if (ad != null) {
      ad.show(onUserEarnedReward: (ad, reward) {
        _showSnackBar('Reward earned: ${reward.amount} ${reward.type}');
      });
      // Preload the next one.
      _preloadAds();
    } else {
      _showSnackBar('Rewarded ad is not ready yet.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Demo'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Cached Ads',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showInterstitialAd,
                child: const Text('Show Interstitial Ad'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showRewardedAd,
                child: const Text('Show Rewarded Ad'),
              ),
              const SizedBox(height: 40),
              const Text(
                'Live-Loaded Ads',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (_isNativeAdLoaded && _nativeAd != null)
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: NativeAdCard(nativeAd: _nativeAd!),
                )
              else
                const SizedBox(
                  height: 250,
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bannerAd != null
          ? SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : const SizedBox(height: 50),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _nativeAd?.dispose();
    // Dispose all cached ads when the app is closed.
    AdCacheManager.instance.disposeAllAds();
    super.dispose();
  }
}
