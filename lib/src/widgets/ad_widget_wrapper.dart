import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ad_loader.dart';

/// Enum representing the state of an ad being loaded by a wrapper widget.
enum _AdState {
  /// The ad is currently being loaded.
  loading,

  /// The ad has been successfully loaded or was provided pre-loaded.
  loaded,

  /// An error occurred while loading the ad.
  error,
}

/// A generic, abstract base class for widgets that wrap a Google Mobile Ad.
///
/// This class manages the lifecycle of an ad, from loading to display and
/// disposal. It supports two flows:
/// 1.  **Live Loading:** When created with the default constructor, it loads an
///     ad based on an `adUnitId`.
/// 2.  **Pre-loaded Ad:** When created with a `.fromAd` constructor, it displays
///     an ad object that has already been loaded.
abstract class AdWidgetWrapper<T extends Ad> extends StatefulWidget {
  /// The ad unit ID for the ad. Required for live loading.
  final String? adUnitId;

  /// The pre-loaded ad object to display.
  final T? ad;

  /// The ad request to use when loading the ad live.
  final AdRequest? request;

  /// A builder function for the loading state.
  final WidgetBuilder? loadingBuilder;

  /// A builder function for the error state.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// The ad loader used for live loading.
  final AsyncAdLoader? adLoader;

  /// Creates a wrapper that loads an ad live.
  const AdWidgetWrapper({
    super.key,
    required this.adUnitId,
    this.request,
    this.loadingBuilder,
    this.errorBuilder,
    this.adLoader,
  }) : ad = null;

  /// Creates a wrapper that displays a pre-loaded ad.
  AdWidgetWrapper.fromAd({
    super.key,
    required this.ad,
    this.loadingBuilder,
    this.errorBuilder,
  })  : adUnitId = ad?.adUnitId,
        request = null,
        adLoader = null;

  /// Abstract method that subclasses must implement to load the specific ad type.
  Future<T> loadAd();

  /// Abstract method that subclasses must implement to build the widget
  /// that displays the loaded ad.
  Widget buildAd(BuildContext context, T ad);

  @override
  State<AdWidgetWrapper<T>> createState() => _AdWidgetWrapperState<T>();
}

class _AdWidgetWrapperState<T extends Ad> extends State<AdWidgetWrapper<T>> {
  _AdState _adState = _AdState.loading;
  T? _ad;
  Object? _error;

  @override
  void initState() {
    super.initState();
    // If an ad was provided, it's already loaded.
    if (widget.ad != null) {
      _ad = widget.ad;
      _adState = _AdState.loaded;
    } else {
      // Otherwise, start the live loading process.
      _adState = _AdState.loading;
      _load();
    }
  }

  @override
  void dispose() {
    // The widget only disposes the ad if it loaded it itself.
    // Pre-loaded ads passed to `.fromAd` are managed externally.
    if (widget.ad == null) {
      _ad?.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final ad = await widget.loadAd();
      if (!mounted) return;
      setState(() {
        _ad = ad;
        _adState = _AdState.loaded;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _adState = _AdState.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_adState) {
      case _AdState.loading:
        return widget.loadingBuilder?.call(context) ?? const SizedBox.shrink();
      case _AdState.error:
        return widget.errorBuilder?.call(context, _error!) ??
            const SizedBox.shrink();
      case _AdState.loaded:
        return widget.buildAd(context, _ad!);
    }
  }
}
