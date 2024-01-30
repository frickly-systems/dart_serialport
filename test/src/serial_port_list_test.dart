// ignore_for_file: prefer_const_constructors
import 'package:dart_serial/src/serial_port_list.dart';
import 'package:test/test.dart';

void main() {
  group('SerialPortListLinux', () {
    test('can list ports', () async {
      final ports = await SerialPortListLinux().listEntries();

      expect(ports, isNotEmpty);
    });
  });
}
