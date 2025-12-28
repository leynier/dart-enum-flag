# enum_flag

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![Tests](https://github.com/leynier/dart-enum-flag/actions/workflows/tests.yml/badge.svg)](https://github.com/leynier/dart-enum-flag/actions/workflows/tests.yml)
[![Codecov](https://codecov.io/gh/leynier/dart-enum-flag/branch/main/graph/badge.svg?token=Llxe6rjE9g)](https://codecov.io/gh/leynier/dart-enum-flag)

A Dart package to create enums for flags using bitmasks, with a mixin and extensions for easy flag manipulation.

## Features

- 🎯 **Type-safe bitmask values** via `EnumFlag` mixin
- ⚡ **Flag manipulation**: `addFlag()`, `removeFlag()`, `toggleFlag()`
- 🔍 **Flag checking**: `hasFlag()`, `hasAnyFlag()`, `hasAllFlags()`
- 📋 **Flag retrieval**: `getFlags()` with generic type support
- 🛠️ **Debugging utilities**: `label`, `binary`, `describeFlags()`
- 📦 **Constants**: `noFlags` for empty state, `all` for combined flags

## Use Cases

Bitmask flags are ideal when you need to store multiple boolean options in a single integer value. Common scenarios include:

### 🔐 File/Resource Permissions

```dart
enum Permission with EnumFlag { read, write, execute, delete }

// Store user permissions in a single int (e.g., in a database)
final adminPermissions = Permission.values.all; // 15
final guestPermissions = [Permission.read].flag; // 1

// Check access
if (userPermissions.hasFlag(Permission.write)) {
  // Allow editing
}
```

### 👥 User Roles & Capabilities

```dart
enum Role with EnumFlag { viewer, editor, moderator, admin }

// Users can have multiple roles
final userRoles = [Role.editor, Role.moderator].flag;

if (userRoles.hasAnyFlag([Role.admin, Role.moderator])) {
  // Show moderation panel
}
```

### 🚀 Feature Flags

```dart
enum Feature with EnumFlag { darkMode, notifications, analytics, betaFeatures }

// Enable features per user or environment
var enabledFeatures = noFlags;
enabledFeatures = enabledFeatures.addFlag(Feature.darkMode);
enabledFeatures = enabledFeatures.addFlag(Feature.notifications);

// Check feature availability
if (enabledFeatures.hasFlag(Feature.betaFeatures)) {
  // Show experimental UI
}
```

### 🎮 Game States & Attributes

```dart
enum StatusEffect with EnumFlag { poisoned, burning, frozen, stunned, blessed }

// Apply multiple status effects to a character
var playerStatus = noFlags;
playerStatus = playerStatus.addFlag(StatusEffect.poisoned);
playerStatus = playerStatus.addFlag(StatusEffect.burning);

// Check and display active effects
print('Active: ${playerStatus.describeFlags(StatusEffect.values)}');
// Output: 'Active: poisoned | burning'

// Remove effect when healed
playerStatus = playerStatus.removeFlag(StatusEffect.poisoned);
```

### 📡 API Response Filtering

```dart
enum IncludeField with EnumFlag { metadata, timestamps, relations, stats }

// Client requests specific fields
final requestedFields = [IncludeField.metadata, IncludeField.stats].flag;

// Server checks what to include
if (requestedFields.hasFlag(IncludeField.relations)) {
  // Load and include related entities
}
```

## Installation

```yaml
dependencies:
  enum_flag: ^2.0.0
```

## Usage

### Basic Setup

```dart
import 'package:enum_flag/enum_flag.dart';

enum Permission with EnumFlag {
  read,    // value: 1 (binary: 00000001)
  write,   // value: 2 (binary: 00000010)
  execute, // value: 4 (binary: 00000100)
  delete,  // value: 8 (binary: 00001000)
}
```

### Getting Bitmask Values

```dart
print(Permission.read.value);   // 1
print(Permission.write.value);  // 2
print(Permission.read.binary);  // '00000001'
print(Permission.read.label);   // 'read'
```

### Combining Flags

```dart
// Using bitwise OR
final flags = Permission.read.value | Permission.write.value; // 3

// Using list extension
final flags = [Permission.read, Permission.write].flag; // 3

// Get all enum values combined
final allFlags = Permission.values.all; // 15
```

### Checking Flags

```dart
final flags = 3; // read | write

flags.hasFlag(Permission.read);     // true
flags.hasFlag(Permission.execute);  // false

flags.hasAnyFlag([Permission.read, Permission.execute]); // true
flags.hasAllFlags([Permission.read, Permission.write]);  // true
```

### Retrieving Active Flags

```dart
final flags = 3;
List<Permission> active = flags.getFlags(Permission.values);
print(active); // [Permission.read, Permission.write]
```

### Manipulating Flags

```dart
var flags = noFlags; // Start with no flags (0)

flags = flags.addFlag(Permission.read);    // 1
flags = flags.addFlag(Permission.write);   // 3
flags = flags.removeFlag(Permission.read); // 2
flags = flags.toggleFlag(Permission.write); // 0
```

### Bulk Operations

```dart
// Add multiple flags at once
var flags = noFlags.addFlags([Permission.read, Permission.write, Permission.execute]); // 7

// Remove multiple flags at once
flags = flags.removeFlags([Permission.read, Permission.execute]); // 2

// Toggle multiple flags at once
flags = flags.toggleFlags([Permission.write, Permission.delete]); // 8
```

### Null-Safe Operations

```dart
int? userFlags = getUserFromDatabase()?.permissions; // May be null

// Safe flag checking (returns false if null)
if (userFlags.hasFlagOrFalse(Permission.read)) {
  // User has read permission
}

// Safe with multiple flags
userFlags.hasAnyFlagOrFalse([Permission.read, Permission.write]); // false if null
userFlags.hasAllFlagsOrFalse([Permission.read, Permission.write]); // false if null

// Get value or default to noFlags
final safeFlags = userFlags.orNoFlags(); // 0 if null
```

### Debugging

```dart
print(3.describeFlags(Permission.values)); // 'read | write'
print(0.describeFlags(Permission.values)); // 'none'
```

## API Reference

### `EnumFlag` Mixin

| Property | Description |
|----------|-------------|
| `value` | Bitmask value (`1 << index`) |
| `label` | Enum name without prefix |
| `binary` | 8-character binary string |

### `int` Extensions

| Method | Description |
|--------|-------------|
| `hasFlag(flag)` | Check if single flag is active |
| `hasAnyFlag(flags)` | Check if any flag is active |
| `hasAllFlags(flags)` | Check if all flags are active |
| `getFlags<T>(flags)` | Get list of active flags |
| `addFlag(flag)` | Return value with flag added |
| `removeFlag(flag)` | Return value with flag removed |
| `toggleFlag(flag)` | Return value with flag toggled |
| `addFlags(flags)` | Add multiple flags at once |
| `removeFlags(flags)` | Remove multiple flags at once |
| `toggleFlags(flags)` | Toggle multiple flags at once |
| `describeFlags<T>(flags)` | Human-readable description |

### `int?` Extensions (Null-Safe)

| Method | Description |
|--------|-------------|
| `hasFlagOrFalse(flag)` | Check flag, returns false if null |
| `hasAnyFlagOrFalse(flags)` | Check any flag, returns false if null |
| `hasAllFlagsOrFalse(flags)` | Check all flags, returns false if null |
| `orNoFlags()` | Returns value or 0 if null |

### Constants & Extensions

| Name | Description |
|------|-------------|
| `noFlags` | Constant `0` for empty state |
| `Iterable<EnumFlag>.flag` | Combined bitmask value |
| `Iterable<EnumFlag>.all` | Alias for `flag` |

## Limitations

- Maximum of 32 enum values (due to Dart's 32-bit integer operations in JavaScript)
- An assertion will fail in debug mode if you exceed this limit

## License

MIT License - see [LICENSE](LICENSE) for details.

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
