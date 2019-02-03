import "package:berrymon_app/model/device.dart";
import "package:berrymon_app/pages/detail.dart";
import "package:berrymon_app/redux/actions.dart";
import "package:berrymon_app/redux/state.dart";
import "package:flutter/material.dart";
import "package:flutter_redux/flutter_redux.dart";
import "package:http/http.dart" as http;
import "package:redux/redux.dart";

class DeviceListTile extends StatelessWidget {
  static const TextStyle styleTitle = TextStyle(fontSize: 20, fontWeight: FontWeight.w500);
  static const TextStyle syteSubtitle = TextStyle(fontSize: 18);

  final String deviceID;
  final bool last;

  DeviceListTile({@required this.deviceID, this.last = false});

  void toggleBacklight(Store store, Device device) async {
    try {
      if (device.backlight == Device.BACKLIGHT_ON) {
        await http.post(
          "http://${device.address}:${device.port.toString()}/api/backlight",
          body: "{\"backlight\": false}",
          headers: {"Content-Type": "application/json"},
        );
        store.dispatch(UpdateDeviceAction(device, backlight: Device.BACKLIGHT_OFF));
      } else if (device.backlight == Device.BACKLIGHT_OFF) {
        await http.post(
          "http://${device.address}:${device.port.toString()}/api/backlight",
          body: "{\"backlight\": true}",
          headers: {"Content-Type": "application/json"},
        );
        store.dispatch(UpdateDeviceAction(device, backlight: Device.BACKLIGHT_ON));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<BerrymonState, Store<BerrymonState>>(
      converter: (Store<BerrymonState> store) => store,
      builder: (BuildContext context, Store<BerrymonState> store) {
        Device device = store.state.devices[deviceID];

        return Padding(
          padding: EdgeInsets.only(bottom: last ? 98 : 8, left: 8, right: 8),
          child: InkWell(
            onTap: () {
              store.dispatch(OpenDetailViewAction(device));
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Detail(store: store)));
            },
            child: Card(
              child: Container(
                height: 90,
                padding: EdgeInsets.only(top: 16, right: 16, bottom: 16, left: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      device.status == Device.STATUS_ONLINE ? Icons.signal_wifi_4_bar : Icons.signal_wifi_off,
                      color: Colors.black,
                    ),
                    Padding(padding: EdgeInsets.only(right: 24)),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(device.name, style: styleTitle),
                          Text("${device.address}:${device.port.toString()}", style: syteSubtitle),
                        ],
                      ),
                    ),
                    ButtonTheme(
                      minWidth: 60,
                      height: 60,
                      buttonColor: Colors.white,
                      disabledColor: Colors.grey[200],
                      child: RaisedButton(
                        child: Container(
                          width: 60,
                          height: 60,
                          child: Icon(device.backlight == Device.BACKLIGHT_ON ? Icons.brightness_high : Icons.brightness_low),
                        ),
                        padding: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        onPressed: (device.status != Device.STATUS_ONLINE && device.backlight == Device.BACKLIGHT_DISABLED)
                            ? null
                            : () => toggleBacklight(store, device),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
