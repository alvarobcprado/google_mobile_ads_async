import 'package:flutter/material.dart';
import 'package:google_mobile_ads_async/google_mobile_ads_async.dart';
import 'package:google_mobile_ads_async/src/utils/logger.dart';

/// {@template banner_ad_widget}
/// Displays a BannerAd with priority-based logic.
///
/// - If [ad] is provided, it will be displayed with the highest priority.
/// - If [ad] is null, a new ad will be loaded using [adUnitIds].
///
/// This widget provides optional builders for loading and error states.
/// If they are not provided, a [SizedBox.shrink] will be displayed.
/// {@endtemplate}
class BannerAdWidget extends StatefulWidget {
  /// {@macro banner_ad_widget}
  const BannerAdWidget({
    super.key,
    this.ad,
    this.adUnitIds,
    this.adRequest = const AdRequest(),
    this.size,
    this.loadingBuilder,
    this.errorBuilder,
  }) : assert(
          ad != null || (adUnitIds != null && size != null),
          'If ad is not provided, then size and an adUnitIds list must be'
          ' provided.',
        );

  /// A pre-loaded ad to be displayed. It has priority over other load params.
  final BannerAd? ad;

  /// A list of ad unit IDs to be tried in a waterfall sequence.
  final List<String>? adUnitIds;

  /// The ad request to use when loading an ad.
  final AdRequest adRequest;

  /// The size of the banner ad. Required if loading a new ad.
  final AdSize? size;

  /// A builder for the loading state. If null, a [SizedBox.shrink] is shown.
  final AdLoadingBuilder? loadingBuilder;

  /// A builder for the error state. If null, a [SizedBox.shrink] is shown.
  final AdErrorBuilder? errorBuilder;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _isAdManagedInternally = false;

  bool _isLoading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    AdLogger.verbose(
      'initState: ${widget.runtimeType} with AdUnitIds: ${widget.adUnitIds}',
    );
    _resolveAd();
  }

  @override
  void didUpdateWidget(BannerAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    AdLogger.verbose(
      'didUpdateWidget: ${widget.runtimeType} with AdUnitIds: '
      '${widget.adUnitIds}',
    );
    // If the source of the ad changes, we need to re-evaluate.
    if (widget.ad != oldWidget.ad ||
        widget.adUnitIds != oldWidget.adUnitIds) {
      _disposeInternalAd();
      _resolveAd();
    }
  }

  /// Decides which ad to use based on the priority logic.
  void _resolveAd() {
    // Priority 1: Use the externally provided ad.
    if (widget.ad != null) {
      AdLogger.debug('Using externally provided ad for ${widget.runtimeType}.');
      setState(() {
        _ad = widget.ad;
        _isAdManagedInternally = false;
        _isLoading = false;
        _error = null;
      });
    }
    // Priority 2: Load an ad internally using adUnitIds.
    else if (widget.adUnitIds != null) {
      AdLogger.debug(
        'No external ad provided, loading internally for '
        '${widget.runtimeType}.',
      );
      _isAdManagedInternally = true;
      _loadAd();
    }
  }

  /// Loads the ad using the adUnitIds.
  Future<void> _loadAd() async {
    if (!mounted) return;
    AdLogger.debug('Internal ad load started for ${widget.runtimeType}');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ad = await GoogleMobileAdsAsync.loadBannerAd(
        adUnitIds: widget.adUnitIds!,
        size: widget.size!,
        request: widget.adRequest,
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

  /// Disposes of the internal ad only if it was created by this widget.
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
      'dispose: ${widget.runtimeType} with AdUnitIds: ${widget.adUnitIds}',
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
