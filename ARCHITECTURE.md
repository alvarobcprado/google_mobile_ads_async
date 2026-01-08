# Architecture and Implementation Plan - Google Mobile Ads Async

## 1. Overview

This document describes the architecture and implementation steps for the `google_mobile_ads_async` package. The main goal is to create a comprehensive wrapper around the `google_mobile_ads` package, transforming its callback-based API into a modern, asynchronous (`Future`-based) API for all ad formats.

In addition to simplifying ad loading, the package will introduce a **pre-loading (cache) manager**, allowing ads to be loaded in the background and displayed instantly when needed, improving user experience and application performance.

A key feature is the support for **ad waterfalls**, allowing developers to provide a list of ad unit IDs. The system will try to load them in sequence, using the first one that successfully returns an ad, thus maximizing fill rates.

**Supported Ad Formats:**
- Banner
- Interstitial
- Rewarded
- Rewarded Interstitial
- Native
- App Open

**The Problem:** The official API requires managing multiple callbacks for each ad type, making the code verbose and complex. Furthermore, there is no integrated solution for ad cache management, declarative UI widgets, or waterfall loading.

**The Solution:**
1.  Abstract the complexity of loading into intuitive, asynchronous method calls (`await GoogleMobileAdsAsync.loadBannerAd(...)`).
2.  Provide an `AdCacheManager` to efficiently preload, store, and retrieve ads.
3.  Offer **UI widgets (wrappers)** for the `Banner` and `Native` formats, which automatically manage the loading lifecycle.
4.  Implement a robust, decoupled **waterfall (cascading) load** mechanism.

---

## 2. Core Principles

- **Simplicity:** The public API should be minimal and intuitive.
- **Robustness:** The system should handle loading failures gracefully, especially in a waterfall context.
- **Decoupling:** Logic for single ad loading should be separate from waterfall orchestration logic.
- **Type Safety:** Use generic and specific Dart types to ensure clarity and safety.
- **Robust Error Handling:** Encapsulate loading failures in clear exceptions (`AdLoadException`, `AdWaterfallException`).
- **Efficiency:** Allow pre-loading of ads to minimize display latency.
- **Non-Intrusive:** After loading, the developer will have full access to the original ad object from `google_mobile_ads`.

---

## 3. Component Architecture

The architecture is designed for clarity and testability, with clear separation of concerns.

### Component 1: `AsyncAdLoader` (The Worker)

The foundational layer responsible for loading a **single ad unit**.

- **Responsibility:** Convert the callback-based API of `google_mobile_ads` into a `Future` for a single `adUnitId`. It knows nothing about waterfalls.
- **Internal Logic:** Uses an `AdFactory` to instantiate the ad object (for testability) and a `Completer` to wrap the `onAdLoaded` and `onAdFailedToLoad` callbacks.

### Component 2: `AdLoaderOrchestrator` (The Manager)

The orchestration layer that manages the loading process, including waterfalls.

- **Responsibility:**
    - Receive a request with either a single `adUnitId` or a list of `adUnitIds`.
    - If it's a list (waterfall), iterate through the IDs, calling `AsyncAdLoader` for each one until a load is successful.
    - If all IDs in a waterfall fail, throw a specific `AdWaterfallException`.
- **Decoupling:** This component contains all the waterfall logic, completely decoupling it from the `AsyncAdLoader`. It acts as a manager, delegating the actual loading work to the `AsyncAdLoader`.

### Component 3: `AdFactory`

A factory class that abstracts the instantiation of ad objects.

- **Responsibility:** Wrap the static ad loading methods from the `google_mobile_ads` package.
- **Purpose:** Its primary goal is **testability**, allowing `AsyncAdLoader` to be tested with a mock `AdFactory`.

### Component 4: `AdCacheManager`

A high-level layer for managing the ad lifecycle.

- **Responsibility:** Preload, store, and provide ads, now with waterfall support.
- **Internal Logic:** It uses the `AdLoaderOrchestrator` to load ads. When a waterfall is used, the ad is cached using the specific `adUnitId` that succeeded.

### Component 5: Display Widgets (Ad Wrappers)

UI components for easy integration into the widget tree.

- **Responsibility:** Manage the loading and display state of a Banner or Native ad, now with waterfall support.
- **Logic:** The widgets accept either a single `adUnitId` or a list of `adUnitIds` and use the `AdLoaderOrchestrator` to handle the loading process, displaying the correct UI for loading, error, or success states.
- **Adaptive Banners:** The `BannerAdWidget` now supports adaptive banners (inline and anchored) through the `BannerAdSizeConfig` class, allowing dynamic sizing based on available width, padding, and optional maximum height.

### Flow Diagram (Waterfall Loading)

```
+------------------+      +--------------------------+      +---------------------+
|   Public API     |----->|   AdLoaderOrchestrator   |----->|    AsyncAdLoader    |
| (GoogleMobileAds |      | (Manages waterfall logic)|      | (Loads one adUnitId)|
|  Async, Widgets) |      +--------------------------+      +----------+----------+
+------------------+                                                   |
                                                                       | uses
                                                                       v
                                                              +----------+----------+
                                                              |      AdFactory      |
                                                              | (For testability)   |
                                                              +---------------------+
```

### Global Ad Control

The package provides a global ad control mechanism through the `isAdsEnabled` static flag on the `GoogleMobileAdsAsync` facade.

**Location:** `GoogleMobileAdsAsync.isAdsEnabled` (default: `true`)

**Flow:**
1. User sets `GoogleMobileAdsAsync.isAdsEnabled = false`
2. Any ad loading request (via facade, widgets, or cache manager) goes to `AdLoaderOrchestrator`
3. The `_loadAdWithWaterfall` method checks the flag before attempting any loads
4. If disabled: throw `AdLoadException` immediately (no network calls, no SDK overhead)
5. If enabled: proceed with normal waterfall loading logic

**Benefits:**
- **Single Point of Control:** One flag controls all ad loading across the entire package
- **Early Bailout:** Check happens before waterfall iteration, minimizing overhead
- **Automatic Propagation:** All components (`AdCacheManager`, widgets) automatically respect the flag
- **Type-Safe:** Uses existing exception infrastructure (`AdLoadException`)

**Use Cases:**
- Premium user ad-free experience
- GDPR/COPPA compliance
- Development/testing environments
- A/B testing monetization strategies

---

## 4. Implementation Steps (TDD Approach)

The implementation will follow a Test-Driven Development cycle.

- [X] **Step 1: Update Architecture Document**
  - The `ARCHITECTURE.md` is updated to reflect the new, simplified waterfall design.

- [X] **Step 2: Write Failing Tests for `AdLoaderOrchestrator`**
  - Create a new test file for the orchestrator.
  - Write tests that cover:
    - Loading with a single `adUnitId`.
    - Waterfall: Success on the first ID.
    - Waterfall: Success on a fallback ID.
    - Waterfall: Failure of all IDs, throwing `AdWaterfallException`.
  - These tests will fail because the implementation doesn't exist yet.

- [X] **Step 3: Implement `AdLoaderOrchestrator` and `AdWaterfallException`**
  - Create the `AdWaterfallException` class.
  - Create the `AdLoaderOrchestrator` class with the waterfall logic.
  - Run the tests from Step 2 until they all pass.

- [X] **Step 4: Refactor and Integrate**
  - Update the `GoogleMobileAdsAsync` facade to use the new `AdLoaderOrchestrator`.
  - Update `AdCacheManager` and the UI Widgets (`BannerAdWidget`, `NativeAdWidget`) to accept `adUnitIds` and pass them to the facade.
  - Write/update tests for the cache manager and widgets to ensure they handle the waterfall parameters correctly.

- [X] **Step 5: Documentation and Example**
  - Update all API documentation (`///`) for the new parameters.
  - Update the `example/` app to demonstrate the waterfall feature.

---

## 5. Usage Example (Final Result)

**Scenario 1: Loading a Single Ad**
```dart
final ad = await GoogleMobileAdsAsync.loadInterstitialAd(
  adUnitIds: ['your_ad_unit_id'],
);
```

**Scenario 2: Waterfall Loading**
```dart
try {
  final ad = await GoogleMobileAdsAsync.loadRewardedAd(
    adUnitIds: ['id_1_best_cpm', 'id_2_medium_cpm', 'id_3_fallback'],
  );
  ad.show(...);
} on AdWaterfallException catch (e) {
  print('Ad waterfall failed. All ad units failed to load.');
  print('Individual errors: ${e.allErrors}');
}
```

**Scenario 3: UI Widget with Standard Banner**
```dart
BannerAdWidget(
  adUnitIds: ['banner_main', 'banner_fallback'],
  sizeConfig: BannerAdSizeConfig.standard(AdSize.banner),
  loadingBuilder: (context) => CircularProgressIndicator(),
  errorBuilder: (context, error) => Text('Failed to load banner: $error'),
)
```

**Scenario 4: UI Widget with Inline Adaptive Banner**
```dart
BannerAdWidget(
  adUnitIds: ['inline_banner_main', 'inline_banner_fallback'],
  sizeConfig: BannerAdSizeConfig.inline(
    padding: EdgeInsets.symmetric(horizontal: 16),
  ),
  loadingBuilder: (context) => CircularProgressIndicator(),
  errorBuilder: (context, error) => Text('Failed to load inline banner: $error'),
)
```

**Scenario 5: UI Widget with Anchored Adaptive Banner**
```dart
BannerAdWidget(
  adUnitIds: ['anchored_banner_main', 'anchored_banner_fallback'],
  sizeConfig: BannerAdSizeConfig.anchored(
    padding: EdgeInsets.symmetric(horizontal: 16),
  ),
  loadingBuilder: (context) => CircularProgressIndicator(),
  errorBuilder: (context, error) => Text('Failed to load anchored banner: $error'),
)
```