import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads_async/src/ad_loader.dart';

/// A builder function that creates a widget to display a [NativeAd].
typedef NativeAdBuilder = Widget Function(BuildContext context, NativeAd ad);

/// {@template nativeAdWidget}
/// Displays a NativeAd with priority-based logic.
///
/// - If [ad] is provided, it will be displayed with the highest priority, and
///  [adUnitId] will be ignored.
/// - If [ad] is null, a new ad will be loaded using [adUnitId].
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
    _resolveAd();
  }

  @override
  void didUpdateWidget(NativeAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ad != oldWidget.ad || widget.adUnitId != oldWidget.adUnitId) {
      _disposeInternalAd();
      _resolveAd();
    }
  }

  void _resolveAd() {
    if (widget.ad != null) {
      setState(() {
        _ad = widget.ad;
        _isAdManagedInternally = false;
        _isLoading = false;
        _error = null;
      });
    } else if (widget.adUnitId != null) {
      _isAdManagedInternally = true;
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    if (!mounted) return;

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
        setState(() {
          _ad = ad;
          _isLoading = false;
        });
      } else {
        await ad.dispose();
      }
    } catch (e) {
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
      _ad?.dispose();
    }
    _ad = null;
  }

  @override
  void dispose() {
    _disposeInternalAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_error != null) {
      return const Center(child: Icon(Icons.error_outline, color: Colors.red));
    }

    final adToDisplay = _ad;
    if (adToDisplay != null) {
      return widget.nativeAdBuilder(context, adToDisplay);
    }

    return const SizedBox.shrink();
  }
}
