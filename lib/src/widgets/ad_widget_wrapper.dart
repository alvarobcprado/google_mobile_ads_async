import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ad_loader.dart';

/// Enum representing the state of an ad being loaded by a wrapper widget.
enum _AdState {
  /// The ad is currently being loaded.
  loading,

  /// The ad has been successfully loaded.
  loaded,

  /// An error occurred while loading the ad.
  error,
}

/// A generic, abstract base class for widgets that wrap a Google Mobile Ad.
///
/// This class manages the lifecycle of an ad, from loading to display and
/// disposal. It handles the different states (loading, loaded, error) and
/// allows subclasses to define how the ad is loaded and displayed.
abstract class AdWidgetWrapper<T extends Ad> extends StatefulWidget {
  /// The ad unit ID for the ad to be loaded.
  final String adUnitId;

  /// The ad request to use when loading the ad.
  final AdRequest? request;

  /// A builder function for the loading state.
  ///
  /// If null, a [SizedBox.shrink] is used.
  final WidgetBuilder? loadingBuilder;

  /// A builder function for the error state.
  ///
  /// Provides the error object that occurred during loading.
  /// If null, a [SizedBox.shrink] is used.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// The ad loader responsible for loading the ad.
  ///
  /// If null, a default [AsyncAdLoader] instance is created. This is useful
  /// for testing, allowing a mock loader to be injected.
  final AsyncAdLoader? adLoader;

  const AdWidgetWrapper({
    super.key,
    required this.adUnitId,
    this.request,
    this.loadingBuilder,
    this.errorBuilder,
    this.adLoader,
  });

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
    _load();
  }

  @override
  void dispose() {
    _ad?.dispose();
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