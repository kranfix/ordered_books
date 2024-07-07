import 'package:commons/commons.dart';
import 'package:test/test.dart';

class Item with Versionable<Item> {
  const Item(this.id);

  final String id;

  @override
  VID<Item> get $id => VID(id);

  @override
  Version get $version => Version('1.0.0');
}

class Item2 with Versionable<Item2> {
  const Item2(this.id);

  final String id;

  @override
  VID<Item2> get $id => VID(id);

  @override
  Version get $version => Version('1.0.0');
}

void main() {
  group('VID', () {
    test('is comparable with the same type', () {
      final vid1 = VID<Item>('key');
      final vid2 = VID<Item>('key');
      final vid3 = VID<Item>('key1');
      expect(vid1 == 'key', isTrue);
      expect(vid1 == vid1, isTrue);
      expect(vid1 == vid2, isTrue);
      expect(vid1 == vid3, isFalse);
    });
  });
}
