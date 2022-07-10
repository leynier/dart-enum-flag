# enum_flag

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

Package to create enum for flags.

## Usage

```dart
import 'package:enum_flag/enum_flag.dart';

enum EnumX with EnumFlag {
  one,
  two,
  three,
  four,
}

void main() {
    print(EnumX.one.value); // 1
    print(EnumX.two.value); // 2
    print(EnumX.three.value); // 4
    print(EnumX.four.value); // 8
    print(EnumX.one.value | EnumX.two.value); // 3
    print(EnumX.one.value | EnumX.three.value); // 5
    print(1.hasFlag(EnumX.one)); // true
    print(1.hasFlag(EnumX.two)); // false
    print(2.hasFlag(EnumX.one)); // false
    print(2.hasFlag(EnumX.two)); // true
    print(3.hasFlag(EnumX.one)); // true
    print(3.hasFlag(EnumX.two)); // true
    print(1.getFlags(EnumX.values)); // [EnumX.one]
    print(2.getFlags(EnumX.values)); // [EnumX.two]
    print((1 | 2).getFlags(EnumX.values)); // [EnumX.one, EnumX.two]
    print(3.getFlags(EnumX.values)); // [EnumX.one, EnumX.two]
    print([EnumX.one, EnumX.two].flag); // 3
}
```

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
