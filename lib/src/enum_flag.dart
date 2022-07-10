/// Abstract class for use how mixin for [Enum] flags
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
abstract class EnumFlag extends Object {
  /// Abstract property that returns the [Enum] value
  int get index;

  /// Return the value of the [EnumFlag]
  int get value => 1 << index;
}

/// Extensions over [int] to support [EnumFlag]
extension EnumFlagExtensor on int {
  /// Returns true if the [int] value has active the bit of [flag]
  ///
  /// Example:
  ///
  /// ```dart
  /// enum EnumX with EnumFlag {
  ///   one,
  ///   two,
  /// }
  ///
  /// ...
  ///
  /// print(1.hasFlag(EnumX.one)); // true
  /// print(1.hasFlag(EnumX.two)); // false
  /// print(2.hasFlag(EnumX.one)); // false
  /// print(2.hasFlag(EnumX.two)); // true
  /// print(3.hasFlag(EnumX.one)); // true
  /// print(3.hasFlag(EnumX.two)); // true
  /// ```
  bool hasFlag(EnumFlag flag) => this & flag.value != 0;

  /// Returns a [Iterable] of [EnumFlag] that are active in the [int] value
  ///
  /// Example:
  ///
  /// ```dart
  /// enum EnumX with EnumFlag {
  ///   one,
  ///   two,
  /// }
  ///
  /// ...
  ///
  /// print(1.getFlags(EnumX.values)); // [EnumX.one]
  /// print(2.getFlags(EnumX.values)); // [EnumX.two]
  /// print((1 | 2).getFlags(EnumX.values)); // [EnumX.one, EnumX.two]
  /// print(3.getFlags(EnumX.values)); // [EnumX.one, EnumX.two]
  /// ```
  Iterable<EnumFlag> getFlags(Iterable<EnumFlag> flags) => flags.where(hasFlag);
}

/// Extensions over [Iterable] of [EnumFlag] to support [EnumFlag]
extension EnumFlagsExtensor on Iterable<EnumFlag> {
  /// Returns the [int] with the active bits of the [Iterable] of [EnumFlag]
  ///
  /// Example:
  ///
  /// ```dart
  /// enum EnumX with EnumFlag {
  ///   one,
  ///   two,
  /// }
  ///
  /// ...
  ///
  /// print([EnumX.one, EnumX.two].flag); // 3
  /// ```
  int get flag => fold(0, (int value, EnumFlag flag) => value | flag.value);
}
