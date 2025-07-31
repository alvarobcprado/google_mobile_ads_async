# Architecture and Implementation Plan - Google Mobile Ads Async

## 1. Overview

This document describes the architecture and implementation steps for the `google_mobile_ads_async` package. The main goal is to create a comprehensive wrapper around the `google_mobile_ads` package, transforming its callback-based API into a modern, asynchronous (`Future`-based) API for all ad formats.

In addition to simplifying ad loading, the package will introduce a **pre-loading (cache) manager**, allowing ads to be loaded in the background and displayed instantly when needed, improving user experience and application performance.

**Supported Ad Formats:**
- Banner
- Interstitial
- Rewarded
- Rewarded Interstitial
- Native
- App Open

**The Problem:** The official API requires managing multiple callbacks for each ad type, making the code verbose and complex. Furthermore, there is no integrated solution for ad cache management or for declaratively displaying ads in the widget tree.

**The Solution:**
1.  Abstract the complexity of loading into intuitive, asynchronous method calls (`await GoogleMobileAdsAsync.loadBannerAd(...)`).
2.  Provide an `AdCacheManager` to efficiently preload, store, and retrieve ads.
3.  Offer **UI widgets (wrappers)** for the `Banner` and `Native` formats, which automatically manage the loading lifecycle (displaying `loading` and `error` states) and simplify visual integration.

---

## 2. Core Principles

- **Simplicity:** The public API should be minimal and intuitive.
- **Type Safety:** Use generic and specific Dart types (`Future<BannerAd>`, `Future<InterstitialAd>`) to ensure clarity and safety.
- **Robust Error Handling:** Encapsulate loading failures in clear exceptions (`AdLoadException`).
- **Efficiency:** Allow pre-loading of ads to minimize display latency.
- **Non-Intrusive:** After loading, the developer will have full access to the original ad object from `google_mobile_ads`.

---

## 3. Component Architecture

The architecture will consist of three main components: `AsyncAdLoader`, `AdCacheManager`, and `Ad Wrappers`.

### Component 1: `AsyncAdLoader`

The base layer that converts `google_mobile_ads` callbacks into `Future`s.

- **Responsibility:** Orchestrate the loading process for each ad type.
- **Main Methods:**
  ```dart
  // One method for each ad type
  Future<BannerAd> loadBannerAd(...)
  Future<InterstitialAd> loadInterstitialAd(...)
  Future<RewardedAd> loadRewardedAd(...)
  Future<RewardedInterstitialAd> loadRewardedInterstitialAd(...)
  Future<NativeAd> loadNativeAd(...)
  Future<AppOpenAd> loadAppOpenAd(...)
  ```
- **Internal Logic:** Each method will use a `Completer` to wrap the `onAdLoaded` and `onAdFailedToLoad` logic, returning a `Future` that resolves with the ad or throws an `AdLoadException`.

### Component 2: `AdCacheManager`

A high-level layer for managing the ad lifecycle.

- **Responsibility:** Preload, store, and provide ads.
- **Main Methods:**
  ```dart
  // Starts loading an ad and stores it in the cache
  Future<void> preloadAd(String adUnitId, AdType type, {AdRequest? request});

  // Retrieves a preloaded ad from the cache
  T? getAd<T extends Ad>(String adUnitId);

  // Removes an ad from the cache
  void disposeAd(String adUnitId);
  ```
- **Internal Logic:** It will use a `Map<String, Ad>` to store loaded ads, using the `adUnitId` as the key. It will call `AsyncAdLoader` methods to perform the loading.

### Component 3: Display Widgets (Ad Wrappers)

To simplify the integration of ads directly into the Flutter widget tree, the package provides a UI layer.

- **Responsibility:** Manage the loading and display state of a Banner or Native ad, rendering the corresponding UI. It supports a unified, priority-based flow.
- **Logic:** The widget's constructor accepts both an optional pre-loaded `ad` object and an `adUnitId`.
    1.  **Pre-loaded Ad Priority:** If an `ad` object is provided, it is displayed immediately, and the `adUnitId` is ignored. The widget assumes this ad is managed externally and will not dispose of it.
    2.  **Live Loading Fallback:** If `ad` is `null`, the widget uses the `adUnitId` to load the ad automatically. It will manage the entire lifecycle of this ad, including calling `dispose()` when the widget is removed.
- **Main Components:**
    - **`BannerAdWidget`:** A wrapper for banner ads.
    - **`NativeAdWidget`:** A wrapper for native ads.


### Flow Diagram (Preloading)

```
Developer App      AdCacheManager        AsyncAdLoader         google_mobile_ads
      |                  |                     |                       |
      |-- preloadAd() -->|                     |                       |
      |                  |-- load<AdType>() -->|                       |
      |                  |                     |-- <AdType>.load() --->| (with callbacks)
      |                  |                     |                       |
      |                  |                     |<-- onAdLoaded(ad) ----|
      |                  |<-- Future<Ad> ------|                       |
      |                  |-- (Stores 'ad' in Map)
      |                  |
      | (later)          |
      |                  |
      |-- getAd() ------>|
      |<-- (Returns 'ad' from Map)
      |
```

---

## 4. Implementation Steps

The implementation will be divided into the following steps:

- [x] **Step 1: Project Setup**
  - Ensure the `google_mobile_ads` dependency is up to date.

- [x] **Step 2: Generalize the Exception**
  - Keep `AdLoadException` generic to be used by all loading types.

- [x] **Step 3: Implement `AsyncAdLoader`**
  - Create asynchronous loading methods for each ad type: `loadBannerAd`, `loadInterstitialAd`, `loadRewardedAd`, `loadRewardedInterstitialAd`, `loadNativeAd`, and `loadAppOpenAd`.

- [x] **Step 4: Implement `AdCacheManager`**
  - Create the `AdCacheManager` class with logic to preload, store in a `Map`, and retrieve ads.
  - Ensure correct ad disposal (`dispose`) to prevent memory leaks.

- [X] **Step 5: Develop Display Widgets (Wrappers)**
  - Implement `BannerAdWidget` to display banner ads.
  - Implement `NativeAdWidget` with a `nativeAdBuilder` for custom rendering.
  - Refactor the existing `NativeAdCard` to use `NativeAdWidget` internally.

- [X] **Step 6: API Documentation**
  - Update all documentation comments (`///`) to cover the new expanded API, including the **Ad Wrappers**, `AdCacheManager`, and all new loading methods.

- [X] **Step 7: Create a Comprehensive Usage Example**
  - Update the application in the `example/` folder to demonstrate simple loading, preloading, and the **use of the new `BannerAdWidget` and `NativeAdWidget`**.

- [X] **Step 8: Write Tests**
  - Expand unit tests to cover the `AsyncAdLoader` logic for all ad types.
  - Create specific tests for `AdCacheManager` using `mocktail`.

---

## 5. Usage Example (Final Result)

The goal is to enable simple and advanced workflows.

**Scenario 1: Simple Loading (No Cache)**
```dart
Future<void> showInterstitialAd() async {
  try {
    final ad = await GoogleMobileAdsAsync.loadInterstitialAd(
      adUnitId: 'your_ad_unit_id',
    );
    ad.show();
  } on AdLoadException catch (e) {
    print('Failed to load interstitial ad: $e');
  }
}
```

**Scenario 2: Preloading with `AdCacheManager`**
```dart
// On app or screen initialization
void preLoadAds() {
  AdCacheManager.instance.preloadAd('rewarded_ad_unit', AdType.rewarded);
}

// When the user is about to perform the action to see the ad
void showRewardedAd() {
  final ad = AdCacheManager.instance.getAd<RewardedAd>('rewarded_ad_unit');
  if (ad != null) {
    ad.show(onUserEarnedReward: (ad, reward) {
      print('Reward earned: ${reward.amount} ${reward.type}');
    });
  } else {
    // Optional: Try to load the ad now or show a message
    print('Rewarded ad was not ready.');
  }
}
```

**Scenario 3: UI Integration with Ad Wrappers**
```dart
// In a widget's build() method
@override
Widget build(BuildContext context) {
  // Ad is fetched from a cache or pre-loaded earlier
  final BannerAd? myPreloadedAd = AdCacheManager.instance.getAd('banner_id');

  return Column(
    children: [
      Text('App Content'),

      // Example 1: Using a pre-loaded ad for instant display.
      // The widget will show the ad if `myPreloadedAd` is not null.
      // Otherwise, it will use `adUnitId` to load a new one.
      BannerAdWidget(
        ad: myPreloadedAd,
        adUnitId: 'your_banner_ad_unit_id',
      ),

      // Example 2: Live-loading a native ad.
      NativeAdWidget(
        adUnitId: 'your_native_ad_unit_id',
        nativeAdBuilder: (context, ad) => MyCustomNativeAdView(ad: ad),
        loadingBuilder: (context) => Text('Loading native ad...'),
      ),
    ],
  );
}
```