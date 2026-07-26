import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads_async/google_mobile_ads_async.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.flutter.io/google_mobile_ads');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<BuildContext> pumpContext(
    WidgetTester tester, {
    double width = 400,
  }) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, 800)),
          child: SizedBox(key: key),
        ),
      ),
    );
    return key.currentContext!;
  }

  group('BannerAdSizeConfig', () {
    testWidgets('returns the configured standard size', (tester) async {
      final context = await pumpContext(tester);
      const config = BannerAdSizeConfig.standard(AdSize.mediumRectangle);

      final size = await config.getAdSize(context);

      expect(size, AdSize.mediumRectangle);
    });

    testWidgets('creates an inline adaptive size without a max height', (
      tester,
    ) async {
      final context = await pumpContext(tester);
      const config = BannerAdSizeConfig.inline(
        padding: EdgeInsets.symmetric(horizontal: 16),
      );

      final size = await config.getAdSize(context);

      expect(size, isA<InlineAdaptiveSize>());
      expect(size?.width, 368);
      expect((size! as InlineAdaptiveSize).maxHeight, isNull);
    });

    testWidgets('creates an inline adaptive size with a max height', (
      tester,
    ) async {
      final context = await pumpContext(tester);
      const config = BannerAdSizeConfig.inline(maxHeight: 120);

      final size = await config.getAdSize(context);

      expect(size, isA<InlineAdaptiveSize>());
      expect(size?.width, 400);
      expect((size! as InlineAdaptiveSize).maxHeight, 120);
    });

    testWidgets('requests a large anchored adaptive size', (tester) async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return 90;
          });
      final context = await pumpContext(tester);
      const config = BannerAdSizeConfig.anchored(
        padding: EdgeInsets.symmetric(horizontal: 16),
      );

      final size = await config.getAdSize(context);

      expect(size, isA<AnchoredAdaptiveBannerAdSize>());
      expect(size?.width, 368);
      expect(size?.height, 90);
      expect(calls, hasLength(1));
      expect(
        calls.single.method,
        'AdSize#getLargeAnchoredAdaptiveBannerAdSize',
      );
      expect(calls.single.arguments, {'width': 368});
    });

    testWidgets('returns null when padding makes the width negative', (
      tester,
    ) async {
      final context = await pumpContext(tester, width: 100);
      const config = BannerAdSizeConfig.inline(
        padding: EdgeInsets.symmetric(horizontal: 60),
      );

      final size = await config.getAdSize(context);

      expect(size, isNull);
    });
  });
}
