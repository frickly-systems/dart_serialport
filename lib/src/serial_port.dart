// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:dart_serialport/dart_serialport.dart';
import 'package:dart_serialport/src/serial_device_information/serial_device_information.dart';
import 'package:stdlibc/stdlibc.dart' as libc;

enum StopBits {
  one,
  onePointFive,
  two,
}

enum Parity {
  none,
  even,
  odd,
  mark,
  space,
}

enum ByteSize {
  five,
  six,
  seven,
  eight,
}

sealed class SerialPort {
  SerialPort({
    required this.deviceInformation,
    this.baudrate = Baudrate.b9600,
  });

  final SerialDeviceInformation deviceInformation;
  final Baudrate baudrate;
}

class SerialPortLinux extends SerialPort {
  SerialPortLinux({
    required super.deviceInformation,
    super.baudrate = Baudrate.b9600,
  });

  bool isOpen = false;
  int fd = 0;

  @override
  Future<void> open() async {}
}
