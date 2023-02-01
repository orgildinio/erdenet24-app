import 'dart:developer';
import 'package:Erdenet24/api/dio_requests.dart';
import 'package:Erdenet24/api/restapi_helper.dart';
import 'package:Erdenet24/screens/user/home/product_screen.dart';
import 'package:Erdenet24/utils/helpers.dart';
import 'package:Erdenet24/utils/shimmers.dart';
import 'package:Erdenet24/utils/styles.dart';
import 'package:Erdenet24/widgets/inkwell.dart';
import 'package:Erdenet24/widgets/loading.dart';
import 'package:Erdenet24/widgets/separator.dart';
import 'package:flutter/material.dart';
import 'package:Erdenet24/widgets/text.dart';
import 'package:get/get.dart';

class GoingOrdersView extends StatefulWidget {
  const GoingOrdersView({super.key});

  @override
  State<GoingOrdersView> createState() => _GoingOrdersViewState();
}

class _GoingOrdersViewState extends State<GoingOrdersView> {
  bool loading = false;
  @override
  void initState() {
    super.initState();
    getOrders();
  }

  dynamic _data = [];
  void getOrders() async {
    setState(() {
      loading = true;
    });
    var body = {"userId": RestApiHelper.getUserId()};
    dynamic response = await RestApi().getOrders(body);
    dynamic d = Map<String, dynamic>.from(response);
    setState(() {
      loading = false;
    });
    log(d.toString());
    if (d["success"]) {
      setState(() {
        _data = d["data"];
      });
    }
  }

  String timeDiffCalctr(time) {
    var difference = DateTime.now().difference(DateTime.parse(time)).inMinutes;
    return difference.toString();
  }

  void _showOrderDetauls(dynamic data) {
    var products = data["products"];
    Get.bottomSheet(
      SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            color: MyColors.white,
            padding: EdgeInsets.symmetric(
                horizontal: Get.width * .03, vertical: Get.width * .05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(text: "Хаяг:"),
                    CustomText(text: data["address"])
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(text: "Утас:"),
                    CustomText(text: data["phone"])
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(text: "Нийт үнэ:"),
                    CustomText(
                        text: convertToCurrencyFormat(
                      double.parse(data["totalAmount"]),
                      toInt: true,
                      locatedAtTheEnd: true,
                    ))
                  ],
                ),
                SizedBox(height: Get.height * .03),
                MySeparator(color: MyColors.grey),
                SizedBox(height: Get.height * .03),
                ListView.separated(
                    separatorBuilder: (context, index) {
                      return Container(height: 8);
                    },
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: Get.width * .15,
                            child: CachedImage(
                                image:
                                    "${URL.AWS}/products/${products[index]["id"]}.png"),
                          ),
                          SizedBox(
                            width: Get.width * .6,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: products[index]["name"],
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 12,
                                ),
                                CustomText(
                                  text: convertToCurrencyFormat(
                                    double.parse(products[index]["price"]),
                                    toInt: true,
                                    locatedAtTheEnd: true,
                                  ),
                                  fontSize: 12,
                                ),
                                CustomText(
                                  text: products[index]["storeName"],
                                  fontSize: 12,
                                  color: MyColors.gray,
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MyColors.fadedGrey,
                              shape: BoxShape.circle,
                            ),
                            child: CustomText(
                              text: products[index]["quantity"].toString(),
                              fontSize: 14,
                              isLowerCase: true,
                            ),
                          ),
                        ],
                      );
                    }),
                SizedBox(height: Get.height * .01)
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _data.isEmpty && !loading
        ? const CustomLoadingIndicator(text: "Шинэ захиалга байхгүй байна")
        : ListView.separated(
            separatorBuilder: (context, index) {
              return Container(height: 12);
            },
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: _data.isEmpty ? 6 : _data.length,
            itemBuilder: (context, index) {
              if (_data.isEmpty) {
                return MyShimmers().listView();
              } else {
                var data = _data[index];
                return _listItem(data);
              }
            });
  }

  Widget _listItem(data) {
    return CustomInkWell(
      onTap: () {
        _showOrderDetauls(data);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: Get.width * .3,
                      child: CustomText(
                        text: data["orderId"].toString(),
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                        child: CustomText(
                      text: "${timeDiffCalctr(data["orderTime"])} минутын өмнө",
                      color: MyColors.warning,
                      fontSize: 12,
                      textAlign: TextAlign.end,
                    ))
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SizedBox(
                      width: Get.width * .3,
                      child: const CustomText(
                        text: "Хаяг:",
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                        child: CustomText(
                      text: data["address"],
                      overflow: TextOverflow.ellipsis,
                      fontSize: 12,
                      textAlign: TextAlign.end,
                    ))
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SizedBox(
                      width: Get.width * .3,
                      child: const CustomText(
                        text: "Утас:",
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: CustomText(
                        text: data["phone"],
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SizedBox(
                      width: Get.width * .3,
                      child: const CustomText(
                        text: "Нийт үнэ:",
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                        child: CustomText(
                      text: convertToCurrencyFormat(
                          double.parse(data["totalAmount"]),
                          locatedAtTheEnd: true,
                          toInt: true),
                      fontSize: 12,
                      color: MyColors.black,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.end,
                    ))
                  ],
                ),
                const SizedBox(height: 12),
                _status(
                    data["orderStatus"] == "sent"
                        ? 1
                        : data["orderStatus"] == "preparing"
                            ? 2
                            : data["orderStatus"] == "delivering"
                                ? 3
                                : 0,
                    data["orderTime"])
              ],
            )),
      ),
    );
  }

  Widget _status(int step, String time) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: step.isEqual(1)
              ? MainAxisAlignment.start
              : step.isEqual(2)
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.end,
          children: [
            CustomText(
              text: time,
              color: MyColors.gray,
              fontSize: 10,
            )
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.circle,
              size: 10,
              color: step.isEqual(1) ? MyColors.primary : MyColors.gray,
            ),
            Expanded(
                child: Container(
              width: double.infinity,
              height: 1,
              color: MyColors.background,
            )),
            Icon(
              Icons.circle,
              size: 10,
              color: step.isEqual(2) ? MyColors.primary : MyColors.gray,
            ),
            Expanded(
                child: Container(
              width: double.infinity,
              height: 1,
              color: MyColors.background,
            )),
            Icon(
              Icons.circle,
              size: 10,
              color: step.isEqual(3) ? MyColors.primary : MyColors.gray,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: "Захиалга\nхүлээн авсан",
              fontSize: 10,
              textAlign: TextAlign.left,
              color: step.isEqual(1) ? MyColors.black : MyColors.gray,
            ),
            CustomText(
              text: "Хүргэлтэнд\nбэлдэж байна",
              fontSize: 10,
              textAlign: TextAlign.center,
              color: step.isEqual(2) ? MyColors.black : MyColors.gray,
            ),
            CustomText(
              text: "Хүргэлтэнд\nгарсан",
              fontSize: 10,
              textAlign: TextAlign.right,
              color: step.isEqual(3) ? MyColors.black : MyColors.gray,
            )
          ],
        )
      ],
    );
  }
}