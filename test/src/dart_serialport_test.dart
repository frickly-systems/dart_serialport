// ignore_for_file: prefer_const_constructors
import 'package:test/test.dart';
import 'package:dart_serialport/dart_serialport.dart';

void main() {
  group('DartSerialport', () {
    test('can be instantiated', () {
      expect(DartSerialport(), isNotNull);
    });
  });
}
