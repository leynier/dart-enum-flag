import 'package:meta/meta.dart';

/// Constant representing no flags set (value 0).
///
/// Use this to initialize or compare against an empty flag state.
///
/// Example:
///
/// ```dart
/// int flags = noFlags; // 0
/// print(flags == noFlags); // true
/// ```
const int noFlags = 0;

const int _maxBitIndex = 31;
const int _maxBits = 0xFFFFFFFF;
const int _minSigned32 = -0x80000000;
const int _maxSigned32 = 0x7FFFFFFF;

int _validateBitIndex(int bitIndex) {
  if (bitIndex < 0 || bitIndex > _maxBitIndex) {
    throw RangeError.range(bitIndex, 0, _maxBitIndex, 'bitIndex');
  }
  return bitIndex;
}

int _validateBits(int bits) {
  if (bits < noFlags || bits > _maxBits) {
    throw RangeError.range(bits, noFlags, _maxBits, 'bits');
  }
  return bits;
}

int _validateSigned32(int bits) {
  if (bits < _minSigned32 || bits > _maxSigned32) {
    throw RangeError.range(bits, _minSigned32, _maxSigned32, 'bits');
  }
  return bits;
}

_ValidatedFlags<T> _validateFlags<T extends EnumFlag>(Iterable<T> flags) {
  final values = <T>[];
  final positions = <int, T>{};
  var bits = noFlags;

  for (final flag in flags) {
    final bitIndex = _validateBitIndex(flag.bitIndex);
    final previous = positions[bitIndex];
    if (previous != null && previous != flag) {
      throw StateError(
        'Enum flags $previous and $flag both use bitIndex $bitIndex.',
      );
    }
    positions[bitIndex] = flag;
    values.add(flag);
    bits |= flag.value;
  }

  return _ValidatedFlags(values, bits);
}

final class _ValidatedFlags<T extends EnumFlag> {
  const _ValidatedFlags(this.values, this.bits);

  final List<T> values;
  final int bits;
}

/// Mixin for [Enum] flags
///
/// Example:
///
/// ```dart
/// enum EnumX with EnumFlag {
///   one,
///   two,
///   three,
///   four,
/// }
///
/// print(EnumX.one.value); // 1
/// print(EnumX.two.value); // 2
/// print(EnumX.three.value); // 4
/// print(EnumX.four.value); // 8
/// print(EnumX.one.value | EnumX.two.value); // 3
/// print(EnumX.one.value | EnumX.three.value); // 5
/// ```
mixin EnumFlag on Enum {
  /// The position of this flag in its 32-bit mask.
  ///
  /// By default this is the enum's declaration [index]. Override this getter
  /// with an explicit value when masks are persisted or exchanged externally,
  /// so reordering enum members cannot change their stored representation.
  int get bitIndex => index;

  /// Return the bitmask value of this [EnumFlag].
  ///
  /// The value is calculated as `1 << bitIndex`.
  ///
  /// Throws a [RangeError] when [bitIndex] is outside the portable range
  /// 0-31.
  int get value => 1 << _validateBitIndex(bitIndex);

  /// The name of this flag without the enum prefix.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(EnumX.one.label); // 'one'
  /// ```
  String get label => name;

  /// The binary representation of this flag's value.
  ///
  /// Returns a string padded to at least 8 characters with leading zeros.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(EnumX.one.binary); // '00000001'
  /// print(EnumX.two.binary); // '00000010'
  /// print(EnumX.three.binary); // '00000100'
  /// ```
  String get binary => value.toRadixString(2).padLeft(8, '0');
}

/// Extensions over [int] to support [EnumFlag] operations.
extension EnumFlagExtension on int {
  /// Returns true if this value has the bit of [flag] active.
  ///
  /// Example:
  ///
  /// ```dart
  /// enum EnumX with EnumFlag {
  ///   one,
  ///   two,
  /// }
  ///
  /// print(1.hasFlag(EnumX.one)); // true
  /// print(1.hasFlag(EnumX.two)); // false
  /// print(2.hasFlag(EnumX.one)); // false
  /// print(2.hasFlag(EnumX.two)); // true
  /// print(3.hasFlag(EnumX.one)); // true
  /// print(3.hasFlag(EnumX.two)); // true
  /// ```
  bool hasFlag(EnumFlag flag) => _validateBits(this) & flag.value != 0;

  /// Returns true if this value has at least one of the given [flags] active.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(1.hasAnyFlag([EnumX.one, EnumX.two])); // true
  /// print(4.hasAnyFlag([EnumX.one, EnumX.two])); // false
  /// ```
  bool hasAnyFlag(Iterable<EnumFlag> flags) {
    _validateBits(this);
    final validated = _validateFlags(flags);
    return validated.values.any(hasFlag);
  }

  /// Returns true if this value has all of the given [flags] active.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(3.hasAllFlags([EnumX.one, EnumX.two])); // true
  /// print(1.hasAllFlags([EnumX.one, EnumX.two])); // false
  /// ```
  bool hasAllFlags(Iterable<EnumFlag> flags) {
    _validateBits(this);
    final validated = _validateFlags(flags);
    return validated.values.every(hasFlag);
  }

  /// Returns a [List] of flags that are active in this value.
  ///
  /// The returned list preserves the type [T] of the input flags.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(1.getFlags(EnumX.values)); // [EnumX.one]
  /// print(2.getFlags(EnumX.values)); // [EnumX.two]
  /// print(3.getFlags(EnumX.values)); // [EnumX.one, EnumX.two]
  /// ```
  List<T> getFlags<T extends EnumFlag>(Iterable<T> flags) {
    _validateBits(this);
    final validated = _validateFlags(flags);
    return validated.values.where(hasFlag).toList();
  }

  /// Returns a new value with the given [flag] added (bit set).
  ///
  /// Example:
  ///
  /// ```dart
  /// int flags = noFlags;
  /// flags = flags.addFlag(EnumX.one); // 1
  /// flags = flags.addFlag(EnumX.two); // 3
  /// ```
  int addFlag(EnumFlag flag) => _validateBits(this) | flag.value;

  /// Returns a new value with the given [flag] removed (bit cleared).
  ///
  /// Example:
  ///
  /// ```dart
  /// int flags = 3; // one | two
  /// flags = flags.removeFlag(EnumX.one); // 2
  /// ```
  int removeFlag(EnumFlag flag) => _validateBits(this) & ~flag.value;

  /// Returns a new value with the given [flag] toggled (bit flipped).
  ///
  /// If the flag is active, it will be deactivated. If it's inactive,
  /// it will be activated.
  ///
  /// Example:
  ///
  /// ```dart
  /// int flags = 1; // one
  /// flags = flags.toggleFlag(EnumX.one); // 0
  /// flags = flags.toggleFlag(EnumX.one); // 1
  /// ```
  int toggleFlag(EnumFlag flag) => _validateBits(this) ^ flag.value;

  /// Returns a new value with all the given [flags] added (bits set).
  ///
  /// This is a convenience method for adding multiple flags at once.
  ///
  /// Example:
  ///
  /// ```dart
  /// int flags = noFlags;
  /// flags = flags.addFlags([EnumX.one, EnumX.two, EnumX.three]); // 7
  /// ```
  int addFlags(Iterable<EnumFlag> flags) {
    final validated = _validateFlags(flags);
    return _validateBits(this) | validated.bits;
  }

  /// Returns a new value with all the given [flags] removed (bits cleared).
  ///
  /// This is a convenience method for removing multiple flags at once.
  ///
  /// Example:
  ///
  /// ```dart
  /// int flags = 7; // one | two | three
  /// flags = flags.removeFlags([EnumX.one, EnumX.three]); // 2
  /// ```
  int removeFlags(Iterable<EnumFlag> flags) {
    final validated = _validateFlags(flags);
    return _validateBits(this) & ~validated.bits;
  }

  /// Returns a new value with all the given [flags] toggled (bits flipped).
  ///
  /// This is a convenience method for toggling multiple flags at once.
  ///
  /// Example:
  ///
  /// ```dart
  /// int flags = 1; // one
  /// flags = flags.toggleFlags([EnumX.one, EnumX.two]); // 2 (one off, two on)
  /// ```
  int toggleFlags(Iterable<EnumFlag> flags) {
    final validated = _validateFlags(flags);
    return validated.values.fold(
      _validateBits(this),
      (bits, flag) => bits ^ flag.value,
    );
  }

  /// Returns the bits that do not correspond to any of [allFlags].
  int getUnknownBits(Iterable<EnumFlag> allFlags) {
    final validated = _validateFlags(allFlags);
    return _validateBits(this) & (~validated.bits & _maxBits);
  }

  /// Returns a human-readable description of the active flags.
  ///
  /// Useful for debugging and logging purposes.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(3.describeFlags(EnumX.values)); // 'one | two'
  /// print(0.describeFlags(EnumX.values)); // 'none'
  /// ```
  String describeFlags<T extends EnumFlag>(Iterable<T> allFlags) {
    final validated = _validateFlags(allFlags);
    final bits = _validateBits(this);
    if (bits == noFlags) return 'none';

    final parts = validated.values
        .where((flag) => bits & flag.value != 0)
        .map((flag) => flag.label)
        .toList();
    final unknown = bits & (~validated.bits & _maxBits);
    if (unknown != noFlags) {
      final hexadecimal = unknown.toRadixString(16).padLeft(8, '0');
      parts.add('unknown(0x$hexadecimal)');
    }
    return parts.join(' | ');
  }
}

/// Extensions over [Iterable] of [EnumFlag] to combine flags.
extension EnumFlagsExtension<T extends EnumFlag> on Iterable<T> {
  /// Returns the combined bitmask value of all flags in this iterable.
  ///
  /// Example:
  ///
  /// ```dart
  /// print([EnumX.one, EnumX.two].flag); // 3
  /// ```
  int get flag => _validateFlags(this).bits;

  /// Alias for [flag]. Returns the combined bitmask value of all flags.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(EnumX.values.all); // 15 (1 | 2 | 4 | 8)
  /// ```
  int get all => flag;

  /// Returns these flags as an immutable, typed [FlagSet].
  FlagSet<T> get flagSet => FlagSet<T>.of(this);
}

/// An immutable, type-safe set of enum flags backed by a portable 32-bit mask.
///
/// The canonical [bits] representation is unsigned and ranges from 0 through
/// `0xFFFFFFFF`. Use [FlagSet.fromSigned32] and [signedBits] when
/// interoperating with storage that uses signed 32-bit integers.
@immutable
final class FlagSet<T extends EnumFlag> {
  /// Creates an empty flag set.
  const FlagSet.empty() : bits = noFlags;

  /// Creates a flag set from its unsigned 32-bit [bits].
  FlagSet.fromBits(int bits) : bits = _validateBits(bits);

  /// Creates a flag set from a signed 32-bit representation.
  factory FlagSet.fromSigned32(int bits) {
    final signedBits = _validateSigned32(bits);
    return FlagSet<T>.fromBits(signedBits.toUnsigned(32));
  }

  /// Creates a flag set containing [flags].
  factory FlagSet.of(Iterable<T> flags) =>
      FlagSet<T>.fromBits(_validateFlags(flags).bits);

  /// The canonical unsigned 32-bit representation of this set.
  final int bits;

  /// This mask represented as a signed 32-bit integer.
  int get signedBits => bits.toSigned(32);

  /// Whether no bits are set.
  bool get isEmpty => bits == noFlags;

  /// Whether at least one bit is set.
  bool get isNotEmpty => !isEmpty;

  /// Whether [flag] is active.
  bool contains(T flag) => bits.hasFlag(flag);

  /// Whether at least one of [flags] is active.
  bool containsAny(Iterable<T> flags) => bits.hasAnyFlag(flags);

  /// Whether all [flags] are active.
  bool containsAll(Iterable<T> flags) => bits.hasAllFlags(flags);

  /// Returns the active known flags from [allFlags].
  List<T> activeFlags(Iterable<T> allFlags) => bits.getFlags(allFlags);

  /// Returns the bits that do not correspond to [allFlags].
  int unknownBits(Iterable<T> allFlags) => bits.getUnknownBits(allFlags);

  /// Returns a human-readable description using [allFlags].
  String describe(Iterable<T> allFlags) => bits.describeFlags(allFlags);

  /// Returns a set with [flag] added.
  FlagSet<T> add(T flag) => FlagSet<T>.fromBits(bits.addFlag(flag));

  /// Returns a set with [flag] removed.
  FlagSet<T> remove(T flag) => FlagSet<T>.fromBits(bits.removeFlag(flag));

  /// Returns a set with [flag] toggled.
  FlagSet<T> toggle(T flag) => FlagSet<T>.fromBits(bits.toggleFlag(flag));

  /// Returns a set with [flags] added.
  FlagSet<T> addAll(Iterable<T> flags) =>
      FlagSet<T>.fromBits(bits.addFlags(flags));

  /// Returns a set with [flags] removed.
  FlagSet<T> removeAll(Iterable<T> flags) =>
      FlagSet<T>.fromBits(bits.removeFlags(flags));

  /// Returns a set with [flags] toggled.
  FlagSet<T> toggleAll(Iterable<T> flags) =>
      FlagSet<T>.fromBits(bits.toggleFlags(flags));

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FlagSet<T> && bits == other.bits;

  @override
  int get hashCode => Object.hash(runtimeType, bits);

  @override
  String toString() {
    final hexadecimal = bits.toRadixString(16).padLeft(8, '0');
    return 'FlagSet<$T>(0x$hexadecimal)';
  }
}

/// Null-safe extensions over [int?] to support [EnumFlag] operations.
///
/// These extensions provide safe access to flag operations when the value
/// might be null, returning sensible defaults instead of throwing.
extension NullableEnumFlagExtension on int? {
  /// Returns true if this value has the [flag] active, or false if null.
  ///
  /// Example:
  ///
  /// ```dart
  /// int? flags = null;
  /// print(flags.hasFlagOrFalse(EnumX.one)); // false
  ///
  /// flags = 3;
  /// print(flags.hasFlagOrFalse(EnumX.one)); // true
  /// ```
  bool hasFlagOrFalse(EnumFlag flag) => this?.hasFlag(flag) ?? false;

  /// Returns true if this value has any of the [flags] active,
  /// or false if null.
  ///
  /// Example:
  ///
  /// ```dart
  /// int? flags = null;
  /// print(flags.hasAnyFlagOrFalse([EnumX.one, EnumX.two])); // false
  /// ```
  bool hasAnyFlagOrFalse(Iterable<EnumFlag> flags) =>
      this?.hasAnyFlag(flags) ?? false;

  /// Returns true if this value has all [flags] active, or false if null.
  ///
  /// Example:
  ///
  /// ```dart
  /// int? flags = null;
  /// print(flags.hasAllFlagsOrFalse([EnumX.one, EnumX.two])); // false
  /// ```
  bool hasAllFlagsOrFalse(Iterable<EnumFlag> flags) =>
      this?.hasAllFlags(flags) ?? false;

  /// Returns this value if not null, otherwise returns [noFlags] (0).
  ///
  /// Example:
  ///
  /// ```dart
  /// int? flags = null;
  /// print(flags.orNoFlags()); // 0
  ///
  /// flags = 3;
  /// print(flags.orNoFlags()); // 3
  /// ```
  int orNoFlags() => this ?? noFlags;
}
