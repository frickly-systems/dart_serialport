// ignore_for_file: public_member_api_docs

import 'package:dart_periphery/dart_periphery.dart' as periphery;
import 'package:dart_serialport/src/serial_port/serial_port.dart';

class SerialPortLinux implements SerialPort {
  SerialPortLinux(this.config);

  @override
  SerialPortConfig config;

  periphery.Serial? _serial;

  @override
  void close() {
    _serial?.dispose();
    _serial = null;
  }

  @override
  void open() {
    _serial = periphery.Serial.advanced(
      config.port,
      _getBaudrate(),
      _getDataBits(),
      _getParity(),
      _getStopBits(),
      config.xonxoff,
      config.rtscts,
    );
  }

  @override
  void flush() {
    if (_serial == null) throw StateError('SerialPort is not open');

    _serial?.flush();
  }

  @override
  int get inWaiting {
    final serial = _serial;
    if (serial == null) throw StateError('SerialPort is not open');
    return serial.getInputWaiting();
  }

  @override
  int get outWaiting {
    final serial = _serial;
    if (serial == null) throw StateError('SerialPort is not open');
    return serial.getOutputWaiting();
  }

  @override
  List<int> read(int length) {
    final serial = _serial;
    if (serial == null) throw StateError('SerialPort is not open');

    final data = serial.read(
      length,
      config.timeout == Duration.zero ? -1 : config.timeout.inMilliseconds,
    );
    return data.data;
  }

  @override
  void write(List<int> data) {
    final serial = _serial;
    if (serial == null) throw StateError('SerialPort is not open');

    serial.write(data);
  }

  periphery.Baudrate _getBaudrate() {
    return periphery.Baudrate.values.firstWhere(
      (element) => element.name == 'b${config.baudRate}',
      orElse: () => periphery.Baudrate.b9600,
    );
  }

  periphery.DataBits _getDataBits() {
    switch (config.dataBits) {
      case DataBits.five:
        return periphery.DataBits.db5;
      case DataBits.six:
        return periphery.DataBits.db6;
      case DataBits.seven:
        return periphery.DataBits.db7;
      case DataBits.eight:
        return periphery.DataBits.db8;
    }
  }

  periphery.Parity _getParity() {
    switch (config.parity) {
      case Parity.none:
        return periphery.Parity.parityNone;
      case Parity.odd:
        return periphery.Parity.parityOdd;
      case Parity.even:
        return periphery.Parity.parityEven;
      case Parity.mark:
      case Parity.space:
        throw UnsupportedError('parity $config.parity is not supported');
    }
  }

  periphery.StopBits _getStopBits() {
    switch (config.stopBits) {
      case StopBits.one:
        return periphery.StopBits.sb1;
      case StopBits.two:
        return periphery.StopBits.sb2;
      case StopBits.onePointFive:
        throw UnsupportedError('stopBits $config.stopBits is not supported');
    }
  }
}
