import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads_async/google_mobile_ads_async.dart';
import 'package:google_mobile_ads_async/src/ad_loader_orchestrator.dart';
import 'package:google_mobile_ads_async/src/async_ad_loader.dart';
import 'package:mocktail/mocktail.dart';

// --- Mock Classes ---

class MockAsyncAdLoader extends Mock implements AsyncAdLoader {}

class MockBannerAd extends Mock implements BannerAd {}

class MockInterstitialAd extends Mock implements InterstitialAd {}

class MockRewardedAd extends Mock implements RewardedAd {}

class MockRewardedInterstitialAd extends Mock
    implements RewardedInterstitialAd {}

class MockNativeAd extends Mock implements NativeAd {}

class MockAppOpenAd extends Mock implements AppOpenAd {}

class MockLoadAdError extends Mock implements LoadAdError {
  @override
  String toString() => 'MockLoadAdError';
}

void main() {
  // --- Test Setup ---

  late AdLoaderOrchestrator orchestrator;
  late MockAsyncAdLoader mockAdLoader;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(const AdRequest());
    registerFallbackValue(AdSize.banner);
  });

  setUp(() {
    mockAdLoader = MockAsyncAdLoader();
    // Inject the mock loader into the orchestrator
    orchestrator = AdLoaderOrchestrator.withLoader(mockAdLoader);
  });

  // --- Common Variables ---
  const adUnitId1 = 'id-1';
  const adUnitId2 = 'id-2';

  final mockError1 = AdLoadException(MockLoadAdError());
  final mockError2 = AdLoadException(MockLoadAdError());

  // --- Test Groups ---

  group('AdLoaderOrchestrator: BannerAd', () {
    final mockAd = MockBannerAd();

    test('loadBannerAd with a single adUnitId succeeds', () async {
      // Arrange
      when(
        () => mockAdLoader.loadBannerAd(
          adUnitId: adUnitId1,
          size: any(named: 'size'),
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad = await orchestrator.loadBannerAd(
        adUnitIds: [adUnitId1], // Now a list with one item
        size: AdSize.banner,
      );

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadBannerAd(
          adUnitId: adUnitId1,
          size: any(named: 'size'),
          request: any(named: 'request'),
        ),
      ).called(1);
    });

    test('loadBannerAd with waterfall succeeds on the first adUnitId',
        () async {
      // Arrange
      when(
        () => mockAdLoader.loadBannerAd(
          adUnitId: adUnitId1,
          size: any(named: 'size'),
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad = await orchestrator.loadBannerAd(
        adUnitIds: [adUnitId1, adUnitId2],
        size: AdSize.banner,
      );

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadBannerAd(
          adUnitId: adUnitId1,
          size: any(named: 'size'),
          request: any(named: 'request'),
        ),
      ).called(1);
      verifyNever(
        () => mockAdLoader.loadBannerAd(
          adUnitId: adUnitId2,
          size: any(named: 'size'),
          request: any(named: 'request'),
        ),
      );
    });

    test('loadBannerAd with waterfall succeeds on the fallback adUnitId',
        () async {
      // Arrange
      when(
        () => mockAdLoader.loadBannerAd(
          adUnitId: adUnitId1,
          size: any(named: 'size'),
          request: any(named: 'request'),
        ),
      ).thenThrow(mockError1);
      when(
        () => mockAdLoader.loadBannerAd(
          adUnitId: adUnitId2,
          size: any(named: 'size'),
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad = await orchestrator.loadBannerAd(
        adUnitIds: [adUnitId1, adUnitId2],
        size: AdSize.banner,
      );

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadBannerAd(
          adUnitId: adUnitId1,
          size: any(named: 'size'),
          request: any(named: 'request'),
        ),
      ).called(1);
      verify(
        () => mockAdLoader.loadBannerAd(
          adUnitId: adUnitId2,
          size: any(named: 'size'),
          request: any(named: 'request'),
        ),
      ).called(1);
    });

    test(
        'loadBannerAd with waterfall throws AdWaterfallException if '
        'all adUnitIds fail', () async {
      // Arrange
      when(
        () => mockAdLoader.loadBannerAd(
          adUnitId: adUnitId1,
          size: any(named: 'size'),
          request: any(named: 'request'),
        ),
      ).thenThrow(mockError1);
      when(
        () => mockAdLoader.loadBannerAd(
          adUnitId: adUnitId2,
          size: any(named: 'size'),
          request: any(named: 'request'),
        ),
      ).thenThrow(mockError2);

      // Act & Assert
      final call = orchestrator.loadBannerAd(
        adUnitIds: [adUnitId1, adUnitId2],
        size: AdSize.banner,
      );

      expect(
        call,
        throwsA(
          isA<AdWaterfallException>().having(
            (e) => e.allErrors,
            'allErrors',
            [mockError1, mockError2],
          ),
        ),
      );
    });
  });

  group('AdLoaderOrchestrator: InterstitialAd', () {
    final mockAd = MockInterstitialAd();

    test('loadInterstitialAd with a single adUnitId succeeds', () async {
      // Arrange
      when(
        () => mockAdLoader.loadInterstitialAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad = await orchestrator.loadInterstitialAd(adUnitIds: [adUnitId1]);

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadInterstitialAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).called(1);
    });

    test('loadInterstitialAd with waterfall succeeds on the first adUnitId',
        () async {
      // Arrange
      when(
        () => mockAdLoader.loadInterstitialAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad = await orchestrator
          .loadInterstitialAd(adUnitIds: [adUnitId1, adUnitId2]);

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadInterstitialAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).called(1);
      verifyNever(
        () => mockAdLoader.loadInterstitialAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
        ),
      );
    });

    test('loadInterstitialAd with waterfall succeeds on the fallback adUnitId',
        () async {
      // Arrange
      when(
        () => mockAdLoader.loadInterstitialAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).thenThrow(mockError1);
      when(
        () => mockAdLoader.loadInterstitialAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad = await orchestrator
          .loadInterstitialAd(adUnitIds: [adUnitId1, adUnitId2]);

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadInterstitialAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).called(1);
      verify(
        () => mockAdLoader.loadInterstitialAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
        ),
      ).called(1);
    });

    test(
        'loadInterstitialAd with waterfall throws AdWaterfallException '
        'if all adUnitIds fail', () async {
      // Arrange
      when(
        () => mockAdLoader.loadInterstitialAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).thenThrow(mockError1);
      when(
        () => mockAdLoader.loadInterstitialAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
        ),
      ).thenThrow(mockError2);

      // Act & Assert
      final call =
          orchestrator.loadInterstitialAd(adUnitIds: [adUnitId1, adUnitId2]);

      expect(
        call,
        throwsA(
          isA<AdWaterfallException>().having(
            (e) => e.allErrors,
            'allErrors',
            [mockError1, mockError2],
          ),
        ),
      );
    });
  });

  group('AdLoaderOrchestrator: RewardedAd', () {
    final mockAd = MockRewardedAd();

    test('loadRewardedAd with a single adUnitId succeeds', () async {
      // Arrange
      when(
        () => mockAdLoader.loadRewardedAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad = await orchestrator.loadRewardedAd(adUnitIds: [adUnitId1]);

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadRewardedAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).called(1);
    });

    test('loadRewardedAd with waterfall succeeds on the first adUnitId',
        () async {
      // Arrange
      when(
        () => mockAdLoader.loadRewardedAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad =
          await orchestrator.loadRewardedAd(adUnitIds: [adUnitId1, adUnitId2]);

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadRewardedAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).called(1);
      verifyNever(
        () => mockAdLoader.loadRewardedAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
        ),
      );
    });

    test('loadRewardedAd with waterfall succeeds on the fallback adUnitId',
        () async {
      // Arrange
      when(
        () => mockAdLoader.loadRewardedAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).thenThrow(mockError1);
      when(
        () => mockAdLoader.loadRewardedAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad =
          await orchestrator.loadRewardedAd(adUnitIds: [adUnitId1, adUnitId2]);

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadRewardedAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).called(1);
      verify(
        () => mockAdLoader.loadRewardedAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
        ),
      ).called(1);
    });

    test(
        'loadRewardedAd with waterfall throws AdWaterfallException '
        'if all adUnitIds fail', () async {
      // Arrange
      when(
        () => mockAdLoader.loadRewardedAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).thenThrow(mockError1);
      when(
        () => mockAdLoader.loadRewardedAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
        ),
      ).thenThrow(mockError2);

      // Act & Assert
      final call =
          orchestrator.loadRewardedAd(adUnitIds: [adUnitId1, adUnitId2]);

      expect(
        call,
        throwsA(
          isA<AdWaterfallException>().having(
            (e) => e.allErrors,
            'allErrors',
            [mockError1, mockError2],
          ),
        ),
      );
    });
  });

  group('AdLoaderOrchestrator: RewardedInterstitialAd', () {
    final mockAd = MockRewardedInterstitialAd();

    test('loadRewardedInterstitialAd with a single adUnitId succeeds',
        () async {
      // Arrange
      when(
        () => mockAdLoader.loadRewardedInterstitialAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad =
          await orchestrator.loadRewardedInterstitialAd(adUnitIds: [adUnitId1]);

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadRewardedInterstitialAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).called(1);
    });

    test(
        'loadRewardedInterstitialAd with waterfall succeeds on the '
        'first adUnitId', () async {
      // Arrange
      when(
        () => mockAdLoader.loadRewardedInterstitialAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad = await orchestrator
          .loadRewardedInterstitialAd(adUnitIds: [adUnitId1, adUnitId2]);

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadRewardedInterstitialAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).called(1);
      verifyNever(
        () => mockAdLoader.loadRewardedInterstitialAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
        ),
      );
    });

    test(
        'loadRewardedInterstitialAd with waterfall succeeds on the '
        'fallback adUnitId', () async {
      // Arrange
      when(
        () => mockAdLoader.loadRewardedInterstitialAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).thenThrow(mockError1);
      when(
        () => mockAdLoader.loadRewardedInterstitialAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad = await orchestrator
          .loadRewardedInterstitialAd(adUnitIds: [adUnitId1, adUnitId2]);

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadRewardedInterstitialAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).called(1);
      verify(
        () => mockAdLoader.loadRewardedInterstitialAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
        ),
      ).called(1);
    });

    test(
        'loadRewardedInterstitialAd with waterfall throws '
        'AdWaterfallException if all adUnitIds fail', () async {
      // Arrange
      when(
        () => mockAdLoader.loadRewardedInterstitialAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).thenThrow(mockError1);
      when(
        () => mockAdLoader.loadRewardedInterstitialAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
        ),
      ).thenThrow(mockError2);

      // Act & Assert
      final call = orchestrator
          .loadRewardedInterstitialAd(adUnitIds: [adUnitId1, adUnitId2]);

      expect(
        call,
        throwsA(
          isA<AdWaterfallException>().having(
            (e) => e.allErrors,
            'allErrors',
            [mockError1, mockError2],
          ),
        ),
      );
    });
  });

  group('AdLoaderOrchestrator: NativeAd', () {
    final mockAd = MockNativeAd();

    test('loadNativeAd with a single adUnitId succeeds', () async {
      // Arrange
      when(
        () => mockAdLoader.loadNativeAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
          nativeAdOptions: any(named: 'nativeAdOptions'),
          factoryId: any(named: 'factoryId'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad = await orchestrator.loadNativeAd(adUnitIds: [adUnitId1]);

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadNativeAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
          nativeAdOptions: any(named: 'nativeAdOptions'),
          factoryId: any(named: 'factoryId'),
        ),
      ).called(1);
    });

    test('loadNativeAd with waterfall succeeds on the first adUnitId',
        () async {
      // Arrange
      when(
        () => mockAdLoader.loadNativeAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
          nativeAdOptions: any(named: 'nativeAdOptions'),
          factoryId: any(named: 'factoryId'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad =
          await orchestrator.loadNativeAd(adUnitIds: [adUnitId1, adUnitId2]);

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadNativeAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
          nativeAdOptions: any(named: 'nativeAdOptions'),
          factoryId: any(named: 'factoryId'),
        ),
      ).called(1);
      verifyNever(
        () => mockAdLoader.loadNativeAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
          nativeAdOptions: any(named: 'nativeAdOptions'),
          factoryId: any(named: 'factoryId'),
        ),
      );
    });

    test('loadNativeAd with waterfall succeeds on the fallback adUnitId',
        () async {
      // Arrange
      when(
        () => mockAdLoader.loadNativeAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
          nativeAdOptions: any(named: 'nativeAdOptions'),
          factoryId: any(named: 'factoryId'),
        ),
      ).thenThrow(mockError1);
      when(
        () => mockAdLoader.loadNativeAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
          nativeAdOptions: any(named: 'nativeAdOptions'),
          factoryId: any(named: 'factoryId'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad =
          await orchestrator.loadNativeAd(adUnitIds: [adUnitId1, adUnitId2]);

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadNativeAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
          nativeAdOptions: any(named: 'nativeAdOptions'),
          factoryId: any(named: 'factoryId'),
        ),
      ).called(1);
      verify(
        () => mockAdLoader.loadNativeAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
          nativeAdOptions: any(named: 'nativeAdOptions'),
          factoryId: any(named: 'factoryId'),
        ),
      ).called(1);
    });

    test(
        'loadNativeAd with waterfall throws AdWaterfallException if all'
        ' adUnitIds fail', () async {
      // Arrange
      when(
        () => mockAdLoader.loadNativeAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
          nativeAdOptions: any(named: 'nativeAdOptions'),
          factoryId: any(named: 'factoryId'),
        ),
      ).thenThrow(mockError1);
      when(
        () => mockAdLoader.loadNativeAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
          nativeAdOptions: any(named: 'nativeAdOptions'),
          factoryId: any(named: 'factoryId'),
        ),
      ).thenThrow(mockError2);

      // Act & Assert
      final call = orchestrator.loadNativeAd(adUnitIds: [adUnitId1, adUnitId2]);

      expect(
        call,
        throwsA(
          isA<AdWaterfallException>().having(
            (e) => e.allErrors,
            'allErrors',
            [mockError1, mockError2],
          ),
        ),
      );
    });
  });

  group('AdLoaderOrchestrator: AppOpenAd', () {
    final mockAd = MockAppOpenAd();

    test('loadAppOpenAd with a single adUnitId succeeds', () async {
      // Arrange
      when(
        () => mockAdLoader.loadAppOpenAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad = await orchestrator.loadAppOpenAd(adUnitIds: [adUnitId1]);

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadAppOpenAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).called(1);
    });

    test('loadAppOpenAd with waterfall succeeds on the first adUnitId',
        () async {
      // Arrange
      when(
        () => mockAdLoader.loadAppOpenAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad =
          await orchestrator.loadAppOpenAd(adUnitIds: [adUnitId1, adUnitId2]);

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadAppOpenAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).called(1);
      verifyNever(
        () => mockAdLoader.loadAppOpenAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
        ),
      );
    });

    test('loadAppOpenAd with waterfall succeeds on the fallback adUnitId',
        () async {
      // Arrange
      when(
        () => mockAdLoader.loadAppOpenAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).thenThrow(mockError1);
      when(
        () => mockAdLoader.loadAppOpenAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      // Act
      final ad =
          await orchestrator.loadAppOpenAd(adUnitIds: [adUnitId1, adUnitId2]);

      // Assert
      expect(ad, mockAd);
      verify(
        () => mockAdLoader.loadAppOpenAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).called(1);
      verify(
        () => mockAdLoader.loadAppOpenAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
        ),
      ).called(1);
    });

    test(
        'loadAppOpenAd with waterfall throws AdWaterfallException if '
        'all adUnitIds fail', () async {
      // Arrange
      when(
        () => mockAdLoader.loadAppOpenAd(
          adUnitId: adUnitId1,
          request: any(named: 'request'),
        ),
      ).thenThrow(mockError1);
      when(
        () => mockAdLoader.loadAppOpenAd(
          adUnitId: adUnitId2,
          request: any(named: 'request'),
        ),
      ).thenThrow(mockError2);

      // Act & Assert
      final call =
          orchestrator.loadAppOpenAd(adUnitIds: [adUnitId1, adUnitId2]);

      expect(
        call,
        throwsA(
          isA<AdWaterfallException>().having(
            (e) => e.allErrors,
            'allErrors',
            [mockError1, mockError2],
          ),
        ),
      );
    });
  });

  group('AdLoaderOrchestrator: Global Ad Control (isAdsEnabled)', () {
    setUp(() {
      // Reset the global flag before each test
      GoogleMobileAdsAsync.isAdsEnabled = true;
    });

    tearDown(() {
      // Reset back to enabled after each test
      GoogleMobileAdsAsync.isAdsEnabled = true;
    });

    test('loadBannerAd throws AdLoadException when ads are disabled', () async {
      // Arrange
      GoogleMobileAdsAsync.isAdsEnabled = false;

      // Act & Assert
      final call = orchestrator.loadBannerAd(
        adUnitIds: [adUnitId1],
        size: AdSize.banner,
      );

      await expectLater(
        call,
        throwsA(
          isA<AdLoadException>().having(
            (e) => e.error.message,
            'message',
            'Ad loading is globally disabled',
          ),
        ),
      );

      // Verify mockAdLoader was never called
      verifyNever(
        () => mockAdLoader.loadBannerAd(
          adUnitId: any(named: 'adUnitId'),
          size: any(named: 'size'),
          request: any(named: 'request'),
        ),
      );
    });

    test('loadInterstitialAd throws AdLoadException when ads are disabled',
        () async {
      // Arrange
      GoogleMobileAdsAsync.isAdsEnabled = false;

      // Act & Assert
      final call = orchestrator.loadInterstitialAd(adUnitIds: [adUnitId1]);

      await expectLater(
        call,
        throwsA(
          isA<AdLoadException>().having(
            (e) => e.error.message,
            'message',
            'Ad loading is globally disabled',
          ),
        ),
      );

      // Verify mockAdLoader was never called
      verifyNever(
        () => mockAdLoader.loadInterstitialAd(
          adUnitId: any(named: 'adUnitId'),
          request: any(named: 'request'),
        ),
      );
    });

    test('loadRewardedAd throws AdLoadException when ads are disabled',
        () async {
      // Arrange
      GoogleMobileAdsAsync.isAdsEnabled = false;

      // Act & Assert
      final call = orchestrator.loadRewardedAd(adUnitIds: [adUnitId1]);

      await expectLater(
        call,
        throwsA(
          isA<AdLoadException>().having(
            (e) => e.error.message,
            'message',
            'Ad loading is globally disabled',
          ),
        ),
      );

      // Verify mockAdLoader was never called
      verifyNever(
        () => mockAdLoader.loadRewardedAd(
          adUnitId: any(named: 'adUnitId'),
          request: any(named: 'request'),
        ),
      );
    });

    test(
        'loadRewardedInterstitialAd throws AdLoadException when ads '
        'are disabled', () async {
      // Arrange
      GoogleMobileAdsAsync.isAdsEnabled = false;

      // Act & Assert
      final call =
          orchestrator.loadRewardedInterstitialAd(adUnitIds: [adUnitId1]);

      await expectLater(
        call,
        throwsA(
          isA<AdLoadException>().having(
            (e) => e.error.message,
            'message',
            'Ad loading is globally disabled',
          ),
        ),
      );

      // Verify mockAdLoader was never called
      verifyNever(
        () => mockAdLoader.loadRewardedInterstitialAd(
          adUnitId: any(named: 'adUnitId'),
          request: any(named: 'request'),
        ),
      );
    });

    test('loadNativeAd throws AdLoadException when ads are disabled', () async {
      // Arrange
      GoogleMobileAdsAsync.isAdsEnabled = false;

      // Act & Assert
      final call = orchestrator.loadNativeAd(adUnitIds: [adUnitId1]);

      await expectLater(
        call,
        throwsA(
          isA<AdLoadException>().having(
            (e) => e.error.message,
            'message',
            'Ad loading is globally disabled',
          ),
        ),
      );

      // Verify mockAdLoader was never called
      verifyNever(
        () => mockAdLoader.loadNativeAd(
          adUnitId: any(named: 'adUnitId'),
          request: any(named: 'request'),
          nativeAdOptions: any(named: 'nativeAdOptions'),
          factoryId: any(named: 'factoryId'),
        ),
      );
    });

    test('loadAppOpenAd throws AdLoadException when ads are disabled',
        () async {
      // Arrange
      GoogleMobileAdsAsync.isAdsEnabled = false;

      // Act & Assert
      final call = orchestrator.loadAppOpenAd(adUnitIds: [adUnitId1]);

      await expectLater(
        call,
        throwsA(
          isA<AdLoadException>().having(
            (e) => e.error.message,
            'message',
            'Ad loading is globally disabled',
          ),
        ),
      );

      // Verify mockAdLoader was never called
      verifyNever(
        () => mockAdLoader.loadAppOpenAd(
          adUnitId: any(named: 'adUnitId'),
          request: any(named: 'request'),
        ),
      );
    });

    test('ads load successfully when isAdsEnabled is true', () async {
      // Arrange
      GoogleMobileAdsAsync.isAdsEnabled = true; // explicitly set
      final mockBannerAd = MockBannerAd();

      when(
        () => mockAdLoader.loadBannerAd(
          adUnitId: adUnitId1,
          size: any(named: 'size'),
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockBannerAd);

      // Act
      final ad = await orchestrator.loadBannerAd(
        adUnitIds: [adUnitId1],
        size: AdSize.banner,
      );

      // Assert
      expect(ad, mockBannerAd);
      verify(
        () => mockAdLoader.loadBannerAd(
          adUnitId: adUnitId1,
          size: any(named: 'size'),
          request: any(named: 'request'),
        ),
      ).called(1);
    });
  });
}
