const _unicodeFractions = <String, double>{
  '\u00BC': 0.25,
  '\u00BD': 0.5,
  '\u00BE': 0.75,
  '\u2153': 1 / 3,
  '\u2154': 2 / 3,
  '\u215B': 0.125,
  '\u215C': 0.375,
  '\u215D': 0.625,
  '\u215E': 0.875,
};

const _wordQuantities = <String, double>{
  'a': 1,
  'an': 1,
  'one': 1,
  'two': 2,
  'three': 3,
  'four': 4,
  'five': 5,
  'six': 6,
  'seven': 7,
  'eight': 8,
  'nine': 9,
  'ten': 10,
  'eleven': 11,
  'twelve': 12,
  'half': 0.5,
  'quarter': 0.25,
};

final _leadingWhitespace = RegExp(r'^\s*');
final _bulletPrefix = RegExp(r'^(?:[-*\u2022\u25AA\u25E6])\s+');
final _numberedListPrefix = RegExp(r'^\d+[.)]\s+');
final _wordQuantityAtStart = RegExp(
  r'^(a|an|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|half|quarter)(?=\s|$)',
  caseSensitive: false,
);

// Mixed fractions are listed before ordinary decimal numbers so `1 1/2` and
// `1/2` remain a single quantity.
const _quantityToken =
    r'(?:\d+\s+\d+\s*/\s*\d+|\d+\s*/\s*\d+|\d+(?:[.,]\d+)?[\u00BC\u00BD\u00BE\u2153\u2154\u215B\u215C\u215D\u215E]?|[\u00BC\u00BD\u00BE\u2153\u2154\u215B\u215C\u215D\u215E])';
final _quantityAtStart = RegExp(
  '^($_quantityToken)(?:\\s*([-\\u2013\\u2014])\\s*($_quantityToken))?',
);

// Units commonly attached directly to a quantity: 100ml, 16g, 2tbsp,
// 1 1/2cups, 400G and camel-cased values such as 100mLWater.
final _attachedUnit = RegExp(
  r'^(?:tablespoons?|tbsp\.?|teaspoons?|tsp\.?|kilograms?|kgs?|grams?|gr|g|gm|milligrams?|mgs?|millilit(?:er|re)s?|mls?|centilit(?:er|re)s?|cls?|decilit(?:er|re)s?|dls?|lit(?:er|re)s?|l|lbs?|pounds?|ounces?|oz|fluid\s*ounces?|fl\.?\s*oz|cups?|cans?|packets?|sachets?|slices?|cloves?|pieces?|sticks?|bunches?|heads?|leaves|leaf|sprigs?|pinches?|dashes?|drops?|inches?|inch|cms?|mms?|x|\u00D7)',
  caseSensitive: false,
);

String multiplyText(String input, double multiplier) {
  final result = StringBuffer();
  final formattedMultiplier = _formatQuantity(multiplier);

  for (final line in input.split('\n')) {
    if (line.trim().isEmpty) {
      result.writeln(line);
      continue;
    }

    final parsedLine = _splitPrefix(line);
    result.writeln(
      _multiplyQuantity(
        content: parsedLine.content,
        prefix: parsedLine.prefix,
        multiplier: multiplier,
        formattedMultiplier: formattedMultiplier,
      ),
    );
  }

  return result.toString().trim();
}

_IngredientLine _splitPrefix(String line) {
  final whitespace = _leadingWhitespace.firstMatch(line)!;
  var prefix = whitespace.group(0)!;
  var content = line.substring(prefix.length);

  final bullet = _bulletPrefix.firstMatch(content);
  final numberedList = _numberedListPrefix.firstMatch(content);
  final listPrefix = bullet ?? numberedList;
  if (listPrefix != null) {
    prefix += listPrefix.group(0)!;
    content = content.substring(listPrefix.end);
  }

  return _IngredientLine(prefix: prefix, content: content);
}

String _multiplyQuantity({
  required String content,
  required String prefix,
  required double multiplier,
  required String formattedMultiplier,
}) {
  final quantityMatch = _quantityAtStart.firstMatch(content);
  if (quantityMatch != null &&
      _hasQuantityBoundary(content.substring(quantityMatch.end))) {
    final firstQuantity = _parseQuantity(quantityMatch.group(1)!);
    final secondQuantity = quantityMatch.group(3);
    final range = secondQuantity == null
        ? ''
        : '${quantityMatch.group(2)}${_formatQuantity(_parseQuantity(secondQuantity) * multiplier)}';
    return '$prefix${_formatQuantity(firstQuantity * multiplier)}$range${content.substring(quantityMatch.end)}';
  }

  final wordMatch = _wordQuantityAtStart.firstMatch(content);
  if (wordMatch != null) {
    final quantity = _wordQuantities[wordMatch.group(1)!.toLowerCase()]!;
    return '$prefix${_formatQuantity(quantity * multiplier)}${content.substring(wordMatch.end)}';
  }

  // No recognised quantity means the ingredient is treated as one unit.
  return '$prefix$formattedMultiplier $content';
}

bool _hasQuantityBoundary(String remainder) {
  if (remainder.isEmpty || RegExp(r'^[\s,;:([{]').hasMatch(remainder)) {
    return true;
  }

  final unitMatch = _attachedUnit.firstMatch(remainder);
  if (unitMatch == null) return false;

  final followingText = remainder.substring(unitMatch.end);
  return followingText.isEmpty ||
      RegExp(r'^[\s,;:([{\d]').hasMatch(followingText) ||
      RegExp(r'^[A-Z]').hasMatch(followingText);
}

double _parseQuantity(String value) {
  for (final entry in _unicodeFractions.entries) {
    if (value.endsWith(entry.key)) {
      final wholeNumber = value
          .substring(0, value.length - entry.key.length)
          .trim();
      return (wholeNumber.isEmpty ? 0 : double.parse(wholeNumber)) +
          entry.value;
    }
  }

  if (value.contains('/')) {
    final pieces = value.trim().split(RegExp(r'\s+'));
    final fraction = pieces.last.split('/');
    final fractionValue =
        double.parse(fraction[0].trim()) / double.parse(fraction[1].trim());
    final wholeNumber = pieces.length > 1 ? double.parse(pieces.first) : 0;
    return wholeNumber + fractionValue;
  }

  return double.parse(value.replaceAll(',', '.'));
}

String _formatQuantity(double value) =>
    removeTrailingZeros(value.toStringAsFixed(3));

String removeTrailingZeros(String numberStr) {
  return numberStr.replaceFirst(RegExp(r'\.?0+$'), '');
}

class _IngredientLine {
  const _IngredientLine({required this.prefix, required this.content});

  final String prefix;
  final String content;
}
