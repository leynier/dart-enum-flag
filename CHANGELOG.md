# Changelog

## 3.0.0

### Breaking Changes

- Masks passed to the `int` extensions must be unsigned 32-bit values.
- Invalid flag positions now throw `RangeError` in all build modes.
- `label` uses the enum declaration name instead of parsing `toString()`.
- Descriptions now include unknown bits instead of reporting a non-zero
  unknown mask as `none`.

### New Features

- Added immutable, typed `FlagSet<T>` values with query and update operations.
- Added explicit `bitIndex` overrides for stable persisted masks while keeping
  index-based assignment as the default.
- Added unknown-bit inspection and preservation.
- Added checked signed 32-bit storage conversions.
- Added typed `Iterable<T>.flagSet` construction.

### Improvements

- `getFlags` and `describeFlags` now accept any `Iterable<T>`.
- Added VM and JavaScript coverage for the portable 32-bit boundary.
- Enforced 100% line coverage in CI with a reproducible local coverage gate.
- Kept the package compatible with Dart 3.0 while allowing current analysis
  and test tooling on newer SDKs.

## 2.0.1

### Improvements

- **Code quality**: Fixed all linting issues to comply with `very_good_analysis` standards.
- **CI/CD**: Updated GitHub Actions workflow to use latest versions (checkout@v4, codecov@v4).
- **Documentation**: Improved inline documentation formatting.

## 2.0.0

### Breaking Changes

- **`getFlags` now returns `List<T>` instead of `Iterable<EnumFlag>`**. This provides better type safety and convenience. Update your code if you were relying on the lazy evaluation of `Iterable`.
- **Renamed extensions**: `EnumFlagExtensor` → `EnumFlagExtension`, `EnumFlagsExtensor` → `EnumFlagsExtension`.
- **Minimum Dart SDK version is now 3.0.0**.

### New Features

- **Flag manipulation methods**: `addFlag()`, `removeFlag()`, `toggleFlag()` for immutable flag operations.
- **Bulk operations**: `addFlags()`, `removeFlags()`, `toggleFlags()` for manipulating multiple flags at once.
- **Null-safe extensions** (`NullableEnumFlagExtension` on `int?`): `hasFlagOrFalse()`, `hasAnyFlagOrFalse()`, `hasAllFlagsOrFalse()`, `orNoFlags()`.
- **`noFlags` constant**: Use `noFlags` (value `0`) to represent no active flags.
- **`all` getter**: Get the combined value of all flags in an iterable with `EnumX.values.all`.
- **`hasAnyFlag()` method**: Check if at least one of multiple flags is active.
- **`hasAllFlags()` method**: Check if all specified flags are active.
- **`label` property**: Get the enum name without the prefix (e.g., `EnumX.one.label` → `'one'`).
- **`binary` property**: Get the 8-character binary representation of a flag's value.
- **`describeFlags()` method**: Get a human-readable description of active flags for debugging.

### Improvements

- **Index assertion**: Added runtime assertion to ensure enum index is less than 32 (Dart int limitation).
- **Improved documentation**: All public APIs now have comprehensive doc comments with examples.
- **Expanded test coverage**: Tests now cover all new and existing functionality.

## 1.0.2

- Make `EnumFlag` a `mixin` over `Enum` instead of `abstract class` over `Object`
- Upgrade dependencies

## 1.0.1

- Add example
- Improve description of `pubspec.yaml`
- Improve description of `README.md`

## 1.0.0

- Initial release
