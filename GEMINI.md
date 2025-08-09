# Formatting and Linting
- The project should follow the linter rules defined by the package very_good_analysis. See the [very_good_analysis](https://github.com/verygoodopensource/very_good_analysis) package for details.
- Imports should be sorted alphabetically and follow the following pattern: `import 'package:package_name/file_name.dart';` instead of `../file_name.dart`.

# Tests
This project uses the `mocktail` package for mocking and testing.

# AI Rules
- Act as a Flutter co-developer
- Writes unit tests
- Proactively look for and fix errors
- Choose which tools, extensions, and startup commands to use
- Add and remove Flutter packages
- Adhere to Flutter and Dart best practices for code quality

# Steps to Run when adding a New Feature
- For each new feature, plan the steps to implement it, then create a todo list for each step needed to implement the feature.
- Run `flutter pub get` to fetch dependencies when adding a new package dependency.
- Implement unit tests for the new/modified APIs.
- Run `dart_fix` and `dart_format` to check for any linting errors and warnings and then fix them.
- If the feature is completed, run `flutter test` to check for any test failures and then fix them.
- Update the `ARCHITECTURE.md` document to reflect the new feature implementation or changes.
- Mantain the `README.md` document up to date when changes are made to the package.