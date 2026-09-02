import 'package:field_lens/core/demo/demo_data_seeder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DemoDataSeeder exposes seeded settings key', () {
    expect(DemoDataSeeder.seededKey, 'demo_data_seeded');
  });
}
