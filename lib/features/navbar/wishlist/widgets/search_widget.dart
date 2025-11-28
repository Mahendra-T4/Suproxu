import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget(
      {super.key,
      this.searchController,
      this.isReadOnly = false,
      this.hint,
      this.onTap});
  final TextEditingController? searchController;
  final bool isReadOnly;
  final String? hint;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(
        horizontal: 10.w,
      ),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: searchController,
        // focusNode: _searchFocusNode,
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
        readOnly: isReadOnly,
        onTap: onTap,
        onChanged: (query) {},
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20.r),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    );
  }
}
