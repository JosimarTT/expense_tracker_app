import 'package:expense_tracker_app/core/ids/id_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/data.dart';

bool isUuidV7(String id) => RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
).hasMatch(id);

int timestampFromUuidV7(String id) =>
    int.parse(id.replaceAll('-', '').substring(0, 12), radix: 16);

void main() {
  test('Generates valid, distinct UUIDv7 IDs', () {
    final generator = UuidV7IdGenerator();
    final ids = List.generate(100, (_) => generator.generate());

    expect(ids.every(isUuidV7), isTrue);
    expect(ids.toSet(), hasLength(ids.length));
  });

  test(
    'Embeds the current Unix timestamp for approximate chronological sorting',
    () {
      final before = DateTime.now().toUtc().millisecondsSinceEpoch;
      final id = UuidV7IdGenerator().generate();
      final after = DateTime.now().toUtc().millisecondsSinceEpoch;

      expect(isUuidV7(id), isTrue);
      expect(timestampFromUuidV7(id), inInclusiveRange(before, after));
    },
  );

  test('IDs with increasing embedded timestamps sort chronologically', () {
    const uuid = Uuid();
    final older = uuid.v7(config: V7Options(1760000000000, null));
    final newer = uuid.v7(config: V7Options(1760000000001, null));

    expect(isUuidV7(older), isTrue);
    expect(isUuidV7(newer), isTrue);
    expect(older.compareTo(newer), lessThan(0));
  });
}
