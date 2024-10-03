import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

//String? hostUrl = "http://192.168.0.135";
String? hostUrl = "http://172.20.10.2";
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

void showCustomMaterialBanner({
  required BuildContext context,
  required String? title,
  required String? message,
  required ContentType contentType,
}) {
  final materialBanner = MaterialBanner(
    elevation: 0,
    backgroundColor: Colors.transparent,
    forceActionsBelow: true,
    content: AwesomeSnackbarContent(
      title: title!,
      message: message!,
      contentType: contentType,
      inMaterialBanner: true,
    ),
    actions: const [SizedBox.shrink()],
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentMaterialBanner()
    ..showMaterialBanner(materialBanner);
}

showsnackbar(String? _message, String? _command, BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  SnackBar snackBar = SnackBar(
    duration: const Duration(minutes: 5),
    content: Text(_message!),
    action: SnackBarAction(
      label: _command!,
      onPressed: () {},
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
