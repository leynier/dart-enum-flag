import 'dart:io';

const _defaultLcovPath = 'coverage/lcov.info';

void main(List<String> arguments) {
  if (arguments.length > 1) {
    stderr.writeln('Usage: dart run tool/check_coverage.dart [lcov-path]');
    exitCode = 64;
    return;
  }

  final path = arguments.firstOrNull ?? _defaultLcovPath;
  final report = File(path);
  if (!report.existsSync()) {
    stderr.writeln('Coverage report not found: $path');
    exitCode = 66;
    return;
  }

  var linesFound = 0;
  var linesHit = 0;
  for (final line in report.readAsLinesSync()) {
    if (line.startsWith('LF:')) {
      linesFound += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      linesHit += int.parse(line.substring(3));
    }
  }

  if (linesFound == 0) {
    stderr.writeln('Coverage report contains no executable lines: $path');
    exitCode = 65;
    return;
  }

  final percentage = linesHit * 100 / linesFound;
  stdout.writeln(
    'Line coverage: $linesHit/$linesFound (${percentage.toStringAsFixed(2)}%)',
  );

  if (linesHit != linesFound) {
    stderr.writeln('Expected 100.00% line coverage.');
    exitCode = 1;
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
