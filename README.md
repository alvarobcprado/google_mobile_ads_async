# Google Mobile Ads Async

**Disclaimer:** This package was developed with the assistance of Google's Gemini AI.

[![pub version](https://img.shields.io/pub/v/google_mobile_ads_async.svg)](https://pub.dev/packages/google_mobile_ads_async)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A powerful, async-first wrapper for the official `google_mobile_ads` package. Load ads with `Future`s, implement ad waterfalls, use declarative widgets, and leverage a built-in cache to improve performance and user experience.

## Overview

The official `google_mobile_ads` package provides a robust foundation for displaying ads, but its callback-based API can lead to verbose and complex code. Furthermore, it lacks out-of-the-box support for common monetization strategies like ad waterfalls or a declarative caching mechanism.

`google_mobile_ads_async` solves these problems by:
1.  **Simplifying Ad Loading:** Transforming the callback-based API into an intuitive, `Future`-based one.
2.  **Introducing Ad Waterfalls:** Maximizing fill rates by attempting to load ads from a list of ad unit IDs in sequence.
3.  **Providing a Cache Manager:** Allowing you to preload ads and display them instantly when needed.
4.  **Offering Declarative UI Widgets:** Integrating Banner and Native ads directly into your widget tree, with the library handling the loading lifecycle.

## Key Features

- **Modern Async API:** Load all ad formats (`Banner`, `Interstitial`, `Rewarded`, etc.) using `async/await`.
- **Ad Waterfalls:** Provide a list of ad unit IDs to maximize fill rates. The first ad to load successfully is used.
- **Ad Caching:** Use the `AdCacheManager` to preload ads and reduce latency.
- **Declarative UI Widgets:** Use `BannerAdWidget` and `NativeAdWidget` to display ads declaratively.
- **Robust Error Handling:** Get clear, specific exceptions like `AdLoadException` and `AdWaterfallException`.
- **Full Access to Ad Objects:** Once an ad is loaded, you get the original ad object from `google_mobile_ads` for full control.

## Getting Started

### 1. Prerequisites

This package is a wrapper and depends on the official `google_mobile_ads` package. **You must complete all the platform setup steps (iOS and Android) for that package first.**

This includes updating your `Info.plist` and `AndroidManifest.xml`.

➡️ **Follow the official `google_mobile_ads` installation guide:** [pub.dev/packages/google_mobile_ads](https://pub.dev/packages/google_mobile_ads)

### 2. Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  google_mobile_ads_async: ^latest_version # Use the latest version from pub.dev
```

Then, run `flutter pub get`.

## Usage

### 1. Initialization

Initialize the `google_mobile_ads` SDK when your app starts. This only needs to be done once.

```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(MyApp());
}
```

### 2. Loading a Single Ad (Interstitial)

Load any ad with a single `await` call. The API uses a list of ad unit IDs, even for a single ad.

```dart
import 'package:google_mobile_ads_async/google_mobile_ads_async.dart';

try {
  final interstitialAd = await GoogleMobileAdsAsync.loadInterstitialAd(
    adUnitIds: ['your-interstitial-ad-unit-id'],
  );
  // The ad is ready to be shown.
  interstitialAd.show();
} on AdWaterfallException catch (e) {
  // This is thrown when the ad fails to load.
  print('Failed to load interstitial ad: ${e.message}');
}
```

### 3. Using Ad Waterfalls

Provide a list of ad unit IDs. The system will try each one in order until an ad is successfully loaded. This is great for maximizing revenue.

```dart
try {
  final rewardedAd = await GoogleMobileAdsAsync.loadRewardedAd(
    adUnitIds: [
      'id_1_high_cpm',
      'id_2_medium_cpm',
      'id_3_fallback',
    ],
  );
  rewardedAd.show(...);
} on AdWaterfallException catch (e) {
  // This is thrown when all ad units in the waterfall fail to load.
  print('Ad waterfall failed: ${e.message}');
  print('Individual errors: ${e.allErrors}');
}
```

### 4. Using UI Widgets with Waterfalls

The `BannerAdWidget` handles the loading lifecycle for you. Just provide the ad unit IDs and optional builders for the loading and error states. The ad is displayed automatically on success.

```dart
BannerAdWidget(
  adUnitIds: ['banner_main_id', 'banner_fallback_id'],
  size: AdSize.banner,
  loadingBuilder: (context) => Center(child: CircularProgressIndicator()),
  errorBuilder: (context, error) => Center(child: Text('Failed to load banner: $error')),
)
```

### 5. Pre-loading Ads with AdCacheManager

Preload ads to have them ready for instant display. This is ideal for placements like rewarded ads that a user might trigger on demand.

```dart
// 1. Pre-load the ad, for example, on the main menu.
final cacheManager = AdCacheManager();
cacheManager.preloadAd(
  adUnitIds: ['rewarded_main', 'rewarded_fallback'],
  format: AdFormat.rewarded,
);

// 2. When needed, get the ad from the cache.
final rewardedAd = await cacheManager.getAd(
  adUnitIds: ['rewarded_main', 'rewarded_fallback'],
  format: AdFormat.rewarded,
);

if (rewardedAd != null) {
  rewardedAd.show(...);
} else {
  // Ad wasn't ready or failed to load.
}
```

## Error Handling

- `AdLoadException`: Thrown when a single ad unit fails to load for a specific reason (e.g., network error, no fill).
- `AdWaterfallException`: Thrown when all ad unit IDs in a waterfall list fail to load. It contains a list of the individual errors.

## Additional Information

- **File Issues:** For any bugs or feature requests, please file an issue on our [GitHub repository](https://github.com/alvarobcprado/google_mobile_ads_async/issues).
- **Architecture:** For a deep dive into the internal design of this package, see the [ARCHITECTURE.md](https://github.com/alvarobcprado/google_mobile_ads_async/blob/main/ARCHITECTURE.md) file.
- **Contribute:** Contributions are welcome! Please open a pull request.