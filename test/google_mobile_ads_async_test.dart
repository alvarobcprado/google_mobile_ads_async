import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads_async/google_mobile_ads_async.dart';
import 'package:google_mobile_ads_async/src/ad_loader_orchestrator.dart';
import 'package:mocktail/mocktail.dart';

// --- Mock Classes using Mocktail ---

class MockAdLoaderOrchestrator extends Mock implements AdLoaderOrchestrator {}

class MockBannerAd extends Mock implements BannerAd {}

class MockInterstitialAd extends Mock implements InterstitialAd {}

class MockRewardedAd extends Mock implements RewardedAd {}

class MockLoadAdError extends Mock implements LoadAdError {
  @override
  String toString() => 'MockLoadAdError';
}

void main() {
  // Register fallback values for mocktail.
  setUpAll(() {
    registerFallbackValue(const AdRequest());
    registerFallbackValue(AdSize.banner);
    registerFallbackValue(<String>[]);
  });

  group('AdCacheManager with Mocktail', () {
    late MockAdLoaderOrchestrator mockOrchestrator;
    late AdCacheManager cacheManager;

    const adUnitIds = ['test-banner-1', 'test-banner-2'];

    setUp(() {
      mockOrchestrator = MockAdLoaderOrchestrator();
      cacheManager = AdCacheManager.withOrchestrator(mockOrchestrator);
    });

    tearDown(() {
      cacheManager.disposeAllAds();
    });

    test('preloadAd successfully caches an ad using the orchestrator',
        () async {
      // Arrange
      final mockAd = MockBannerAd();
      when(
        () => mockOrchestrator.loadBannerAd(
          adUnitIds: adUnitIds,
          size: AdSize.banner,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      await cacheManager.preloadAd(
        adUnitIds: adUnitIds,
        type: AdType.banner,
        size: AdSize.banner,
      );

      // Assert
      final cachedAd = cacheManager.getAd<BannerAd>(adUnitIds);
      expect(cachedAd, equals(mockAd));
      verify(
        () => mockOrchestrator.loadBannerAd(
          adUnitIds: adUnitIds,
          size: AdSize.banner,
          request: any(named: 'request'),
        ),
      ).called(1);
    });

    test('preloadAd does not cache an ad on failure', () async {
      // Arrange
      final mockLoadAdError = MockLoadAdError();
      when(() => mockLoadAdError.message).thenReturn('Failed to load');
      when(() => mockLoadAdError.code).thenReturn(1);
      final mockError =
          AdWaterfallException([AdLoadException(mockLoadAdError)]);

      when(
        () => mockOrchestrator.loadBannerAd(
          adUnitIds: any(named: 'adUnitIds'),
          size: any(named: 'size'),
          request: any(named: 'request'),
        ),
      ).thenThrow(mockError);

      // Act
      await cacheManager.preloadAd(
        adUnitIds: adUnitIds,
        type: AdType.banner,
        size: AdSize.banner,
      );

      // Assert
      final cachedAd = cacheManager.getAd<BannerAd>(adUnitIds);
      expect(cachedAd, isNull);
    });

    test('getAd returns null for wrong ad type', () async {
      // Arrange
      final mockAd = MockBannerAd();
      when(
        () => mockOrchestrator.loadBannerAd(
          adUnitIds: adUnitIds,
          size: AdSize.banner,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      await cacheManager.preloadAd(
        adUnitIds: adUnitIds,
        type: AdType.banner,
        size: AdSize.banner,
      );

      // Act & Assert
      final cachedAd = cacheManager.getAd<InterstitialAd>(adUnitIds);
      expect(cachedAd, isNull);
    });

    test('disposeAd removes and disposes the ad', () async {
      // Arrange
      final mockAd = MockBannerAd();
      when(mockAd.dispose).thenAnswer((_) async {});
      when(
        () => mockOrchestrator.loadBannerAd(
          adUnitIds: adUnitIds,
          size: AdSize.banner,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      await cacheManager.preloadAd(
        adUnitIds: adUnitIds,
        type: AdType.banner,
        size: AdSize.banner,
      );

      // Act
      cacheManager.disposeAd(adUnitIds);

      // Assert
      verify(mockAd.dispose).called(1);
      final cachedAd = cacheManager.getAd<BannerAd>(adUnitIds);
      expect(cachedAd, isNull);
    });

    test('disposeAllAds clears the cache and disposes all ads', () async {
      // Arrange
      final mockAd1 = MockBannerAd();
      final mockAd2 = MockInterstitialAd();
      when(mockAd1.dispose).thenAnswer((_) async {});
      when(mockAd2.dispose).thenAnswer((_) async {});

      when(
        () => mockOrchestrator.loadBannerAd(
          adUnitIds: ['id1'],
          size: AdSize.banner,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd1);
      when(
        () => mockOrchestrator.loadInterstitialAd(
          adUnitIds: ['id2'],
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd2);

      await cacheManager.preloadAd(
        adUnitIds: ['id1'],
        type: AdType.banner,
        size: AdSize.banner,
      );
      await cacheManager.preloadAd(
        adUnitIds: ['id2'],
        type: AdType.interstitial,
      );

      // Act
      cacheManager.disposeAllAds();

      // Assert
      verify(mockAd1.dispose).called(1);
      verify(mockAd2.dispose).called(1);
      expect(cacheManager.getAd<BannerAd>(['id1']), isNull);
      expect(cacheManager.getAd<InterstitialAd>(['id2']), isNull);
    });
  });
}
