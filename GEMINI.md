# Formatting and Linting
- The project should follow the linter rules defined by the package very_good_analysis. See the [very_good_analysis](https://github.com/verygoodopensource/very_good_analysis) package for details.
- Imports should be sorted alphabetically and follow the following pattern: `import 'package:package_name/file_name.dart';` instead of `../file_name.dart`.

# Tests
This project uses the `mocktail` package for mocking and testing.

# Steps to Run when adding a New Feature
- If a new package is added, run `flutter pub get` to fetch dependencies.
- If the feature will add new/modify existing APIs, implement the unit tests for the new/modified APIs.
- If the feature is completed, run `flutter analyze` to check for any linting errors and warnings and then fix them.
- If the feature is completed, run `flutter test` to check for any test failures and then fix them.