import "package:berrymon_app/main.dart" as main;
import "package:berrymon_app/model/device.dart";
import "package:berrymon_app/pages/splash.dart";
import "package:berrymon_app/redux/actions.dart";
import "package:berrymon_app/redux/state.dart";
import "package:berrymon_app/widgets/add_device_dialog.dart";
import "package:flutter/material.dart";
import "package:flutter_redux/flutter_redux.dart";
import "package:redux/redux.dart";
import "package:berrymon_app/widgets/device_list_tile.dart";

class Home extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void addDevice(Store<BerrymonState> store, Device device) async {
    if (store.state.devices.containsKey(device.id)) {
      scaffoldKey.currentState.hideCurrentSnackBar();
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Aborted: Duplicate.")));
      return;
    }

    bool valid = await main.verifyDevice(device);

    if (valid) {
      device.status = Device.STATUS_ONLINE;
      store.dispatch(AddDeviceAction(device));
      store.dispatch(RefreshAction());

      scaffoldKey.currentState.hideCurrentSnackBar();
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Device added.")));
      return;
    }

    scaffoldKey.currentState.hideCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Aborted: Could not connect.")));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<BerrymonState, Store<BerrymonState>>(
      converter: (Store<BerrymonState> store) => store,
      builder: (BuildContext context, Store<BerrymonState> store) {
        return store.state.initialized
            ? Scaffold(
                key: scaffoldKey,
                backgroundColor: Colors.pink,
                appBar: AppBar(
                  title: Text("Berrymon"),
                  centerTitle: true,
                  elevation: 0,
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: (store.state.loading || store.state.refreshing) ? null : () => store.dispatch(RefreshAction()),
                    )
                  ],
                ),
                floatingActionButton: FloatingActionButton.extended(
                  label: Text("Add"),
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (store.state.loading || store.state.refreshing) return;
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AddDeviceDialog(
                              onSubmit: ({String address, int port}) {
                                Navigator.pop(context);
                                scaffoldKey.currentState.hideCurrentSnackBar();
                                scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Adding device...")));

                                Device device = Device(address, port);
                                addDevice(store, device);
                              },
                              onCancel: () {
                                Navigator.pop(context);
                              },
                              onInvalidInput: () {
                                Navigator.pop(context);
                                scaffoldKey.currentState.hideCurrentSnackBar();
                                scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Aborted: Invalid input.")));
                              },
                            ));
                  },
                ),
                body: Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: store.state.devices.keys.length,
                    itemBuilder: (BuildContext context, int index) {
                      print(store.state.devices.length);
                      return DeviceListTile(
                        deviceID: store.state.devices[store.state.devices.keys.elementAt(index)].id,
                        last: index == store.state.devices.keys.length - 1,
                      );
                    },
                  ),
                ),
              )
            : Splash();
      },
    );
  }
}
