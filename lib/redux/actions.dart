import "package:berrymon_app/model/device.dart";
import "package:shared_preferences/shared_preferences.dart";

class InitializedAction {
  SharedPreferences preferences;
  InitializedAction(this.preferences);
}

class AddDeviceAction {
  Device device;
  bool disk;
  AddDeviceAction(this.device, {this.disk = true});
}

class RemoveDeviceAction {
  Device device;
  RemoveDeviceAction(this.device);
}

class UpdateDeviceAction {
  Device device;

  String name;
  String address;
  String username;

  String apiName;
  String apiVersion;

  int port;
  int status;
  int backlight;

  double load;
  double temperature;

  UpdateDeviceAction(
    this.device, {
    this.name,
    this.username,
    this.apiName,
    this.apiVersion,
    this.status,
    this.backlight,
    this.load,
    this.temperature,
  });
}

class OpenDetailViewAction {
  Device device;
  OpenDetailViewAction(this.device);
}

class OpenSettingsViewAction {
  Device device;
  OpenSettingsViewAction(this.device);
}

class CloseDetailViewAction {}

class CloseSettingsViewAction {}

class RefreshAction {}

class RefreshEndAction {}

class RefreshStartAction {}
