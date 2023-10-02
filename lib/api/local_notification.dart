import 'dart:convert';
import 'dart:developer';
import 'package:Erdenet24/api/restapi_helper.dart';
import 'package:get/get.dart';
import 'package:Erdenet24/utils/styles.dart';
import 'package:Erdenet24/controller/user_controller.dart';
import 'package:Erdenet24/controller/driver_controller.dart';
import 'package:Erdenet24/controller/store_controller.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

final _userCtx = Get.put(UserController());
final _storeCtx = Get.put(StoreController());
final _driverCtx = Get.put(DriverController());

class LocalNofitication {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    var payload = jsonDecode(receivedNotification.payload!["data"]!);
    var role = payload["role"];
    var userRole = RestApiHelper.getUserRole();
    if (userRole == "store") {
      _storeCtx.storeActionHandler(payload);
    } else if (userRole == "driver") {
      _driverCtx.driverActionHandler(payload);
    } else if (userRole == "user") {
      _userCtx.userActionHandler(payload);
    }
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }
}

Future<void> handleNotifications(message) async {
  var info = message["data"];
  var data = jsonDecode(info);

  AwesomeNotifications().createNotification(
    content: NotificationContent(
      wakeUpScreen: true,
      payload: Map<String, String>.from(message),
      id: data["id"] ?? 1,
      channelKey: 'basic_channel',
      title: data["title"],
      body: data["body"],
      notificationLayout: data["isDefault"]
          ? NotificationLayout.Default
          : NotificationLayout.BigPicture,
      displayOnBackground: true,
      displayOnForeground: true,
      color: MyColors.primary,
      largeIcon: data["largeIcon"],
      bigPicture: data["bigPicture"],
    ),
  );
}
