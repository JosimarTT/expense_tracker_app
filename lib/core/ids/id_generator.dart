import 'package:uuid/uuid.dart';

abstract interface class IdGenerator {
  String generate();
}

class UuidV7IdGenerator implements IdGenerator {
  UuidV7IdGenerator({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  @override
  String generate() => _uuid.v7();
}
