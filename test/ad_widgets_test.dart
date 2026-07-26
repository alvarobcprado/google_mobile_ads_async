import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads_async/google_mobile_ads_async.dart';

void main() {
  setUp(() {
    GoogleMobileAdsAsync.isAdsEnabled = false;
    GoogleMobileAdsAsync.setLogLevel(Level.off);
  });

  tearDown(() {
    GoogleMobileAdsAsync.isAdsEnabled = true;
    GoogleMobileAdsAsync.setLogLevel(Level.all);
  });

  testWidgets('BannerAdWidget exposes its error state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BannerAdWidget(
          adUnitIds: const ['banner'],
          sizeConfig: const BannerAdSizeConfig.standard(AdSize.banner),
          loadingBuilder: (_) => const Text('loading banner'),
          errorBuilder: (_, _) => const Text('banner error'),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('banner error'), findsOneWidget);
  });

  testWidgets('BannerAdWidget reloads after its ad unit IDs change', (
    tester,
  ) async {
    var errorBuildCount = 0;

    Widget buildWidget(List<String> adUnitIds) => MaterialApp(
      home: BannerAdWidget(
        adUnitIds: adUnitIds,
        sizeConfig: const BannerAdSizeConfig.standard(AdSize.banner),
        errorBuilder: (_, _) {
          errorBuildCount++;
          return const Text('banner error');
        },
      ),
    );

    await tester.pumpWidget(buildWidget(const ['first-banner']));
    await tester.pump();
    expect(errorBuildCount, 1);

    await tester.pumpWidget(buildWidget(const ['second-banner']));
    await tester.pump();

    expect(errorBuildCount, greaterThan(1));
  });

  testWidgets('NativeAdWidget exposes loading and error states', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NativeAdWidget(
          adUnitIds: const ['native'],
          loadingBuilder: (_) => const Text('loading native'),
          errorBuilder: (_, _) => const Text('native error'),
        ),
      ),
    );

    expect(find.text('loading native'), findsOneWidget);

    await tester.pump();

    expect(find.text('native error'), findsOneWidget);
  });

  testWidgets('NativeAdWidget reloads after its factory ID changes', (
    tester,
  ) async {
    var errorBuildCount = 0;

    Widget buildWidget(String factoryId) => MaterialApp(
      home: NativeAdWidget(
        adUnitIds: const ['native'],
        factoryId: factoryId,
        errorBuilder: (_, _) {
          errorBuildCount++;
          return const Text('native error');
        },
      ),
    );

    await tester.pumpWidget(buildWidget('first-factory'));
    await tester.pump();
    expect(errorBuildCount, 1);

    await tester.pumpWidget(buildWidget('second-factory'));
    await tester.pump();

    expect(errorBuildCount, 2);
  });
}
