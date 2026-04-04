// ignore_for_file: avoid_print
//
// `developer.log` is easy to miss in `flutter run` output; these go to stdout.

/// Visible in the **host terminal** when you run `flutter run` / `flutter run -v`.
void logToTerminal(String tag, String message) {
  print('[$tag] $message');
}

void logErrorToTerminal(String tag, Object error, StackTrace stackTrace) {
  print('[$tag] $error');
  print(stackTrace);
}
