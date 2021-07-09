import 'dart:io';

import 'package:device_info/device_info.dart';

class ConfigService {
  late String idDevice;

  ConfigService._privateConstructor();

  static final ConfigService instance = ConfigService._privateConstructor();

  Future<void> init() async {
    idDevice = await _getId();
  }

  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }
}
