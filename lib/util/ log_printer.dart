import 'package:logger/logger.dart';

// Custom printer to include dynamic class name
class ClassNamePrettyPrinter extends PrettyPrinter {
  final String className;

  ClassNamePrettyPrinter({
    required this.className,
    int methodCount = 2,
    int errorMethodCount = 8,
    int lineLength = 120,
    bool colors = true,
    bool printEmojis = true,
  }) : super(
          methodCount: methodCount,
          errorMethodCount: errorMethodCount,
          lineLength: lineLength,
          colors: colors,
          printEmojis: printEmojis,
        );

  @override
  List<String> log(LogEvent event) {
    // Get the original log message using PrettyPrinter's log method
    final originalLog = super.log(event);
    
    // Prepend class name to each log message
    final classNamePrefix = '[${className}] ';
    return originalLog.map((log) => classNamePrefix + log).toList();
  }
}
