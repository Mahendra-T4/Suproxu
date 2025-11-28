import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/Assets/assets.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/features/navbar/profile/notification/notificationScreen.dart';

PreferredSizeWidget customAppBar(
        {required BuildContext context, required bool isShowNotify}) =>
    AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Image.asset(
                Assets.assetsImagesSuproxulogo,
                height: 65.h,
                width: 65.w,
                // color: kWhiteColor,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (isShowNotify)
          IconButton(
            onPressed: () {
              GoRouter.of(context).pushNamed(NotificationScreen.routeName);
            },
            icon: Image.asset(
              Assets.assetsImagesSupertradeNotification,
              scale: 20,
              color: kGoldenBraunColor,
            ),
          ),
      ],
    );

PreferredSizeWidget customAppBarWithTitle(
        {required BuildContext context,
        required String title,
        required bool isShowNotify}) =>
    AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          spacing: 10,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Image.asset(
                Assets.assetsImagesSuproxulogo,
                height: 65.h,
                width: 65.w,
                // color: kWhiteColor,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kGoldenBraunColor,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (isShowNotify)
          IconButton(
            onPressed: () {
              GoRouter.of(context).pushNamed(NotificationScreen.routeName);
            },
            icon: Image.asset(
              Assets.assetsImagesSupertradeNotification,
              scale: 20,
              color: kWhiteColor,
            ),
          ),
      ],
    );
