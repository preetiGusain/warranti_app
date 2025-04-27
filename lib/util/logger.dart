import 'package:logger/logger.dart';
import 'package:warranti_app/util/ log_printer.dart';

Logger getLogger(String className) {
  return Logger(
    printer: ClassNamePrettyPrinter(
      className: className,
      methodCount: 2,               // Number of method calls to display
      errorMethodCount: 8,          // Number of method calls in stack trace
      lineLength: 120,              // Width of output
      colors: true,                 // Colorful output
      printEmojis: true,            // Print emojis for log levels
    ),
  );
}
