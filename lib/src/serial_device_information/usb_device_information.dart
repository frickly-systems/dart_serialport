// ignore_for_file: public_member_api_docs

part of 'serial_device_information.dart';

@immutable
class USBDeviceInformation extends SerialDeviceInformation {
  const USBDeviceInformation({
    required super.deviceName,
    required this.devicePath,
    required this.subsystem,
    required this.vid,
    required this.pid,
    required this.serialNumber,
    required this.numberOfInterfaces,
    required this.interface,
    required this.location,
    required this.manufacturer,
    required this.product,
  }) : super(
          devicePath: devicePath,
        );

  final String subsystem;
  final int vid;
  final int pid;
  final String serialNumber;
  final int numberOfInterfaces;
  final String? interface;
  final Directory location;
  final String manufacturer;
  final String product;

  @override
  final Directory devicePath;

  @override
  List<Object?> get props => [
        ...super.props,
        subsystem,
        vid,
        pid,
        serialNumber,
        numberOfInterfaces,
        interface,
        location,
        manufacturer,
        product,
      ];
}
