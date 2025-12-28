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
  /// Return the bitmask value of this [EnumFlag].
  ///
  /// The value is calculated as `1 << index`, where index is the
  /// position of the enum value in the enum declaration.
  ///
  /// Note: Only supports up to 32 enum values (index 0-31) due to
  /// integer bit limitations.
  int get value {
    assert(
      index < 32,
      'EnumFlag only supports up to 32 values (index 0-31). '
      'Found index $index.',
    );
    return 1 << index;
  }

  /// The name of this flag without the enum prefix.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(EnumX.one.label); // 'one'
  /// ```
  String get label => toString().split('.').last;

  /// The binary representation of this flag's value.
  ///
  /// Returns an 8-character string padded with leading zeros.
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
  bool hasFlag(EnumFlag flag) => this & flag.value != 0;

  /// Returns true if this value has at least one of the given [flags] active.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(1.hasAnyFlag([EnumX.one, EnumX.two])); // true
  /// print(4.hasAnyFlag([EnumX.one, EnumX.two])); // false
  /// ```
  bool hasAnyFlag(Iterable<EnumFlag> flags) => flags.any(hasFlag);

  /// Returns true if this value has all of the given [flags] active.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(3.hasAllFlags([EnumX.one, EnumX.two])); // true
  /// print(1.hasAllFlags([EnumX.one, EnumX.two])); // false
  /// ```
  bool hasAllFlags(Iterable<EnumFlag> flags) => flags.every(hasFlag);

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
  List<T> getFlags<T extends EnumFlag>(List<T> flags) =>
      flags.where(hasFlag).toList();

  /// Returns a new value with the given [flag] added (bit set).
  ///
  /// Example:
  ///
  /// ```dart
  /// int flags = noFlags;
  /// flags = flags.addFlag(EnumX.one); // 1
  /// flags = flags.addFlag(EnumX.two); // 3
  /// ```
  int addFlag(EnumFlag flag) => this | flag.value;

  /// Returns a new value with the given [flag] removed (bit cleared).
  ///
  /// Example:
  ///
  /// ```dart
  /// int flags = 3; // one | two
  /// flags = flags.removeFlag(EnumX.one); // 2
  /// ```
  int removeFlag(EnumFlag flag) => this & ~flag.value;

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
  int toggleFlag(EnumFlag flag) => this ^ flag.value;

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
  int addFlags(Iterable<EnumFlag> flags) =>
      flags.fold(this, (value, flag) => value | flag.value);

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
  int removeFlags(Iterable<EnumFlag> flags) =>
      flags.fold(this, (value, flag) => value & ~flag.value);

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
  int toggleFlags(Iterable<EnumFlag> flags) =>
      flags.fold(this, (value, flag) => value ^ flag.value);

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
  String describeFlags<T extends EnumFlag>(List<T> allFlags) {
    final active = getFlags<T>(allFlags);
    if (active.isEmpty) return 'none';
    return active.map((f) => f.label).join(' | ');
  }
}

/// Extensions over [Iterable] of [EnumFlag] to combine flags.
extension EnumFlagsExtension on Iterable<EnumFlag> {
  /// Returns the combined bitmask value of all flags in this iterable.
  ///
  /// Example:
  ///
  /// ```dart
  /// print([EnumX.one, EnumX.two].flag); // 3
  /// ```
  int get flag => fold(0, (int value, EnumFlag flag) => value | flag.value);

  /// Alias for [flag]. Returns the combined bitmask value of all flags.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(EnumX.values.all); // 15 (1 | 2 | 4 | 8)
  /// ```
  int get all => flag;
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
