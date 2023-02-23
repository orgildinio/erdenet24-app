import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'package:Erdenet24/api/dio_requests.dart';
import 'package:Erdenet24/api/restapi_helper.dart';
import 'package:Erdenet24/utils/styles.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../screens/driver/driver_bottom_views.dart';

class DriverController extends GetxController {
  //=========================Driver states==================================
  RxInt step = 0.obs;
  RxBool isOnline = false.obs;
  RxMap remoteMessageData = {}.obs;
  RxMap deliveryInfo = {}.obs;
  RxString fcmToken = "".obs;
  dynamic driverInfo = [].obs;

  //=========================Map states==================================
  RxString distanceAndDuration = "".obs;
  Rx<LatLng> storeLocation = LatLng(49.02821126030273, 104.04634376483777).obs;
  RxBool isGPSActive = false.obs;
  RxInt markerIdCounter = 0.obs;
  RxDouble markerRotation = 0.0.obs;
  Rx<LatLng> initialPosition =
      LatLng(49.02821126030273, 104.04634376483777).obs;
  Rx<Completer<GoogleMapController>> mapController =
      Completer<GoogleMapController>().obs;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;

  //=========================Map controllers==================================
  void getUserLocation() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      isGPSActive.value = false;
    } else {
      isGPSActive.value = true;
      LocationPermission permission;
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      initialPosition.value = LatLng(position.latitude, position.longitude);
      CameraPosition currentCameraPosition = CameraPosition(
        bearing: 0,
        target: initialPosition.value,
        zoom: 16,
      );
      final GoogleMapController controller = await mapController.value.future;
      controller
          .animateCamera(CameraUpdate.newCameraPosition(currentCameraPosition));
      markerRotation.value = position.heading;
      addMarker();
    }
  }

  void addMarker() async {
    BitmapDescriptor iconBitmap = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/images/png/app/driver.png",
    );
    MarkerId markerId = MarkerId(markerIdVal());
    Marker marker = Marker(
      markerId: markerId,
      position: initialPosition.value,
      icon: iconBitmap,
      rotation: markerRotation.value,
    );
    markers[markerId] = marker;
  }

  String markerIdVal({bool increment = false}) {
    String val = 'marker_id_$markerIdCounter';
    if (increment) markerIdCounter++;
    return val;
  }

  void onCameraMove(CameraPosition cameraPosition) {
    if (markers.isNotEmpty) {
      MarkerId markerId = MarkerId(markerIdVal());
      Marker? marker = markers[markerId];
      Marker updatedMarker = marker!.copyWith(
        positionParam: cameraPosition.target,
      );
      markers[markerId] = updatedMarker;
    }
  }

  void getPositionStream() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 3,
      ),
    ).listen((Position? info) async {
      initialPosition.value = LatLng(info!.latitude, info.longitude);
      CameraPosition currentCameraPosition = CameraPosition(
        bearing: 0,
        target: initialPosition.value,
        zoom: 16,
      );
      markerRotation.value = info.heading;
      addMarker();
      final GoogleMapController controller = await mapController.value.future;
      controller
          .animateCamera(CameraUpdate.newCameraPosition(currentCameraPosition));
    });
  }

  void onMapCreated(GoogleMapController controller) async {
    if (!mapController.value.isCompleted) {
      mapController.value.complete(controller);
    }

    addMarker();
    Future.delayed(const Duration(seconds: 1), () async {
      if (!mapController.value.isCompleted) {
        GoogleMapController controller = await mapController.value.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: initialPosition.value,
              zoom: 17.0,
            ),
          ),
        );
      } else {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: initialPosition.value,
              zoom: 17.0,
            ),
          ),
        );
      }
    });
  }

  //=========================Driver controllers==================================
  void turnOnOff(value) async {
    isOnline.value = value;
    if (value == true) {
      playSound("engine_start");
      getUserLocation();
      getPositionStream();
      startTimer(10800);
    } else {
      stopTimer();
      stopSound();
    }
  }

  void fetchDriverInfo(int id) async {
    dynamic response = await RestApi().getDriver(id);
    dynamic d = Map<String, dynamic>.from(response);
    if (d["success"]) {
      driverInfo = d["data"];
    }
  }

  void updateDriverInfo(dynamic body) async {
    var id = RestApiHelper.getUserId();
    dynamic user = await RestApi().updateDriver(id, body);
    dynamic data = Map<String, dynamic>.from(user);
    if (data["success"]) {}
  }

  void getNewDelivery() async {
    storeLocation.value = LatLng(
      double.parse(deliveryInfo["latitude"]),
      double.parse(deliveryInfo["longitude"]),
    );
    // getDistance(driverLocation.value, storeLocation.value);

    step.value = 1;
    playSound("incoming");
  }

  void sendUserTokenToTheServer() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    var body = {"mapToken": fcmToken};
    await RestApi().updateUser(RestApiHelper.getUserId(), body);
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      var body = {"mapToken": newToken};
      await RestApi().updateUser(RestApiHelper.getUserId(), body);
    });
  }

  void cancelNewDelivery() async {
    step.value = 0;
    stopSound();
    removeMarker("store");
  }

  void finishDelivery() {
    step.value = 0;
    removeMarker("store");

    deliveryInfo.clear();
  }

  void getDistance(LatLng driver, LatLng store) async {
    const String baseUrl =
        'https://maps.googleapis.com/maps/api/directions/json?';
    final respose = await Dio().get(baseUrl, queryParameters: {
      "origin": "${driver.latitude}, ${driver.longitude}",
      "destination": "${store.latitude}, ${store.longitude}",
      "key": "AIzaSyAHTYs2cMm87YH3wppr6wTtKRZxfyXjvB4"
    });
    final Map parsed = json.decode(respose.toString());
    String distanceText = parsed["routes"][0]["legs"][0]["distance"]["text"];
    String durationText = parsed["routes"][0]["legs"][0]["duration"]["text"];
    distanceText = distanceText.substring(0, distanceText.length - 3);
    double distanceMile = double.parse(distanceText);
    String distanceKm = (distanceMile * 1.609).toStringAsFixed(3);
    distanceAndDuration.value = "$distanceKm km, $durationText";
  }

  void removeMarker(String type) {
    markers.removeWhere(
      (key, value) => value.markerId == MarkerId(type),
    );
  }

  void firebaseMessagingForegroundHandler() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      storeLocation.value = LatLng(
        double.parse(message.data["latitude"]),
        double.parse(message.data["longitude"]),
      );
      deliveryInfo.value = message.data;
      storeLocation.value = LatLng(
        double.parse(deliveryInfo["latitude"]),
        double.parse(deliveryInfo["longitude"]),
      );
      getNewDelivery();
    });
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

//time controller====================

  Timer? _timer;
  int remainingSeconds = 0;
  final time = '00.00'.obs;

  void stopTimer() {
    _timer!.cancel();
  }

  void startTimer(int seconds) {
    const duration = Duration(seconds: 1);
    remainingSeconds = seconds;
    _timer = Timer.periodic(duration, (Timer timer) {
      if (remainingSeconds == 0) {
        turnOnOff(false);
        timer.cancel();
      } else {
        int hours = remainingSeconds ~/ 3600;
        int minutes = remainingSeconds ~/ 60 % 60;
        int seconds = (remainingSeconds % 60);
        time.value = hours.toString().padLeft(2, "0") +
            ":" +
            minutes.toString().padLeft(2, "0") +
            ":" +
            seconds.toString().padLeft(2, "0");
        remainingSeconds--;
      }
    });
  }
}
