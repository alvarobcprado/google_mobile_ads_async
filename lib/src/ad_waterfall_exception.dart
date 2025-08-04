import 'package:google_mobile_ads_async/src/ad_load_exception.dart';

/// An exception thrown when an ad fails to load after trying all adUnitIds
/// in a waterfall sequence.
class AdWaterfallException implements Exception {
  /// Creates an [AdWaterfallException] with a list of the underlying errors.
  AdWaterfallException(this.allErrors);

  /// A list of all the [AdLoadException] errors that occurred for each
  /// corresponding adUnitId in the waterfall.
  final List<AdLoadException> allErrors;

  @override
  String toString() =>
      'Ad waterfall failed: None of the provided adUnitIds could load an ad. '
      'Encountered ${allErrors.length} errors. First error: ${allErrors.first}';
}
