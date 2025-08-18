import 'package:flutter/material.dart';
import 'package:google_mobile_ads_async/google_mobile_ads_async.dart';

// Ad Unit IDs for testing. Replace with your own in production.
const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
const String nativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Example Log Configuration ---
  // Set the log level to see detailed messages during debugging.
  // Use Level.verbose for the most detail.
  GoogleMobileAdsAsync.setLogLevel(Level.debug);

  // Initialize the Google Mobile Ads SDK.
  await MobileAds.instance.initialize();
  // Preload ads using the cache manager.
  await _preloadAds();
  runApp(const MyApp());
}

Future<void> _preloadAds() async {
  final cacheManager = AdCacheManager.instance;
  // Preload multiple ads in parallel.
  await Future.wait([
    cacheManager.preloadAd(
      adUnitIds: [interstitialAdUnitId],
      type: AdType.interstitial,
    ),
    cacheManager.preloadAd(
      adUnitIds: [rewardedAdUnitId],
      type: AdType.rewarded,
    ),
    // Preload a banner for the bottom navigation bar.
    cacheManager.preloadAd(
      adUnitIds: [bannerAdUnitId],
      type: AdType.banner,
      size: AdSize.banner,
    ),
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
    // Get the ad from the cache.
    final ad = AdCacheManager.instance.getAd<InterstitialAd>([
      interstitialAdUnitId,
    ]);

    if (ad != null) {
      ad.show();
      // Preload the next one.
      AdCacheManager.instance.preloadAd(
        adUnitIds: [interstitialAdUnitId],
        type: AdType.interstitial,
      );
    } else {
      _showSnackBar('Interstitial ad is not ready yet.');
      // Optionally, load the ad if it wasn't in the cache.
      AdCacheManager.instance.preloadAd(
        adUnitIds: [interstitialAdUnitId],
        type: AdType.interstitial,
      );
    }
  }

  void _showRewardedAd() {
    // Get the ad from the cache.
    final ad = AdCacheManager.instance.getAd<RewardedAd>([rewardedAdUnitId]);

    if (ad != null) {
      ad.show(
        onUserEarnedReward: (ad, reward) {
          _showSnackBar('Reward earned: ${reward.amount} ${reward.type}');
        },
      );
      // Preload the next one.
      AdCacheManager.instance.preloadAd(
        adUnitIds: [rewardedAdUnitId],
        type: AdType.rewarded,
      );
    } else {
      _showSnackBar('Rewarded ad is not ready yet.');
      // Optionally, load the ad if it wasn't in the cache.
      AdCacheManager.instance.preloadAd(
        adUnitIds: [rewardedAdUnitId],
        type: AdType.rewarded,
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Try to get the cached banner ad.
    final cachedBanner =
        AdCacheManager.instance.getAd<BannerAd>([bannerAdUnitId]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Demo'),
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
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
              const SizedBox(height: 40),
              const Text(
                'Widget-Based Ads',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('Native Ad', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              SizedBox(
                height: 380,
                child: NativeAdWidget(
                  // The widget will load the ad using the adUnitIds.
                  adUnitIds: const [nativeAdUnitId],
                  loadingBuilder: (_) => const CircularProgressIndicator(),
                  errorBuilder: (_, error) =>
                      Text('Native ad failed to load: $error'),
                  nativeTemplateStyle: NativeTemplateStyle(
                    templateType: TemplateType.medium,
                    cornerRadius: 12,
                    mainBackgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Banner Ad (in-line)', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              BannerAdWidget(
                adUnitIds: const [bannerAdUnitId],
                size: AdSize.mediumRectangle,
                loadingBuilder: (_) => const CircularProgressIndicator(),
                errorBuilder: (_, error) =>
                    Text('Banner ad failed to load: $error'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // The widget will display the cached ad if available,
      // otherwise it will load a new one using the adUnitId.
      bottomNavigationBar: BannerAdWidget(
        ad: cachedBanner,
        adUnitIds: const [bannerAdUnitId],
        size: AdSize.banner,
        errorBuilder: (_, error) =>
            Text('Bottom banner failed to load: $error'),
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
