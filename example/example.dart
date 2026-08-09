// This executable demonstrates the package by printing each result.
// ignore_for_file: avoid_print

import 'package:enum_flag/enum_flag.dart';

// Explicit positions are recommended for persisted or external masks.
enum Permission with EnumFlag {
  read(0),
  write(1),
  execute(2),
  delete(3);

  const Permission(this.bitIndex);

  @override
  final int bitIndex;
}

// Index-based flags are convenient for values that are never persisted.
enum LocalFeature with EnumFlag {
  compactMode,
  diagnostics,
}

void main() {
  print('=== Stable bit values ===');
  print('read.value: ${Permission.read.value}'); // 1
  print('write.value: ${Permission.write.value}'); // 2
  print('execute.binary: ${Permission.execute.binary}'); // 00000100
  print('delete.label: ${Permission.delete.label}'); // delete

  print('\n=== int API ===');
  final readWrite = [Permission.read, Permission.write].flag;
  print('read | write: $readWrite'); // 3
  print('has read: ${readWrite.hasFlag(Permission.read)}'); // true
  print('has execute: ${readWrite.hasFlag(Permission.execute)}'); // false
  print(
    'active: ${readWrite.describeFlags(Permission.values)}',
  ); // read | write

  print('\n=== Typed FlagSet API ===');
  final permissions = [Permission.read, Permission.execute].flagSet;
  final updated = permissions
      .add(Permission.write)
      .remove(Permission.execute)
      .toggle(Permission.delete);
  print('bits: ${updated.bits}'); // 11
  print('contains write: ${updated.contains(Permission.write)}'); // true
  print('active: ${updated.activeFlags(Permission.values)}');

  print('\n=== Unknown and signed bits ===');
  final withUnknown = FlagSet<Permission>.fromBits(0x13);
  print(withUnknown.describe(Permission.values));
  // read | write | unknown(0x00000010)

  final signed = FlagSet<Permission>.fromSigned32(-1);
  print('unsigned: ${signed.bits}'); // 4294967295
  print('signed: ${signed.signedBits}'); // -1

  print('\n=== Index-based local flags ===');
  print(LocalFeature.values.all); // 3
}
