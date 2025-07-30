import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads_async/google_mobile_ads_async.dart';
import 'package:google_mobile_ads_async/src/ad_factory.dart';
import 'package:google_mobile_ads_async/src/ad_loader.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'google_mobile_ads_async_test.mocks.dart';

@GenerateMocks([
  AdFactory,
  AsyncAdLoader,
  BannerAd,
  InterstitialAd,
  RewardedAd,
  LoadAdError,
])
void main() {
  group('AsyncAdLoader', () {
    late MockAdFactory mockAdFactory;
    late AsyncAdLoader adLoader;

    setUp(() {
      mockAdFactory = MockAdFactory();
      adLoader = AsyncAdLoader.withFactory(mockAdFactory);
    });

    // ... (testes do AsyncAdLoader mantidos aqui)
  });

  group('AdCacheManager', () {
    late MockAsyncAdLoader mockAdLoader;
    late AdCacheManager cacheManager;

    setUp(() {
      mockAdLoader = MockAsyncAdLoader();
      cacheManager = AdCacheManager.withLoader(mockAdLoader);
    });

    tearDown(() {
      cacheManager.disposeAllAds();
    });

    test('preloadAd successfully caches an ad', () async {
      final mockAd = MockBannerAd();
      when(mockAdLoader.loadBannerAd(
        adUnitId: 'test-banner',
        size: AdSize.banner,
        request: null,
      )).thenAnswer((_) async => mockAd);

      await cacheManager.preloadAd(
        'test-banner',
        AdType.banner,
        size: AdSize.banner,
      );

      final cachedAd = cacheManager.getAd<BannerAd>('test-banner');
      expect(cachedAd, equals(mockAd));
    });

    test('preloadAd does not cache an ad on failure', () async {
      final mockError = MockLoadAdError();
      when(mockError.message).thenReturn('Failed to load');
      when(mockError.code).thenReturn(1);
      when(mockAdLoader.loadBannerAd(
        adUnitId: 'test-banner-fail',
        size: AdSize.banner,
        request: null,
      )).thenThrow(AdLoadException(mockError));

      await cacheManager.preloadAd(
        'test-banner-fail',
        AdType.banner,
        size: AdSize.banner,
      );

      final cachedAd = cacheManager.getAd<BannerAd>('test-banner-fail');
      expect(cachedAd, isNull);
    });

    test('getAd returns null for wrong ad type', () async {
      final mockAd = MockBannerAd();
      when(mockAdLoader.loadBannerAd(
        adUnitId: 'test-banner',
        size: AdSize.banner,
        request: null,
      )).thenAnswer((_) async => mockAd);

      await cacheManager.preloadAd(
        'test-banner',
        AdType.banner,
        size: AdSize.banner,
      );

      final cachedAd = cacheManager.getAd<InterstitialAd>('test-banner');
      expect(cachedAd, isNull);
    });

    test('disposeAd removes and disposes the ad', () async {
      final mockAd = MockBannerAd();
      when(mockAdLoader.loadBannerAd(
        adUnitId: 'test-banner',
        size: AdSize.banner,
        request: null,
      )).thenAnswer((_) async => mockAd);

      await cacheManager.preloadAd(
        'test-banner',
        AdType.banner,
        size: AdSize.banner,
      );

      cacheManager.disposeAd('test-banner');
      verify(mockAd.dispose()).called(1);
      final cachedAd = cacheManager.getAd<BannerAd>('test-banner');
      expect(cachedAd, isNull);
    });
  });
}
