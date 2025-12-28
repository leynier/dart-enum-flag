// ignore_for_file: avoid_print

import 'package:enum_flag/enum_flag.dart';

enum Permission with EnumFlag {
  read,
  write,
  execute,
  delete,
}

void main() {
  // Basic bitmask values
  print('=== Basic Values ===');
  print('read.value: ${Permission.read.value}'); // 1
  print('write.value: ${Permission.write.value}'); // 2
  print('execute.value: ${Permission.execute.value}'); // 4
  print('delete.value: ${Permission.delete.value}'); // 8

  // Convenience properties
  print('\n=== Convenience Properties ===');
  print('read.label: ${Permission.read.label}'); // read
  print('read.binary: ${Permission.read.binary}'); // 00000001
  print('execute.binary: ${Permission.execute.binary}'); // 00000100

  // Combining flags
  print('\n=== Combining Flags ===');
  final readWrite = Permission.read.value | Permission.write.value;
  print('read | write = $readWrite'); // 3
  print('[read, write].flag = ${[Permission.read, Permission.write].flag}'); // 3
  print('All permissions: ${Permission.values.all}'); // 15

  // Checking flags
  print('\n=== Checking Flags ===');
  print('$readWrite hasFlag(read): ${readWrite.hasFlag(Permission.read)}'); // true
  print('$readWrite hasFlag(execute): ${readWrite.hasFlag(Permission.execute)}'); // false

  // hasAnyFlag and hasAllFlags
  print('\n=== hasAnyFlag / hasAllFlags ===');
  final flags = 3; // read | write
  print('$flags hasAnyFlag([read, execute]): '
      '${flags.hasAnyFlag([Permission.read, Permission.execute])}'); // true
  print('$flags hasAllFlags([read, write]): '
      '${flags.hasAllFlags([Permission.read, Permission.write])}'); // true
  print('$flags hasAllFlags([read, execute]): '
      '${flags.hasAllFlags([Permission.read, Permission.execute])}'); // false

  // Getting active flags
  print('\n=== Getting Flags ===');
  print('$flags getFlags: ${flags.getFlags(Permission.values)}'); // [read, write]
  print('7.getFlags: ${7.getFlags(Permission.values)}'); // [read, write, execute]

  // Manipulating flags
  print('\n=== Manipulating Flags ===');
  var userPermissions = noFlags;
  print('Initial: $userPermissions (noFlags)');

  userPermissions = userPermissions.addFlag(Permission.read);
  print('After addFlag(read): $userPermissions');

  userPermissions = userPermissions.addFlag(Permission.write);
  print('After addFlag(write): $userPermissions');

  userPermissions = userPermissions.removeFlag(Permission.read);
  print('After removeFlag(read): $userPermissions');

  userPermissions = userPermissions.toggleFlag(Permission.execute);
  print('After toggleFlag(execute): $userPermissions');

  userPermissions = userPermissions.toggleFlag(Permission.execute);
  print('After toggleFlag(execute) again: $userPermissions');

  // Describing flags (useful for debugging)
  print('\n=== Describing Flags ===');
  print('0: ${0.describeFlags(Permission.values)}'); // none
  print('3: ${3.describeFlags(Permission.values)}'); // read | write
  print('15: ${15.describeFlags(Permission.values)}'); // read | write | execute | delete
}
