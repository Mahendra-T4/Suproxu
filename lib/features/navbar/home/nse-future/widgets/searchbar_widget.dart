import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(12.r),
        // boxShadow: [
        //   BoxShadow(
        //       color: Colors.black.withOpacity(0.2),
        //       blurRadius: 8,
        //       offset: const Offset(0, 2))
        // ],
      ),
      child: Row(
        children: [
          SizedBox(
            // height: 45,
            // width: 45,
            child: IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                )),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              // focusNode: _searchFocusNode,
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
              onChanged: (query) {},
              decoration: InputDecoration(
                hintText: 'Search by symbol or price...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                prefixIcon:
                    Icon(Icons.search, color: Colors.grey[400], size: 20.r),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
