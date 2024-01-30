// ignore_for_file: prefer_const_constructors
import 'package:dart_serialport/dart_serialport.dart';
import 'package:dart_serialport/src/serial_port_list.dart';
import 'package:test/test.dart';
import 'package:linux_serial/linux_serial.dart' as ls;

void main() {
  group('DartSerialport', () {
    test('can list ports', () async {
      final ports = await SerialPortListLinux().listEntries();

      for (final port
          in ports.where((element) => element.deviceName == 'ttyACM0')) {
        print(port as USBDeviceInformation);
      }
      expect(ports, isNotEmpty);
    });

    test('linux serial test', () async {
      final l = ls.SerialPorts.ports;
      for (final port in l) {
        print(port);
      }
    });
  });
}
