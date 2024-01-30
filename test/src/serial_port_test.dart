// ignore_for_file: prefer_const_constructors

import 'package:dart_serialport/src/serial_port/serial_port.dart';
import 'package:dart_serialport/src/serial_port/serial_port_linux.dart';
import 'package:test/test.dart';

// NOTE: This test must have two connected serial ports
// /tmp/ttyV0
// /tmp/ttyV1
// e.g. run: socat -d -d pty,rawer,echo=0,link=/tmp/ttyV0 pty,rawer,echo=0,link=/tmp/ttyV1
void main() {
  group('SerialPortLinux', () {
    final config1 = SerialPortConfig(port: '/tmp/ttyV0');
    late final SerialPortLinux port;

    final config2 = SerialPortConfig(port: '/tmp/ttyV1');
    late final SerialPortLinux port2;

    setUp(() async {
      port = SerialPortLinux(config1);
      port2 = SerialPortLinux(config2);
    });

    tearDown(() {
      port.close();
      port2.close();
    });

    test('can open port', () async {
      port.open();
    });

    test('can send data', () async {
      port
        ..open()
        ..write([1, 2, 3])
        ..flush();

      await Future<void>.delayed(Duration(milliseconds: 10));

      expect(port.outWaiting, 0);
    });

    test('can receive data', () async {
      port.open();

      port2
        ..open()
        ..write([1, 2, 3])
        ..flush();

      await Future<void>.delayed(Duration(milliseconds: 10));

      expect(port.read(3), [1, 2, 3]);
    });
  });
}
