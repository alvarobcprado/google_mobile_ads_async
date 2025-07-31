import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads_async/src/ad_loader.dart';

/// {@template banner_ad_widget}
/// Displays a BannerAd with priority-based logic.
///
/// - If [ad] is provided, it will be displayed with the highest priority, and
///  [adUnitId] will be ignored.
/// - If [ad] is null, a new ad will be loaded using [adUnitId].
/// {@endtemplate}
class BannerAdWidget extends StatefulWidget {
  /// {@macro banner_ad_widget}
  const BannerAdWidget({
    super.key,
    this.ad,
    this.adUnitId,
    this.adRequest = const AdRequest(),
    this.size,
  }) : assert(
          ad != null || (adUnitId != null && size != null),
          'If ad is not provided, then adUnitId and size must be provided.',
        );

  /// A pre-loaded ad to be displayed. It has priority over [adUnitId].
  final BannerAd? ad;

  /// The ad unit ID for loading an ad, used only if [ad] is null.
  final String? adUnitId;

  /// The ad request to use when loading with [adUnitId].
  final AdRequest adRequest;

  /// The size of the banner ad. Required if loading with [adUnitId].
  final AdSize? size;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  // The ad that the widget is currently managing or displaying.
  BannerAd? _ad;
  // Flag to determine if _ad was created and is managed by this widget.
  bool _isAdManagedInternally = false;

  bool _isLoading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _resolveAd();
  }

  @override
  void didUpdateWidget(BannerAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the source of the ad changes, we need to re-evaluate.
    if (widget.ad != oldWidget.ad || widget.adUnitId != oldWidget.adUnitId) {
      _disposeInternalAd();
      _resolveAd();
    }
  }

  /// Decides which ad to use based on the priority logic.
  void _resolveAd() {
    // Priority 1: Use the externally provided ad.
    if (widget.ad != null) {
      setState(() {
        _ad = widget.ad;
        _isAdManagedInternally = false;
        _isLoading = false;
        _error = null;
      });
    }
    // Priority 2: Load an ad internally using adUnitId.
    else if (widget.adUnitId != null) {
      _isAdManagedInternally = true;
      _loadAd();
    }
  }

  /// Loads the ad using the adUnitId.
  Future<void> _loadAd() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final adLoader = AsyncAdLoader();
      final ad = await adLoader.loadBannerAd(
        adUnitId: widget.adUnitId!,
        size: widget.size!,
        request: widget.adRequest,
      );

      if (mounted) {
        setState(() {
          _ad = ad;
          _isLoading = false;
        });
      } else {
        // If the widget was disposed while the ad was loading, dispose the ad.
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

  /// Disposes of the internal ad only if it was created by this widget.
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
      // Optional: Display a more informative error widget.
      return const Center(child: Icon(Icons.error_outline, color: Colors.red));
    }

    final adToDisplay = _ad;
    if (adToDisplay != null) {
      return SizedBox(
        width: adToDisplay.size.width.toDouble(),
        height: adToDisplay.size.height.toDouble(),
        child: AdWidget(ad: adToDisplay),
      );
    }

    // Returns an empty container if there is no ad to display.
    return const SizedBox.shrink();
  }
}
