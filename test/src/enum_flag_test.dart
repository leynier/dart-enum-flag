import 'package:enum_flag/enum_flag.dart';
import 'package:test/test.dart';

enum EnumX with EnumFlag {
  one,
  two,
}

void main() {
  test('Test', () {
    expect(EnumX.one.value, equals(1));
    expect(EnumX.two.value, equals(2));
    expect(EnumX.one.value | EnumX.two.value, equals(1 | 2));
    expect(1.hasFlag(EnumX.one), isTrue);
    expect(1.hasFlag(EnumX.two), isFalse);
    expect(2.hasFlag(EnumX.one), isFalse);
    expect(2.hasFlag(EnumX.two), isTrue);
    expect((1 | 2).hasFlag(EnumX.one), isTrue);
    expect(3.hasFlag(EnumX.two), isTrue);
    expect(1.getFlags(EnumX.values), equals([EnumX.one]));
    expect(2.getFlags(EnumX.values), equals([EnumX.two]));
    expect((1 | 2).getFlags(EnumX.values), equals([EnumX.one, EnumX.two]));
    expect([EnumX.one].flag, equals(1));
    expect([EnumX.two].flag, equals(2));
    expect([EnumX.one, EnumX.two].flag, equals(1 | 2));
  });
}
