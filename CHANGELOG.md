## 2.0.0

- Upgraded `google_mobile_ads` to 9.0.0 and `logger` to 2.7.0.
- Raised the minimum toolchain to Dart 3.10.0 and Flutter 3.38.1.
- Raised platform requirements to Android API 23 with compile SDK 35+ and
  Kotlin 2.3, and iOS 13.0.
- Migrated anchored adaptive banners to
  `AdSize.getLargeAnchoredAdaptiveBannerAdSize`.
- Protected asynchronous loaders from duplicate SDK callbacks and explicitly
  handled asynchronous ad disposal.
- Updated the example's Android and iOS configuration, including the iOS test
  App ID.
- Updated development dependencies and expanded loader, banner sizing, and
  widget lifecycle tests.

### Migration from 1.x

- Upgrade the consuming app to the minimum Flutter/Dart versions above.
- Set Android `minSdk` to 23, `compileSdk` to at least 35, and use Kotlin 2.3.
- Set the iOS deployment target to 13.0.
- Confirm the AdMob application ID is configured in both
  `AndroidManifest.xml` and `Info.plist`.
- Expect `BannerAdSizeConfig.anchored` to request a large anchored adaptive
  banner.

## 1.0.0

- Initial stable release.
- Features: Async/await API for all ad formats, ad waterfall support, declarative widgets, and a cache manager.
