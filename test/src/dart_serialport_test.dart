// ignore_for_file: prefer_const_constructors
import 'package:dart_serialport/dart_serialport.dart';
import 'package:test/test.dart';

void main() {
  group('DartSerialport', () {
    test('can be instantiated', () {
      expect(DartSerialport(), isNotNull);
    });

    test('can list ports', () async {
      final ports = await SerialPortList().info();

      for (final port
          in ports.where((element) => element.deviceName == 'ttyACM0')) {
        print(port.usbInformation);
      }
      expect(ports, isNotEmpty);
    });
  });
}
