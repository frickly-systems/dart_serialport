// ignore_for_file: public_member_api_docs

part of 'serial_device_information.dart';

@immutable
class USBDeviceInformation extends SerialDeviceInformation {
  factory USBDeviceInformation({
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

    return USBDeviceInformation._internal(
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

  const USBDeviceInformation._internal({
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

  final String subsystem;
  final int vid;
  final int pid;
  final String serialNumber;
  final int numberOfInterfaces;
  final String? interface;
  final Directory location;
  final String manufacturer;
  final String product;
}
