class Device {
  static const int STATUS_ONLINE = 0;
  static const int STATUS_OFFLINE = 1;

  static const int BACKLIGHT_ON = 0;
  static const int BACKLIGHT_OFF = 1;
  static const int BACKLIGHT_DISABLED = 2;

  String id;
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

  Device(
    this.address,
    this.port, {
    this.name: "Raspberry Pi",
    this.username: "",
    this.apiName: "",
    this.apiVersion: "",
    this.status = STATUS_OFFLINE,
    this.backlight = BACKLIGHT_DISABLED,
    this.load = 0,
    this.temperature = 0,
  }) {
    this.id = address + ":" + port.toString();
  }

  static Device changeID(String id) {
    Device device = Device("", 0);
    device.id = id;
    return device;
  }
}
