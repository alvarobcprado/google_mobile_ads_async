import 'package:google_mobile_ads/google_mobile_ads.dart';

/// An exception thrown when a native ad fails to load.
class AdLoadException implements Exception {
  /// Creates an [AdLoadException] with the given [LoadAdError].
  AdLoadException(this.error);

  /// The error object from the Google Mobile Ads SDK.
  final LoadAdError error;

  @override
  String toString() =>
      'Failed to load ad: ${error.message} (Code: ${error.code})';
}
