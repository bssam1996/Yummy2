import 'package:flutter_test/flutter_test.dart';
import 'package:yummy2/UI/Recipe/helper.dart';

void main() {
  test('only multiplies a quantity at the start of an ingredient line', () {
    expect(
      multiplyText('1 salt\n1 ml7\nsalt, pepper', 0.5),
      '0.5 salt\n0.5 ml7\n0.5 salt, pepper',
    );
  });

  test('does not interpret a joined number as an ingredient quantity', () {
    expect(multiplyText('1salt', 0.5), '0.5 1salt');
  });

  test('multiplies compact units regardless of their casing', () {
    expect(
      multiplyText('16g salt\n100mL water\n2tbsp olive oil\n100mlWater', 0.5),
      '8g salt\n50mL water\n1tbsp olive oil\n50mlWater',
    );
  });

  test('supports fractions, ranges, list prefixes, and written quantities', () {
    expect(
      multiplyText(
        '1/2 cup milk\n1 1/2cups flour\n1-2 kg potatoes\n- one clove garlic\n\u00BDcup cream',
        0.5,
      ),
      '0.25 cup milk\n0.75cups flour\n0.5-1 kg potatoes\n- 0.5 clove garlic\n0.25cup cream',
    );
  });
}
