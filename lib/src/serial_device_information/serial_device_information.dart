// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'usb_device_information.dart';

@immutable
class SerialDeviceInformation extends Equatable {
  const SerialDeviceInformation({
    required this.deviceName,
    required Directory? devicePath,
  }) : _devicePath = devicePath;

  final String deviceName;

  final Directory? _devicePath;
  Directory? get devicePath => _devicePath;

  @override
  List<Object?> get props => [
        deviceName,
        devicePath,
      ];

  @override
  String toString() {
    return 'SerialDeviceInformation{ '
        'deviceName: $deviceName, '
        'devicePath: $devicePath, '
        '}';
  }
}
