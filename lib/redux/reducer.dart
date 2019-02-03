import "package:berrymon_app/model/device.dart";
import "package:berrymon_app/redux/actions.dart";
import "package:berrymon_app/redux/state.dart";

class BerrymonReducer {
  static BerrymonState reduce(BerrymonState state, dynamic action) {
    if (action is InitializedAction) return reduceInitializedAction(state, action);
    if (action is AddDeviceAction) return reduceAddDeviceAction(state, action);
    if (action is RemoveDeviceAction) return reduceRemoveDeviceAction(state, action);
    if (action is UpdateDeviceAction) return reduceUpdateDeviceAction(state, action);
    if (action is OpenDetailViewAction) return reduceOpenDetailViewAction(state, action);
    if (action is OpenSettingsViewAction) return reduceOpenSettingsViewAction(state, action);
    if (action is CloseDetailViewAction) return reduceCloseDetailViewAction(state, action);
    if (action is CloseSettingsViewAction) return reduceCloseSettingsViewAction(state, action);
    if (action is RefreshAction) return reduceRefreshAction(state, action);
    if (action is RefreshStartAction) return reduceRefreshStartAction(state, action);
    if (action is RefreshEndAction) return reduceRefreshEndAction(state, action);
    return state;
  }

  static BerrymonState reduceInitializedAction(BerrymonState state, InitializedAction action) {
    state.initialized = true;
    state.preferences = action.preferences;

    return state;
  }

  static BerrymonState reduceAddDeviceAction(BerrymonState state, AddDeviceAction action) {
    Device device = action.device;

    if (action.disk) {
      List<String> ids = state.preferences.getStringList("ids") ?? [];
      ids.add(device.id);

      state.preferences.setString(device.id, device.name);
      state.preferences.setString(device.id + "A", device.address);
      state.preferences.setInt(device.id + "P", device.port);
      state.preferences.setStringList("ids", ids);
    }

    state.devices[device.id] = device;
    return state;
  }

  static BerrymonState reduceRemoveDeviceAction(BerrymonState state, RemoveDeviceAction action) {
    Device device = action.device;
    print(device.id);

    List<String> ids = state.preferences.getStringList("ids") ?? [];
    ids.remove(device.id);

    state.preferences.remove(device.id);
    state.preferences.remove(device.id + "A");
    state.preferences.remove(device.id + "P");
    state.preferences.setStringList("ids", ids);

    print(state.devices.length);
    state.devices.remove(device.id);
    print(state.devices.length);
    return state;
  }

  static BerrymonState reduceUpdateDeviceAction(BerrymonState state, UpdateDeviceAction action) {
    Device device = action.device;

    if (action.backlight != null) device.backlight = action.backlight;
    if (action.load != null) device.load = action.load;
    if (action.name != null) device.name = action.name;
    if (action.status != null) device.status = action.status;
    if (action.temperature != null) device.temperature = action.temperature;
    if (action.username != null) device.username = action.username;
    if (action.apiName != null) device.apiName = action.apiName;
    if (action.apiVersion != null) device.apiVersion = action.apiVersion;

    bool breakingChange = false;
    String oldID;

    if (action.address != null) {
      oldID = device.id;
      device.id = action.address + ":" + device.port.toString();
      device.address = action.address;
      breakingChange = true;
    }

    if (action.port != null) {
      if (!breakingChange) oldID = device.id;
      device.id = device.address + ":" + action.port.toString();
      device.port = action.port;
      breakingChange = true;
    }

    if (breakingChange) {
      state = reduceRemoveDeviceAction(state, RemoveDeviceAction(Device.changeID(oldID)));
      state = reduceAddDeviceAction(state, AddDeviceAction(device));
      return state;
    }

    state.devices[device.id] = device;
    return state;
  }

  static BerrymonState reduceOpenDetailViewAction(BerrymonState state, OpenDetailViewAction action) {
    state.activeDevice = action.device.id;
    state.details = true;
    return state;
  }

  static BerrymonState reduceOpenSettingsViewAction(BerrymonState state, OpenSettingsViewAction action) {
    state.settings = true;
    return state;
  }

  static BerrymonState reduceCloseDetailViewAction(BerrymonState state, CloseDetailViewAction action) {
    state.activeDevice = null;
    state.details = false;
    return state;
  }

  static BerrymonState reduceCloseSettingsViewAction(BerrymonState state, CloseSettingsViewAction action) {
    state.settings = false;

    return state;
  }

  static BerrymonState reduceRefreshAction(BerrymonState state, RefreshAction action) {
    state.loading = true;
    return state;
  }

  static BerrymonState reduceRefreshStartAction(BerrymonState state, RefreshStartAction action) {
    state.refreshing = true;
    return state;
  }

  static BerrymonState reduceRefreshEndAction(BerrymonState state, RefreshEndAction action) {
    state.loading = false;
    state.refreshing = false;

    state.devices.forEach((String id, Device device) => print(id + ": " + device.status.toString()));

    return state;
  }
}
