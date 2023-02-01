import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:Erdenet24/widgets/dialogs.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../screens/driver/driver_bottom_views.dart';

class DriverController extends GetxController {
  RxBool isDriverActive = false.obs;
  RxDouble driverLat = 49.02821126030273.obs;
  RxDouble driverLng = 104.04634376483777.obs;
  RxDouble storeLat = 49.02646128988077.obs;
  RxDouble storeLng = 104.0399308405171.obs;

  RxBool gotDeliveryRequest = false.obs;

  RxBool distanceCalculated = false.obs;
  RxBool acceptedTheDelivery = false.obs;
  RxInt deliverySteps = 0.obs;
  RxString distance = "".obs;
  RxString duration = "".obs;

  Rx<PageController> pageController = PageController().obs;
  int waitingSeconds = 30;
  Timer? countdownTimer;
  Duration myDuration = const Duration(hours: 3);
  Rx<Completer<GoogleMapController>> googleMapController =
      Completer<GoogleMapController>().obs;
  Rx<CountDownController> countDownController = CountDownController().obs;

  void turnedOnApp(value) async {
    isDriverActive.value = value;
    bool serviceEnabled;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 50,
      );
      var info = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      driverLat.value = info.latitude;
      driverLng.value = info.longitude;

      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position? info) {
        if (info != null) {
          driverLat.value = info.latitude;
          driverLng.value = info.longitude;
        }
      });
      final GoogleMapController controller =
          await googleMapController.value.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(driverLat.value, driverLng.value),
          zoom: 19,
          tilt: 59)));
    }
  }

  void deliveryRequestArrived(context) async {
    loadingDialog(context);
    gotDeliveryRequest.value = true;
    const String baseUrl =
        'https://maps.googleapis.com/maps/api/directions/json?';
    final respose = await Dio().get(baseUrl, queryParameters: {
      "origin": "${driverLat.value}, ${driverLng.value}",
      "destination": "${storeLat.value}, ${storeLng.value}",
      "key": "AIzaSyAHTYs2cMm87YH3wppr6wTtKRZxfyXjvB4"
    });
    log(respose.toString());
    final Map parsed = json.decode(respose.toString());

    if (parsed.isNotEmpty) {
      // String distanceText = parsed["routes"][0]["legs"][0]["distance"]["text"];
      // String durationText = parsed["routes"][0]["legs"][0]["duration"]["text"];
      // distanceText = distanceText.substring(0, distanceText.length - 3);
      // double distanceMile = double.parse(distanceText);
      // double distanceKm = (distanceMile * 1.609);

      // distance.value = distanceKm.toStringAsFixed(3);
      // duration.value = durationText;
    }
    Get.back();
    incomingNewOrder();
    countDownController.value.start();
  }

  // void startTimer() {
  //   myDuration = const Duration(hours: 3);
  //   countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
  //     const reduceSecondsBy = 1;
  //     final seconds = myDuration.inSeconds - reduceSecondsBy;
  //     if (seconds < 0) {
  //       countdownTimer!.cancel();
  //     } else {
  //       myDuration = Duration(seconds: seconds);
  //     }
  //   });
  // }

  void declineDeliveryRequest() {
    Get.back();
    distanceCalculated.value = false;
    countDownController.value.pause();
    stopSound();
  }

  void acceptDeliveryRequest() async {
    stopSound();
    Get.back();
    distanceCalculated.value = false;
    acceptedTheDelivery.value = true;
    // final GoogleMapController controller =
    //     await googleMapController.value.future;
    // controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
    //     bearing: -120, target: origin.value, zoom: 16, tilt: 32)));
    // trackDriversLocation();
  }

  void changePage(int value) {
    pageController.value.animateToPage(
      value,
      duration: const Duration(milliseconds: 500),
      curve: Curves.bounceInOut,
    );
  }
}