import 'package:enum_flag/enum_flag.dart';
import 'package:test/test.dart';

enum EnumX with EnumFlag {
  one,
  two,
  three,
  four,
}

void main() {
  group('EnumFlag mixin', () {
    test('value returns correct bitmask', () {
      expect(EnumX.one.value, equals(1));
      expect(EnumX.two.value, equals(2));
      expect(EnumX.three.value, equals(4));
      expect(EnumX.four.value, equals(8));
    });

    test('label returns enum name without prefix', () {
      expect(EnumX.one.label, equals('one'));
      expect(EnumX.two.label, equals('two'));
    });

    test('binary returns 8-character binary representation', () {
      expect(EnumX.one.binary, equals('00000001'));
      expect(EnumX.two.binary, equals('00000010'));
      expect(EnumX.three.binary, equals('00000100'));
      expect(EnumX.four.binary, equals('00001000'));
    });

    test('values can be combined with bitwise OR', () {
      expect(EnumX.one.value | EnumX.two.value, equals(3));
      expect(EnumX.one.value | EnumX.three.value, equals(5));
    });
  });

  group('noFlags constant', () {
    test('noFlags equals zero', () {
      expect(noFlags, equals(0));
    });

    test('noFlags has no active flags', () {
      expect(noFlags.hasFlag(EnumX.one), isFalse);
      expect(noFlags.hasFlag(EnumX.two), isFalse);
    });
  });

  group('EnumFlagExtension on int', () {
    group('hasFlag', () {
      test('returns true when flag is active', () {
        expect(1.hasFlag(EnumX.one), isTrue);
        expect(2.hasFlag(EnumX.two), isTrue);
        expect(3.hasFlag(EnumX.one), isTrue);
        expect(3.hasFlag(EnumX.two), isTrue);
      });

      test('returns false when flag is not active', () {
        expect(1.hasFlag(EnumX.two), isFalse);
        expect(2.hasFlag(EnumX.one), isFalse);
        expect(4.hasFlag(EnumX.one), isFalse);
      });
    });

    group('hasAnyFlag', () {
      test('returns true when at least one flag is active', () {
        expect(1.hasAnyFlag([EnumX.one, EnumX.two]), isTrue);
        expect(2.hasAnyFlag([EnumX.one, EnumX.two]), isTrue);
        expect(3.hasAnyFlag([EnumX.one, EnumX.two]), isTrue);
      });

      test('returns false when no flags are active', () {
        expect(4.hasAnyFlag([EnumX.one, EnumX.two]), isFalse);
        expect(8.hasAnyFlag([EnumX.one, EnumX.two]), isFalse);
      });

      test('returns false for empty flag list', () {
        expect(3.hasAnyFlag([]), isFalse);
      });
    });

    group('hasAllFlags', () {
      test('returns true when all flags are active', () {
        expect(3.hasAllFlags([EnumX.one, EnumX.two]), isTrue);
        expect(7.hasAllFlags([EnumX.one, EnumX.two, EnumX.three]), isTrue);
      });

      test('returns false when not all flags are active', () {
        expect(1.hasAllFlags([EnumX.one, EnumX.two]), isFalse);
        expect(2.hasAllFlags([EnumX.one, EnumX.two]), isFalse);
      });

      test('returns true for empty flag list', () {
        expect(0.hasAllFlags([]), isTrue);
      });
    });

    group('getFlags', () {
      test('returns list of active flags', () {
        expect(1.getFlags(EnumX.values), equals([EnumX.one]));
        expect(2.getFlags(EnumX.values), equals([EnumX.two]));
        expect(3.getFlags(EnumX.values), equals([EnumX.one, EnumX.two]));
      });

      test('returns empty list when no flags active', () {
        expect(0.getFlags(EnumX.values), isEmpty);
      });

      test('returns typed list', () {
        final flags = 3.getFlags(EnumX.values);
        expect(flags, isA<List<EnumX>>());
      });
    });

    group('addFlag', () {
      test('adds flag to value', () {
        expect(noFlags.addFlag(EnumX.one), equals(1));
        expect(1.addFlag(EnumX.two), equals(3));
        expect(3.addFlag(EnumX.three), equals(7));
      });

      test('adding existing flag is idempotent', () {
        expect(1.addFlag(EnumX.one), equals(1));
        expect(3.addFlag(EnumX.one), equals(3));
      });
    });

    group('removeFlag', () {
      test('removes flag from value', () {
        expect(3.removeFlag(EnumX.one), equals(2));
        expect(3.removeFlag(EnumX.two), equals(1));
        expect(7.removeFlag(EnumX.three), equals(3));
      });

      test('removing non-existent flag is idempotent', () {
        expect(1.removeFlag(EnumX.two), equals(1));
        expect(2.removeFlag(EnumX.one), equals(2));
      });
    });

    group('toggleFlag', () {
      test('toggles flag on when off', () {
        expect(0.toggleFlag(EnumX.one), equals(1));
        expect(1.toggleFlag(EnumX.two), equals(3));
      });

      test('toggles flag off when on', () {
        expect(1.toggleFlag(EnumX.one), equals(0));
        expect(3.toggleFlag(EnumX.two), equals(1));
      });

      test('double toggle returns to original', () {
        expect(0.toggleFlag(EnumX.one).toggleFlag(EnumX.one), equals(0));
        expect(5.toggleFlag(EnumX.two).toggleFlag(EnumX.two), equals(5));
      });
    });

    group('describeFlags', () {
      test('returns flag names joined by pipe', () {
        expect(1.describeFlags(EnumX.values), equals('one'));
        expect(3.describeFlags(EnumX.values), equals('one | two'));
        expect(7.describeFlags(EnumX.values), equals('one | two | three'));
      });

      test('returns "none" when no flags active', () {
        expect(0.describeFlags(EnumX.values), equals('none'));
      });
    });
  });

  group('EnumFlagsExtension on Iterable<EnumFlag>', () {
    group('flag', () {
      test('combines flags into single value', () {
        expect([EnumX.one].flag, equals(1));
        expect([EnumX.two].flag, equals(2));
        expect([EnumX.one, EnumX.two].flag, equals(3));
        expect([EnumX.one, EnumX.two, EnumX.three].flag, equals(7));
      });

      test('returns 0 for empty list', () {
        expect(<EnumX>[].flag, equals(0));
      });
    });

    group('all', () {
      test('returns combined value of all enum values', () {
        expect(EnumX.values.all, equals(15));
      });

      test('is equivalent to flag', () {
        expect(EnumX.values.all, equals(EnumX.values.flag));
      });
    });
  });

  group('Bulk operations', () {
    group('addFlags', () {
      test('adds multiple flags at once', () {
        expect(noFlags.addFlags([EnumX.one, EnumX.two]), equals(3));
        expect(
          noFlags.addFlags([EnumX.one, EnumX.two, EnumX.three]),
          equals(7),
        );
        expect(1.addFlags([EnumX.two, EnumX.three]), equals(7));
      });

      test('adding existing flags is idempotent', () {
        expect(3.addFlags([EnumX.one, EnumX.two]), equals(3));
      });

      test('adding empty list returns same value', () {
        expect(5.addFlags([]), equals(5));
      });
    });

    group('removeFlags', () {
      test('removes multiple flags at once', () {
        expect(7.removeFlags([EnumX.one, EnumX.two]), equals(4));
        expect(15.removeFlags([EnumX.one, EnumX.three]), equals(10));
      });

      test('removing non-existent flags is idempotent', () {
        expect(1.removeFlags([EnumX.two, EnumX.three]), equals(1));
      });

      test('removing empty list returns same value', () {
        expect(5.removeFlags([]), equals(5));
      });
    });

    group('toggleFlags', () {
      test('toggles multiple flags at once', () {
        expect(0.toggleFlags([EnumX.one, EnumX.two]), equals(3));
        expect(1.toggleFlags([EnumX.one, EnumX.two]), equals(2));
        expect(3.toggleFlags([EnumX.one, EnumX.two]), equals(0));
      });

      test('toggling empty list returns same value', () {
        expect(5.toggleFlags([]), equals(5));
      });
    });
  });

  group('NullableEnumFlagExtension on int?', () {
    group('hasFlagOrFalse', () {
      test('returns false when null', () {
        const int? nullFlags = null;
        expect(nullFlags.hasFlagOrFalse(EnumX.one), isFalse);
      });

      test('returns correct value when not null', () {
        const flags = 3;
        expect(flags.hasFlagOrFalse(EnumX.one), isTrue);
        expect(flags.hasFlagOrFalse(EnumX.three), isFalse);
      });
    });

    group('hasAnyFlagOrFalse', () {
      test('returns false when null', () {
        const int? nullFlags = null;
        expect(nullFlags.hasAnyFlagOrFalse([EnumX.one, EnumX.two]), isFalse);
      });

      test('returns correct value when not null', () {
        const flags = 1;
        expect(flags.hasAnyFlagOrFalse([EnumX.one, EnumX.two]), isTrue);
        expect(flags.hasAnyFlagOrFalse([EnumX.three, EnumX.four]), isFalse);
      });
    });

    group('hasAllFlagsOrFalse', () {
      test('returns false when null', () {
        const int? nullFlags = null;
        expect(nullFlags.hasAllFlagsOrFalse([EnumX.one, EnumX.two]), isFalse);
      });

      test('returns correct value when not null', () {
        const flags = 3;
        expect(flags.hasAllFlagsOrFalse([EnumX.one, EnumX.two]), isTrue);
        expect(flags.hasAllFlagsOrFalse([EnumX.one, EnumX.three]), isFalse);
      });
    });

    group('orNoFlags', () {
      test('returns noFlags when null', () {
        const int? nullFlags = null;
        expect(nullFlags.orNoFlags(), equals(noFlags));
        expect(nullFlags.orNoFlags(), equals(0));
      });

      test('returns value when not null', () {
        const flags = 5;
        expect(flags.orNoFlags(), equals(5));
      });
    });
  });
}
