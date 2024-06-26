import 'dart:developer';

import 'package:Erdenet24/controller/user_controller.dart';
import 'package:Erdenet24/widgets/button.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter/material.dart';

import 'package:Erdenet24/widgets/text.dart';
import 'package:Erdenet24/utils/shimmers.dart';
import 'package:Erdenet24/widgets/image.dart';
import 'package:Erdenet24/utils/routes.dart';
import 'package:Erdenet24/utils/styles.dart';
import 'package:Erdenet24/widgets/header.dart';
import 'package:Erdenet24/widgets/inkwell.dart';
import 'package:Erdenet24/widgets/custom_empty_widget.dart';
import 'package:Erdenet24/widgets/shimmer.dart';
import 'package:Erdenet24/api/dio_requests/user.dart';
import 'package:Erdenet24/controller/navigation_controller.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  bool loading = false;
  bool storeLoading = false;
  List categories = [];
  List storeList = [];
  String title = "";
  int category = 0;
  bool isHomePage = true;
  PageController controller = PageController();
  final _navCtx = Get.put(NavigationController());
  final _userCtx = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    getMainCategories();
  }

  void getMainCategories() async {
    if (_userCtx.categories.isEmpty) {
      loading = true;
      dynamic getMainCategories = await UserApi().getMainCategories();
      dynamic response = Map<String, dynamic>.from(getMainCategories);
      if (response["success"]) {
        categories = response["data"];
      }
      loading = false;
    } else {
      categories = _userCtx.categories;
    }
    setState(() {});
  }

  void getStoreList() async {
    storeLoading = true;
    dynamic getMainCategories = await UserApi().getStoreList(category);
    dynamic response = Map<String, dynamic>.from(getMainCategories);
    if (response["success"]) {
      storeList = response["data"];
      log("storeList: $storeList");
    }
    storeLoading = false;
    setState(() {});
  }

  void animateToPage(int id) {
    controller.animateToPage(
      id,
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );
    storeList.clear();
    storeLoading = true;
    setState(() {});
  }

  void showWarningDialog(String title, VoidCallback onPressed) {
    showGeneralDialog(
      context: Get.context!,
      barrierLabel: "",
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, a1, a2) {
        return Container();
      },
      transitionBuilder: (ctx, a1, a2, child) {
        var curve = Curves.bounceInOut.transform(a1.value);
        return WillPopScope(
          onWillPop: () async => false,
          child: Transform.scale(
            scale: curve,
            child: Center(
              child: Container(
                width: Get.width,
                margin: EdgeInsets.all(Get.width * .09),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                padding: EdgeInsets.only(
                  right: Get.width * .09,
                  left: Get.width * .09,
                  top: Get.height * .04,
                  bottom: Get.height * .03,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        IconlyBold.info_circle,
                        size: Get.width * .15,
                        color: Colors.amber,
                      ),
                      SizedBox(height: Get.height * .02),
                      Text(
                        "Анхааруулга",
                        style: const TextStyle(
                          color: MyColors.gray,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: Get.height * .02),
                      Column(
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: Get.height * .04),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                  child: CustomButton(
                                onPressed: () {
                                  Get.back();
                                  animateToPage(0);
                                },
                                bgColor: Colors.white,
                                text: "Үгүй",
                                elevation: 0,
                                textColor: Colors.black,
                              )),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  elevation: 0,
                                  bgColor: Colors.amber,
                                  text: "Тийм",
                                  onPressed: onPressed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isHomePage) {
          return true;
        } else {
          animateToPage(0);
          isHomePage = true;
          setState(() {});
          return false;
        }
      },
      child: PageView(
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (value) {},
        controller: controller,
        children: [
          _homeScreenMainView(),
          _homeScreenStoreListView(),
        ],
      ),
    );
  }

  Widget _homeScreenMainView() {
    return CustomHeader(
      customLeading: IconButton(
        onPressed: () {
          _navCtx.openDrawer();
        },
        icon: const Icon(
          Icons.menu_rounded,
          color: MyColors.black,
        ),
      ),
      customTitle: GestureDetector(
        onTap: () => Get.toNamed(userSearchBarScreenRoute),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 40,
          decoration: BoxDecoration(
            color: MyColors.background.withAlpha(92),
            borderRadius: BorderRadius.circular(
              50,
            ),
          ),
          child: Row(
            children: const [
              Icon(
                IconlyLight.search,
                color: MyColors.primary,
                size: 18,
              ),
              SizedBox(width: 12),
              CustomText(
                text: "Та юу хайж байна?",
                color: MyColors.gray,
                fontSize: 14,
              ),
            ],
          ),
        ),
      ),
      customActions: IconButton(
        onPressed: () {
          Get.toNamed(userQrScanScreenRoute);
        },
        icon: const Icon(
          IconlyLight.scan,
          color: MyColors.black,
        ),
      ),
      body: _bodyWidget(),
    );
  }

  Widget _bodyWidget() {
    return Container(
      color: MyColors.background.withAlpha(92),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _button(1),
                _button(2),
                _button(3),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _button(4),
                _button(5),
                _button(6),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _button(7),
                _button(8),
                _button(9),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _button(int index) {
    var item = loading ? null : categories[index - 1];
    return loading
        ? Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomShimmer(
                        width: Get.width * .16,
                        height: Get.width * .16,
                        borderRadius: 50,
                      ),
                      SizedBox(height: Get.height * .04),
                      CustomShimmer(width: Get.width * .2, height: 16)
                    ],
                  )),
            ),
          )
        : Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CustomInkWell(
                onTap: () {
                  title = item["name"];
                  isHomePage = false;
                  setState(() {});
                  animateToPage(1);
                  if (item["warning"] != "") {
                    showWarningDialog(item["warning"], () {
                      Get.back();
                      category = item["id"];
                      setState(() {});
                      getStoreList();
                    });
                  } else {
                    category = item["id"];
                    setState(() {});
                    getStoreList();
                  }
                },
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          customImage(
                            Get.width * .16,
                            item["image"],
                            isCircle: true,
                          ),
                          SizedBox(height: Get.height * .04),
                          Text(
                            item["name"] ?? "",
                            style: TextStyle(
                              color: !item["empty"]
                                  ? MyColors.black
                                  : MyColors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    item["ribbon"] != ""
                        ? Container(
                            foregroundDecoration:
                                RotatedCornerDecoration.withColor(
                              color: Colors.red,
                              spanBaselineShift: 4,
                              badgeSize: const Size(56, 56),
                              badgeCornerRadius: const Radius.circular(12),
                              textSpan: TextSpan(
                                text: item["ribbon"],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    BoxShadow(
                                        color: Colors.yellowAccent,
                                        blurRadius: 8),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _homeScreenStoreListView() {
    return CustomHeader(
      customLeading: CustomInkWell(
        onTap: () {
          isHomePage = true;
          setState(() {});
          animateToPage(0);
        },
        child: const Center(
          child: Icon(
            IconlyLight.arrow_left,
            color: MyColors.black,
            size: 20,
          ),
        ),
      ),
      title: title,
      customActions: Container(),
      body: storeLoading && storeList.isEmpty
          ? listShimmerWidget()
          : !storeLoading && storeList.isEmpty
              ? customEmptyWidget("Дэлгүүр байхгүй байна")
              : RefreshIndicator(
                  color: MyColors.primary,
                  onRefresh: () async {
                    storeList.clear();
                    await Future.delayed(const Duration(milliseconds: 600));
                    setState(() {});
                    getStoreList();
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    separatorBuilder: (context, index) {
                      return Container(
                        height: 7,
                        color: MyColors.fadedGrey,
                      );
                    },
                    shrinkWrap: true,
                    itemCount: storeList.isEmpty ? 6 : storeList.length,
                    itemBuilder: (context, index) {
                      if (storeList.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        var data = storeList[index];
                        return CustomInkWell(
                          onTap: () {
                            Get.toNamed(userProductsScreenRoute, arguments: {
                              "title": data["name"],
                              "id": data["id"],
                              "isOpen": data["isOpen"]
                            });
                          },
                          borderRadius: BorderRadius.zero,
                          child: SizedBox(
                            height: Get.width * .2 + 16,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  customImage(
                                    Get.width * .2,
                                    data["image"],
                                    isCircle: true,
                                    isFaded: !data["isOpen"],
                                    fadeText: "Хаалттай",
                                  ),
                                  SizedBox(width: Get.width * .05),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          data["name"],
                                          style: const TextStyle(
                                            color: MyColors.black,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          data["description"],
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        RatingBar.builder(
                                          itemSize: 20,
                                          initialRating: double.parse(
                                              data["rating"] ?? "0"),
                                          minRating: 0,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          unratedColor: MyColors.background,
                                          itemPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 2),
                                          itemBuilder: (context, _) =>
                                              const Icon(
                                            IconlyBold.star,
                                            color: Colors.amber,
                                          ),
                                          onRatingUpdate: (rating) {},
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: Get.width * .1,
                                    child: data["withSale"] != null &&
                                            data["withSale"] == 1
                                        ? Column(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  "SALE",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
    );
  }
}
