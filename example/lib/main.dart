import 'package:flutter/material.dart';
import 'package:google_mobile_ads_async/google_mobile_ads_async.dart';

// Ad Unit IDs for testing. Replace with your own in production.
const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
const String nativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the Google Mobile Ads SDK.
  await MobileAds.instance.initialize();
  // Preload ads using the cache manager.
  _preloadAds().ignore();
  runApp(const MyApp());
}

Future<void> _preloadAds() async {
  final cacheManager = AdCacheManager.instance;
  Future.wait([
    cacheManager.preloadAd(interstitialAdUnitId, AdType.interstitial),
    cacheManager.preloadAd(rewardedAdUnitId, AdType.rewarded),
    // Preload ads for the widgets too
    cacheManager.preloadAd(bannerAdUnitId, AdType.banner, size: AdSize.banner),
  ]);
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
  // --- Ad Showing Methods ---

  void _showInterstitialAd() {
    final ad =
        AdCacheManager.instance.getAd<InterstitialAd>(interstitialAdUnitId);
    if (ad != null) {
      ad.show();
      // Preload the next one.
      AdCacheManager.instance
          .preloadAd(interstitialAdUnitId, AdType.interstitial);
    } else {
      _showSnackBar('Interstitial ad is not ready yet.');
    }
  }

  void _showRewardedAd() {
    final ad = AdCacheManager.instance.getAd<RewardedAd>(rewardedAdUnitId);
    if (ad != null) {
      ad.show(onUserEarnedReward: (ad, reward) {
        _showSnackBar('Reward earned: ${reward.amount} ${reward.type}');
      });
      // Preload the next one.
      AdCacheManager.instance.preloadAd(rewardedAdUnitId, AdType.rewarded);
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
    // Try to get the cached ads.
    final cachedBanner =
        AdCacheManager.instance.getAd<BannerAd>(bannerAdUnitId);
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
                'Cached Ads (Programmatic)',
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
              const SizedBox(height: 20),
              const Text(
                'Widget-Based Ads',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('Native Ad', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              SizedBox(
                height: 320,
                child: NativeAdWidget(
                  adUnitId: nativeAdUnitId,
                  nativeAdBuilder: (context, ad) => AdWidget(ad: ad),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Banner Ad', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              const BannerAdWidget(
                adUnitId: bannerAdUnitId,
                size: AdSize.mediumRectangle,
              ),
            ],
          ),
        ),
      ),
      // The widget will display the cached ad if available,
      // otherwise it will load a new one using the adUnitId.
      bottomNavigationBar: BannerAdWidget(
        ad: cachedBanner,
        adUnitId: bannerAdUnitId,
        size: AdSize.banner,
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all cached ads when the app is closed.
    AdCacheManager.instance.disposeAllAds();
    super.dispose();
  }
}
