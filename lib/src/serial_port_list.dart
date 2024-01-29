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

  static bool _isSerialDevice(File file) {
    final path = file.path;
    return _deviceFilter.any((filter) => filter.matches(path));
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

    final subsystemPath = _subsystemPath(deviceName);
    final subsystem = path.basename(subsystemPath);

    if (subsystem == 'usb' || subsystem == 'usb-serial') {
      return USBDeviceInformation(
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

  String _subsystemPath(String deviceName) =>
      File('/sys/class/tty/$deviceName/device/subsystem')
          .absolute
          .resolveSymbolicLinksSync();

  @override
  Future<Iterable<SerialDeviceInformation>> listEntries() {
    final rawDevices = Directory('/dev')
        .listSync()
        .whereType<File>()
        .where(_isSerialDevice)
        .toList();

    final devices = rawDevices.map(
      (device) {
        final deviceName = path.basename(device.path);
        return _toDeviceInfo(deviceName);
      },
    );

    return Future.value(devices);
  }
}
