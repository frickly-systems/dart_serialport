// ignore_for_file: public_member_api_docs
part of 'serial_device_information.dart';

class SerialDeviceEntry {
  SerialDeviceEntry({
    required this.deviceName,
  });

  final String deviceName;

  SerialDeviceInformation enrich() {
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
}
