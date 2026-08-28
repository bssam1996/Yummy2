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
}
