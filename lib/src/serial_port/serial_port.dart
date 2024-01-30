// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:dart_serialport/src/serial_port/serial_port_linux.dart';

enum Parity {
  none,
  odd,
  even,
  mark,
  space,
}

enum DataBits {
  five,
  six,
  seven,
  eight,
}

enum StopBits {
  one,
  onePointFive,
  two,
}

/// configuration for a SerialPort
class SerialPortConfig {
  /// configuration for a SerialPort
  SerialPortConfig({
    required this.port,
    this.baudRate = 9600,
    this.dataBits = DataBits.eight,
    this.stopBits = StopBits.one,
    this.parity = Parity.none,
    this.timeout = Duration.zero,
    this.xonxoff = false,
  });

  /// the port to connect to
  /// path on linux, COM{num} on windows
  /// e.g. /dev/ttyUSB0
  final String port;

  /// the baud rate to use
  /// e.g. 9600
  final int baudRate;

  /// the number of data bits to use
  /// e.g. 8
  final DataBits dataBits;

  /// the number of stop bits to use
  final StopBits stopBits;

  /// the parity to use
  final Parity parity;

  /// read timeout
  final Duration timeout;

  // enable software flow control
  final bool xonxoff;

  // enable hardware flow control
  final rtscts = false;
}

abstract class SerialPort {
  factory SerialPort(SerialPortConfig config) {
    if (Platform.isLinux) {
      return SerialPortLinux(config);
    }

    throw UnsupportedError('Platform not supported');
  }

  SerialPortConfig get config;

  void open();

  void close();

  void flush();

  List<int> read(int length);

  void write(List<int> data);

  int get inWaiting;

  int get outWaiting;
}
