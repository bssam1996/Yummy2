String multiplyText(String input, double multiplier) {
  final lines = input.split('\n');
  final result = StringBuffer();
  final formattedMultiplier = removeTrailingZeros(
    multiplier.toStringAsFixed(3),
  );
  // A quantity is valid only when it is the first token in a line. This keeps
  // ingredient names such as "ml7" unchanged.
  final quantityAtStartOfLine = RegExp(r'^(\s*)(\d+(?:\.\d+)?)(?=\s)');

  for (final line in lines) {
    if (line.trim().isEmpty) {
      result.writeln(line);
      continue;
    }

    final quantityMatch = quantityAtStartOfLine.firstMatch(line);
    if (quantityMatch == null) {
      // An ingredient without a starting quantity is treated as one serving.
      result.writeln('$formattedMultiplier $line');
      continue;
    }

    final quantity = double.parse(quantityMatch.group(2)!);
    final multipliedQuantity = removeTrailingZeros(
      (quantity * multiplier).toStringAsFixed(3),
    );
    result.writeln(
      '${quantityMatch.group(1)}$multipliedQuantity${line.substring(quantityMatch.end)}',
    );
  }

  return result.toString().trim();
}

String removeTrailingZeros(String numberStr) {
  // Remove trailing zeros and the decimal point if the number is an integer
  numberStr = numberStr.replaceFirst(RegExp(r'\.?0+$'), '');
  return numberStr;
}
