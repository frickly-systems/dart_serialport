// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'package:dart_serialport/dart_serialport.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

sealed class SerialPortList {
  factory SerialPortList() {
    if (Platform.isLinux) {
      return SerialPortListLinux();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future<Iterable<SerialDeviceEntry>> entries();
}

class SerialPortListLinux implements SerialPortList {
  SerialPortListLinux()
      : _devices = Directory('/dev')
            .listSync()
            .whereType<File>()
            .where(_isSerialDevice)
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

  static bool _isSerialDevice(File file) {
    final path = file.path;
    return _deviceFilter.any((filter) => filter.matches(path));
  }

  @override
  Future<Iterable<SerialDeviceEntry>> entries() {
    final devices = _devices.map(
      (device) {
        final deviceName = path.basename(device.path);
        return SerialDeviceEntry(deviceName: deviceName);
      },
    );

    return Future.value(devices);
  }
}
