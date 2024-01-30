// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'package:dart_serialport/dart_serialport.dart';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

@immutable
sealed class SerialPortList {
  factory SerialPortList() {
    if (Platform.isLinux) {
      return const SerialPortListLinux();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future<Iterable<SerialDeviceInformation>> listEntries();
}

@immutable
class SerialPortListLinux implements SerialPortList {
  const SerialPortListLinux();

  static final _deviceFilter = [
    Glob('/dev/ttyS*'),
    Glob('/dev/ttyUSB*'),
    Glob('/dev/ttyXRUSB*'),
    Glob('/dev/ttyACM*'),
    Glob('/dev/ttyAMA*'),
    Glob('/dev/rfcomm*'),
    Glob('/dev/ttyAP*'),
    Glob('/dev/ttyGS*'),
  ];

  @override
  Future<Iterable<SerialDeviceInformation>> listEntries() {
    bool isSerialDevice(File file) {
      final path = file.path;
      return _deviceFilter.any((filter) => filter.matches(path));
    }

    final rawDevices = Directory('/dev')
        .listSync()
        .whereType<File>()
        .where(isSerialDevice)
        .toList();

    final devices = rawDevices.map(
      (device) {
        final deviceName = path.basename(device.path);
        return _toDeviceInfo(deviceName);
      },
    );

    return Future.value(devices);
  }

  SerialDeviceInformation _toDeviceInfo(String deviceName) {
    final devicePath = Directory(
      Directory('/sys/class/tty/$deviceName/device')
          .absolute
          .resolveSymbolicLinksSync(),
    );

    if (!devicePath.existsSync()) {
      return SerialDeviceInformation(
        devicePath: null,
        deviceName: deviceName,
      );
    }

    final subsystem = path.basename(
      Directory(path.join(devicePath.path, 'subsystem'))
          .absolute
          .resolveSymbolicLinksSync(),
    );

    if (subsystem == 'usb' || subsystem == 'usb-serial') {
      return _generateUSBDeviceInformation(
        devicePath: devicePath,
        deviceName: deviceName,
        subsystem: subsystem,
      );
    }

    return SerialDeviceInformation(
      devicePath: devicePath,
      deviceName: deviceName,
    );
  }

  USBDeviceInformation _generateUSBDeviceInformation({
    required String deviceName,
    required Directory devicePath,
    required String subsystem,
  }) {
    Directory usbInterfacePath() {
      if (subsystem == 'usb') {
        return devicePath;
      }

      return devicePath.parent;
    }

    final usbDevicePath = usbInterfacePath().parent;
    String readProperty(String property, {Directory? basepath}) {
      final propertyFile =
          File(path.join((basepath ?? usbDevicePath).path, property));
      if (propertyFile.existsSync()) {
        return propertyFile.readAsLinesSync().first;
      }
      return '';
    }

    final numberOfInterfaces =
        int.tryParse(readProperty('bNumInterfaces')) ?? 1;
    final vid = int.parse(readProperty('idVendor'), radix: 16);
    final pid = int.parse(readProperty('idProduct'), radix: 16);
    final serialNumber = readProperty('serial');
    final manufacturer = readProperty('manufacturer');
    final product = readProperty('product');
    final interface = readProperty('interface', basepath: usbInterfacePath());

    final location =
        numberOfInterfaces == 1 ? usbDevicePath : usbInterfacePath();

    return USBDeviceInformation(
      deviceName: deviceName,
      devicePath: devicePath,
      subsystem: subsystem,
      vid: vid,
      pid: pid,
      serialNumber: serialNumber,
      numberOfInterfaces: numberOfInterfaces,
      location: location,
      manufacturer: manufacturer,
      product: product,
      interface: interface,
    );
  }
}
