import "package:flutter/material.dart";

typedef void OnSubmitCallback({@required String address, @required int port});
typedef void OnInvalidInputCallback();
typedef void OnCancelCallback();

class AddDeviceDialog extends StatelessWidget {
  static const InputDecoration addressDecoration = InputDecoration(border: OutlineInputBorder(), labelText: "Address", hintText: "172.16.254.1");
  static const InputDecoration portDecoration = InputDecoration(border: OutlineInputBorder(), labelText: "Port", hintText: "2374");

  final OnSubmitCallback onSubmit;
  final OnInvalidInputCallback onInvalidInput;
  final OnCancelCallback onCancel;

  final TextEditingController addressController = TextEditingController();
  final TextEditingController portController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  AddDeviceDialog({@required this.onSubmit, @required this.onInvalidInput, @required this.onCancel});

  bool verfiyInput() {
    if (addressController.text.isEmpty || portController.text.isEmpty) return false;

    RegExp regAddress = RegExp(r"^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$");
    RegExp regPort = RegExp(r"^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$");

    if (!regAddress.hasMatch(addressController.text) || !regPort.hasMatch(portController.text)) return false;

    return true;
  }

  void submit() {
    if (!verfiyInput()) {
      onInvalidInput();
      return;
    }

    onSubmit(address: addressController.text, port: int.parse(portController.text));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add a new device"),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            autofocus: true,
            controller: addressController,
            decoration: addressDecoration,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context).requestFocus(focusNode),
          ),
          Padding(padding: EdgeInsets.only(bottom: 16.0)),
          TextField(
            focusNode: focusNode,
            controller: portController,
            decoration: portDecoration,
            keyboardType: TextInputType.numberWithOptions(signed: false),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => submit(),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(child: Text("Cancel"), onPressed: onCancel),
        FlatButton(child: Text("Add"), onPressed: submit),
      ],
    );
  }
}
