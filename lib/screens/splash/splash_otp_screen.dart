import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:Erdenet24/utils/enums.dart';
import 'package:Erdenet24/utils/routes.dart';
import 'package:Erdenet24/utils/styles.dart';
import 'package:Erdenet24/widgets/text.dart';
import 'package:Erdenet24/widgets/header.dart';
import 'package:Erdenet24/widgets/snackbar.dart';
import 'package:Erdenet24/api/dio_requests/login.dart';
import 'package:Erdenet24/widgets/dialogs/dialog_list.dart';

class SplashOtpScreen extends StatefulWidget {
  const SplashOtpScreen({super.key});

  @override
  State<SplashOtpScreen> createState() => _SplashOtpScreenState();
}

class _SplashOtpScreenState extends State<SplashOtpScreen> {
  String loginType = "";
  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 1);
  final arguments = Get.arguments;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        final seconds = myDuration.inSeconds - 1;
        if (seconds < 0) {
          countdownTimer!.cancel();
        } else {
          myDuration = Duration(seconds: seconds);
        }
      });
    });
  }

  void sendOTP() async {
    CustomDialogs().showLoadingDialog();
    dynamic generateCode = await LoginAPi().sendAuthCode(arguments["phone"]);
    dynamic response = Map<String, dynamic>.from(generateCode);
    Get.back();
    myDuration = const Duration(minutes: 1);
    setState(() {});
    startTimer();
    if (response["success"]) {
      int code = response["code"];
      arguments['code'] = code.toString();
    } else {
      countdownTimer!.cancel();
      customSnackbar(
          ActionType.error, "Алдаа гарлаа, түр хүлээгээд дахин оролдоно уу", 3);
    }
  }

  Future<void> onCompleted(String value) async {
    if (arguments["code"] == value) {
      Get.toNamed(
        splashProvinceSelectScreenRoute,
        arguments: arguments,
      );
    } else {
      Get.back();
      customSnackbar(ActionType.error, "Баталгаажуулах код буруу байна", 3);
    }
  }

  @override
  void dispose() {
    super.dispose();
    countdownTimer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    return CustomHeader(
      customActions: Container(),
      title: "Баталгаажуулах",
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: MyColors.fadedGrey, shape: BoxShape.circle),
              child: Image(
                image: const AssetImage("assets/images/png/password.png"),
                width: Get.width * .1,
              ),
            ),
            SizedBox(height: Get.height * .03),
            CustomText(
              text:
                  "${arguments["phone"]} дугаарлуу илгээсэн нэвтрэх кодыг оруулна уу",
              color: MyColors.gray,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Get.height * .03),
            PinCodeTextField(
              autoFocus: true,
              appContext: context,
              cursorColor: MyColors.primary,
              controller: controller,
              cursorWidth: 1,
              length: 6,
              animationType: AnimationType.fade,
              keyboardType: TextInputType.number,
              textStyle: const TextStyle(fontSize: 16),
              pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 48,
                  fieldWidth: (Get.width - 90) / 6,
                  activeFillColor: Colors.white,
                  inactiveFillColor: MyColors.white,
                  selectedFillColor: MyColors.white,
                  borderWidth: 1,
                  activeColor: MyColors.grey,
                  inactiveColor: MyColors.grey,
                  selectedColor: MyColors.primary),
              animationDuration: const Duration(milliseconds: 300),
              enableActiveFill: true,
              onCompleted: onCompleted,
              onChanged: (value) {},
              enablePinAutofill: false,
              useExternalAutoFillGroup: true,
            ),
            SizedBox(height: Get.height * .03),
            myDuration.inSeconds.isLowerThan(1)
                ? TextButton(
                    onPressed: sendOTP,
                    child: const CustomText(
                      text: "Дахин код авах",
                      fontSize: 14,
                      color: MyColors.black,
                    ),
                  )
                : CustomText(
                    text:
                        '$minutes:$seconds секундын дараа дахин код авах боломжтой',
                    fontSize: 14,
                    textAlign: TextAlign.center,
                  ),
          ],
        ),
      ),
    );
  }
}
