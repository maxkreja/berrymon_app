import "dart:async";
import "dart:convert";

import "package:berrymon_app/model/device.dart";
import "package:berrymon_app/redux/actions.dart";
import "package:berrymon_app/redux/state.dart";
import "package:flutter/material.dart";
import "package:flutter_redux/flutter_redux.dart";
import "package:http/http.dart" as http;
import "package:redux/redux.dart";

class Detail extends StatefulWidget {
  final Store<BerrymonState> store;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Detail({@required this.store});

  @override
  _State createState() => _State();
}

class _State extends State<Detail> {
  Timer timer;
  Device device;
  bool updating = false;

  @override
  void initState() {
    super.initState();

    device = widget.store.state.devices[widget.store.state.activeDevice] ?? Device("", 0);

    timer = Timer.periodic(Duration(seconds: 1), (_) async {
      if (updating) return;

      setState(() {
        updating = true;
      });

      try {
        http.Response response = await http.get("http://${device.address}:${device.port.toString()}/api/statistics");
        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);
          if (data.containsKey("username") && data.containsKey("cpu_load") && data.containsKey("cpu_temp")) {
            String username = data["username"];
            double temp = data["cpu_temp"];
            double load = data["cpu_load"];

            http.Response response = await http.get("http://${device.address}:${device.port.toString()}/api");
            if (response.statusCode == 200) {
              data = jsonDecode(response.body);
              if (data.containsKey("name") && data.containsKey("version")) {
                String apiName = data["name"];
                String apiVersion = data["version"];
                widget.store.dispatch(UpdateDeviceAction(device, username: username, temperature: temp, load: load, apiName: apiName, apiVersion: apiVersion));
              }
            }
          }
        }
      } catch (e) {
        widget.store.dispatch(UpdateDeviceAction(device, status: Device.STATUS_OFFLINE));
        print(e);
      }

      setState(() {
        updating = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<BerrymonState, Store<BerrymonState>>(
      converter: (Store<BerrymonState> store) => store,
      builder: (BuildContext context, Store<BerrymonState> store) {
        return WillPopScope(
          onWillPop: () {
            store.dispatch(CloseDetailViewAction());
            store.dispatch(RefreshAction());
            return Future.value(true);
          },
          child: Scaffold(
            key: widget.scaffoldKey,
            appBar: AppBar(
              title: Text(device.name),
              centerTitle: true,
              elevation: 0,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Delete this device?"),
                          actions: <Widget>[
                            FlatButton(
                              child: Text("Cancel"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            FlatButton(
                              child: Text("Delete"),
                              onPressed: () {
                                store.dispatch(RemoveDeviceAction(device));
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            )
                          ],
                        );
                      },
                    );
                  },
                )
              ],
            ),
            backgroundColor: Colors.pink,
            body: SingleChildScrollView(
              padding: EdgeInsets.only(top: 32, right: 16.0, bottom: 16.0, left: 16.0),
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Card(
                    child: ListTile(
                      title: Text(device.username),
                      subtitle: Text(device.id),
                      trailing: Icon(
                        device.status == Device.STATUS_ONLINE ? Icons.signal_wifi_4_bar : Icons.signal_wifi_off,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Card(
                          child: ListTile(
                            contentPadding: EdgeInsets.only(top: 16.0, bottom: 32.0),
                            title: Text(
                              "Load",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 32),
                              child: Text(
                                device.load.toStringAsFixed(1) + "%",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: ListTile(
                            contentPadding: EdgeInsets.only(top: 16.0, bottom: 32.0),
                            title: Text(
                              "Temperature",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 32),
                              child: Text(
                                device.temperature.toStringAsFixed(1) + "°C",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Card(
                    child: ListTile(
                      title: Text(device.apiName),
                      subtitle: Text("Version: " + device.apiVersion),
                      leading: Icon(Icons.info_outline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
