import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads_async/src/ad_loader.dart';
import 'package:google_mobile_ads_async/src/utils/logger.dart';
import 'package:google_mobile_ads_async/src/widgets/ad_builders.dart';

/// A builder function that creates a widget to display a [NativeAd].
typedef NativeAdBuilder = Widget Function(BuildContext context, NativeAd ad);

/// {@template nativeAdWidget}
/// Displays a NativeAd with priority-based logic.
///
/// - If [ad] is provided, it will be displayed with the highest priority, and
///  [adUnitId] will be ignored.
/// - If [ad] is null, a new ad will be loaded using [adUnitId].
///
/// This widget provides optional builders for loading and error states.
/// If they are not provided, a [SizedBox.shrink] will be displayed.
/// {@endtemplate}
class NativeAdWidget extends StatefulWidget {
  ////@{macro nativeAdWidget}
  const NativeAdWidget({
    required this.nativeAdBuilder,
    super.key,
    this.ad,
    this.adUnitId,
    this.adRequest = const AdRequest(),
    this.factoryId,
    this.nativeAdOptions,
    this.loadingBuilder,
    this.errorBuilder,
  }) : assert(
          ad != null || adUnitId != null,
          'Either ad or adUnitId must be provided.',
        );

  /// A pre-loaded ad to be displayed. It has priority over [adUnitId].
  final NativeAd? ad;

  /// The ad unit ID for loading an ad, used only if [ad] is null.
  final String? adUnitId;

  /// The builder function to create the ad's UI.
  final NativeAdBuilder nativeAdBuilder;

  /// The ad request to use when loading with [adUnitId].
  final AdRequest adRequest;

  /// Optional factory ID for native ad formats.
  final String? factoryId;

  /// Optional options for the native ad.
  final NativeAdOptions? nativeAdOptions;

  /// A builder for the loading state. If null, a [SizedBox.shrink] is shown.
  final AdLoadingBuilder? loadingBuilder;

  /// A builder for the error state. If null, a [SizedBox.shrink] is shown.
  final AdErrorBuilder? errorBuilder;

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _ad;
  bool _isAdManagedInternally = false;

  bool _isLoading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    AdLogger.verbose(
      'initState: ${widget.runtimeType} with AdUnitId: ${widget.adUnitId}',
    );
    _resolveAd();
  }

  @override
  void didUpdateWidget(NativeAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    AdLogger.verbose(
      'didUpdateWidget: ${widget.runtimeType} with AdUnitId: '
      '${widget.adUnitId}',
    );
    if (widget.ad != oldWidget.ad || widget.adUnitId != oldWidget.adUnitId) {
      _disposeInternalAd();
      _resolveAd();
    }
  }

  void _resolveAd() {
    if (widget.ad != null) {
      AdLogger.debug(
        'Using externally provided ad for ${widget.runtimeType}.',
      );
      setState(() {
        _ad = widget.ad;
        _isAdManagedInternally = false;
        _isLoading = false;
        _error = null;
      });
    } else if (widget.adUnitId != null) {
      AdLogger.debug(
        'No external ad provided, loading internally for '
        '${widget.runtimeType}.',
      );
      _isAdManagedInternally = true;
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    if (!mounted) return;
    AdLogger.debug('Internal ad load started for ${widget.runtimeType}');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final adLoader = AsyncAdLoader();
      final ad = await adLoader.loadNativeAd(
        adUnitId: widget.adUnitId!,
        request: widget.adRequest,
        factoryId: widget.factoryId,
        nativeAdOptions: widget.nativeAdOptions,
      );

      if (mounted) {
        AdLogger.info('Internal ad load succeeded for ${widget.runtimeType}');
        setState(() {
          _ad = ad;
          _isLoading = false;
        });
      } else {
        AdLogger.warning(
          'Widget was disposed while ad was loading. Disposing ad.',
        );
        await ad.dispose();
      }
    } catch (e) {
      AdLogger.error(
        'Internal ad load failed for ${widget.runtimeType}',
        error: e,
      );
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  void _disposeInternalAd() {
    if (_isAdManagedInternally) {
      AdLogger.debug(
        'Disposing internally managed ad for ${widget.runtimeType}.',
      );
      _ad?.dispose();
    }
    _ad = null;
  }

  @override
  void dispose() {
    AdLogger.verbose(
      'dispose: ${widget.runtimeType} with AdUnitId: ${widget.adUnitId}',
    );
    _disposeInternalAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingBuilder?.call(context) ?? const SizedBox.shrink();
    }

    if (_error != null) {
      return widget.errorBuilder?.call(context, _error!) ??
          const SizedBox.shrink();
    }

    final adToDisplay = _ad;
    if (adToDisplay != null) {
      return widget.nativeAdBuilder(context, adToDisplay);
    }

    return const SizedBox.shrink();
  }
}
