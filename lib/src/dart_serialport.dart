// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:glob/glob.dart';
import 'package:path/path.dart';

/// {@template dart_serialport}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class DartSerialport {
  /// {@macro dart_serialport}
  const DartSerialport();
}

class SerialPort {}

class SerialDeviceInfo {
  SerialDeviceInfo({required this.deviceName})
      : devicePath = Directory('/sys/class/tty/$deviceName/device');
  final String deviceName;
  final Directory devicePath;

  String? get subsystem {
    if (!devicePath.existsSync()) {
      return null;
    }

    final subsysPath = File('/sys/class/tty/$deviceName/device/subsystem')
        .absolute
        .resolveSymbolicLinksSync();

    return basename(subsysPath);
  }

  Directory? get usbInterfacePath {
    if (subsystem == 'usb') {
      return devicePath;
    } else if (subsystem == 'usb-serial') {
      return devicePath.parent;
    } else {
      return null;
    }
  }

  UsbInformation? get usbInformation {
    final usbInterfacePath = this.usbInterfacePath;

    if (usbInterfacePath == null) {
      return null;
    }

    final usbDevicePath = usbInterfacePath.parent;
    String readProperty(String property, {Directory? basepath}) {
      final propertyFile =
          File(join((basepath ?? usbDevicePath).path, property));
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
    final interface = readProperty('interface', basepath: usbInterfacePath);

    final location = numberOfInterfaces == 1 ? usbDevicePath : usbInterfacePath;
  }
}

class UsbInformation {
  const UsbInformation({
    required this.vid,
    required this.pid,
    required this.serialNumber,
    required this.numberOfInterfaces,
    required this.location,
    required this.interfaceDescription,
    required this.manufacturer,
    required this.product,
  });

  final int vid;
  final int pid;
  final String serialNumber;
  final int numberOfInterfaces;
  final String? interfaceDescription;
  final String location;
  final String manufacturer;
  final String product;
}

class SerialPortList {
  SerialPortList()
      : _devices = Directory('/dev')
            .listSync()
            .whereType<File>()
            .where(
              (entity) =>
                  _isSerialDevice(entity.absolute.resolveSymbolicLinksSync()),
            )
            .toList();

  late final List<File> _devices;

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

  static bool _isSerialDevice(String path) {
    return _deviceFilter.any((filter) => filter.matches(path));
  }
}
