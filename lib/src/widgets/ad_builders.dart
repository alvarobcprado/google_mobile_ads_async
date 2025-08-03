import 'package:flutter/widgets.dart';

/// A builder function for the ad loading state.
typedef AdLoadingBuilder = Widget Function(BuildContext context);

/// A builder function for the ad error state.
///
/// The [error] parameter contains the exception that occurred.
typedef AdErrorBuilder = Widget Function(BuildContext context, Object error);
