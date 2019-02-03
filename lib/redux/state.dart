import "package:berrymon_app/model/device.dart";
import "package:shared_preferences/shared_preferences.dart";

class BerrymonState {
  Map<String, Device> devices = {};

  bool initialized;
  bool loading;
  bool details;
  bool settings;
  bool refreshing;

  String activeDevice;
  SharedPreferences preferences;

  BerrymonState({
    this.loading = false,
    this.details = false,
    this.settings = false,
    this.initialized = false,
    this.refreshing = false,
  });

  static BerrymonState initial() => BerrymonState();
}
