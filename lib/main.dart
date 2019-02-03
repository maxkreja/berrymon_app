import "dart:convert";

import "package:berrymon_app/model/device.dart";
import "package:berrymon_app/pages/home.dart";
import "package:berrymon_app/redux/actions.dart";
import "package:berrymon_app/redux/reducer.dart";
import "package:berrymon_app/redux/state.dart";
import "package:flutter/material.dart";
import "package:flutter_redux/flutter_redux.dart";
import "package:http/http.dart" as http;
import "package:redux/redux.dart";
import "package:shared_preferences/shared_preferences.dart";

void initialize(Store<BerrymonState> store) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  store.dispatch(InitializedAction(preferences));

  store.onChange.listen((BerrymonState state) {
    if (state.loading && !state.refreshing) {
      store.dispatch(RefreshStartAction());
      refresh(store);
    }
  });
  store.dispatch(RefreshAction());
}

Future<bool> verifyDevice(Device device) async {
  try {
    http.Response response = await http.get("http://${device.address}:${device.port.toString()}/api");
    if (response.statusCode != 200) return false;

    Map<String, dynamic> data = jsonDecode(response.body);
    if (data.containsKey("name") && data.containsKey("version") && data["name"].toString().contains("Berrymon API")) return true;
    return false;
  } catch (_) {
    return false;
  }
}

Future<int> getBacklightStatus(Device device) async {
  try {
    http.Response response = await http.get("http://${device.address}:${device.port.toString()}/api/backlight");
    if (response.statusCode != 200) return Device.BACKLIGHT_DISABLED;

    Map<String, dynamic> data = jsonDecode(response.body);
    if (data.containsKey("backlight")) return (data["backlight"].toString().toLowerCase() == "true") ? Device.BACKLIGHT_ON : Device.BACKLIGHT_OFF;

    return Device.BACKLIGHT_DISABLED;
  } catch (_) {
    return Device.BACKLIGHT_DISABLED;
  }
}

void refresh(Store<BerrymonState> store) async {
  SharedPreferences preferences = store.state.preferences;
  List<String> ids = preferences.getStringList("ids") ?? [];

  for (String id in ids) {
    String name = preferences.getString(id);
    String address = preferences.getString(id + "A");
    int port = preferences.getInt(id + "P");

    if (name == null || address == null || port == null) continue;

    Device device = Device(address, port, name: name);
    device.status = (await verifyDevice(device)) ? Device.STATUS_ONLINE : Device.STATUS_OFFLINE;
    device.backlight = await getBacklightStatus(device);

    store.dispatch(AddDeviceAction(device, disk: false));
  }

  store.dispatch(RefreshEndAction());
}

void main() {
  final Store<BerrymonState> store = Store<BerrymonState>(BerrymonReducer.reduce, initialState: BerrymonState.initial());
  runApp(App(store: store));
  initialize(store);
}

class App extends StatelessWidget {
  final Store<BerrymonState> store;

  App({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<BerrymonState>(
      store: store,
      child: MaterialApp(
        title: "Berrymon",
        theme: ThemeData(
          primarySwatch: Colors.pink,
          primaryColor: Colors.pink,
          accentColor: Colors.pinkAccent,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        debugShowCheckedModeBanner: false,
        home: Home(),
      ),
    );
  }
}
