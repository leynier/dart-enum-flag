# enum_flag

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![Tests](https://github.com/leynier/dart-enum-flag/actions/workflows/tests.yml/badge.svg)](https://github.com/leynier/dart-enum-flag/actions/workflows/tests.yml)
[![Codecov](https://codecov.io/gh/leynier/dart-enum-flag/branch/main/graph/badge.svg)](https://codecov.io/gh/leynier/dart-enum-flag)

Portable, type-safe enum flags for Dart. Use the familiar `int` extensions or
an immutable `FlagSet<T>` while keeping the same unsigned 32-bit representation
on the Dart VM and JavaScript.

## Features

- Portable masks from `0` through `0xFFFFFFFF`.
- Stable explicit bit positions for databases and APIs.
- Convenient index-based flags for local, non-persisted state.
- Typed immutable `FlagSet<T>` operations.
- Backwards-compatible extensions on `int`, `int?`, and `Iterable`.
- Preservation and reporting of unknown bits for forward compatibility.
- Explicit conversion to and from signed 32-bit storage.

## Installation

```yaml
dependencies:
  enum_flag: ^3.0.0
```

## Defining flags

### Stable explicit positions

Declare `bitIndex` explicitly when a mask is persisted or exchanged with
another application. Members can then be reordered without changing their
stored values.

```dart
import 'package:enum_flag/enum_flag.dart';

enum Permission with EnumFlag {
  read(0),
  write(1),
  execute(2),
  delete(3);

  const Permission(this.bitIndex);

  @override
  final int bitIndex;
}
```

Every position must be unique and between 0 and 31. Invalid positions throw a
`RangeError` in every build mode, including JavaScript production builds.

### Index-based positions

For state that is never persisted, the mixin uses the declaration index by
default:

```dart
enum LocalFeature with EnumFlag {
  compactMode, // bitIndex: 0, value: 1
  diagnostics, // bitIndex: 1, value: 2
}
```

If these values are persisted, never reorder existing members or insert new
members before them. Only append new members, or migrate to explicit positions.

## Typed FlagSet API

Create an immutable, typed set from flags or from an unsigned mask:

```dart
final permissions = [Permission.read, Permission.execute].flagSet;
final restored = FlagSet<Permission>.fromBits(5);

print(permissions == restored); // true
print(permissions.bits); // 5
print(permissions.contains(Permission.read)); // true
print(permissions.activeFlags(Permission.values));
// [Permission.read, Permission.execute]
```

All updates return a new value:

```dart
final updated = permissions
    .add(Permission.write)
    .remove(Permission.execute)
    .toggle(Permission.delete);

print(updated.bits); // 11
```

Bulk operations are also available:

```dart
final updated = const FlagSet<Permission>.empty()
    .addAll([Permission.read, Permission.write])
    .toggleAll([Permission.write, Permission.execute])
    .removeAll([Permission.read]);

print(updated.bits); // 4
```

`FlagSet<T>` stores only the mask. Pass the enum's `values` list when an
operation needs to interpret all known members.

## int API

The v2-style extensions remain first-class APIs:

```dart
var bits = noFlags;
bits = bits.addFlag(Permission.read);
bits = bits.addFlags([Permission.write, Permission.execute]);
bits = bits.removeFlag(Permission.execute);

print(bits.hasFlag(Permission.read)); // true
print(bits.hasAnyFlag([Permission.execute, Permission.write])); // true
print(bits.hasAllFlags([Permission.read, Permission.write])); // true
print(bits.getFlags(Permission.values));
// [Permission.read, Permission.write]
```

Combine iterables into either representation:

```dart
final bits = [Permission.read, Permission.write].flag; // 3
final allBits = Permission.values.all; // 15
final set = [Permission.read, Permission.write].flagSet;
```

Nullable masks retain the v2 helpers:

```dart
int? storedBits;

storedBits.hasFlagOrFalse(Permission.read); // false
storedBits.hasAnyFlagOrFalse(Permission.values); // false
storedBits.hasAllFlagsOrFalse(Permission.values); // false
storedBits.orNoFlags(); // 0
```

## Unknown bits

Masks from a newer producer may contain positions the current enum does not
know. They are preserved through `FlagSet` operations and reported explicitly:

```dart
final permissions = FlagSet<Permission>.fromBits(0x13);

print(permissions.unknownBits(Permission.values)); // 16
print(permissions.describe(Permission.values));
// read | write | unknown(0x00000010)
```

The same behavior is available through `int.getUnknownBits()` and
`int.describeFlags()`.

## Signed 32-bit storage

The canonical representation is unsigned. Use explicit helpers for a database
column or protocol that represents the same bits as a signed 32-bit integer:

```dart
final stored = FlagSet<Permission>.fromSigned32(-1);

print(stored.bits); // 4294967295 (0xFFFFFFFF)
print(stored.signedBits); // -1
```

Values outside the corresponding signed or unsigned 32-bit range throw a
`RangeError`; they are never normalized silently.

## Debug properties

```dart
print(Permission.read.bitIndex); // 0
print(Permission.read.value); // 1
print(Permission.read.label); // read
print(Permission.read.binary); // 00000001
```

`label` always uses the enum declaration name, even if the enum overrides
`toString()`. `binary` is padded to at least eight characters and grows up to
32 characters for higher positions.

## Migrating from v2

Most calls continue to compile. Review these intentional changes:

- Masks and receivers must be unsigned 32-bit values. Convert signed storage
  with `FlagSet.fromSigned32`.
- A flag outside positions 0-31 now throws in release as well as debug builds.
- `label` uses the declaration name instead of parsing `toString()`.
- `describeFlags` reports unknown bits instead of returning `none` for a
  non-zero unknown mask.
- `getFlags` and `describeFlags` now accept any `Iterable<T>`.
- Persisted index-based enums should override `bitIndex` before members are
  reordered or inserted.

## Development and coverage

Run the same coverage gate used by CI:

```shell
dart test --coverage=coverage
dart run coverage:format_coverage \
  --lcov \
  --in=coverage \
  --out=coverage/lcov.info \
  --report-on=lib
dart run tool/check_coverage.dart
```

The final command fails unless every executable line under `lib` is covered.

## License

MIT License - see [LICENSE](LICENSE) for details.

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
