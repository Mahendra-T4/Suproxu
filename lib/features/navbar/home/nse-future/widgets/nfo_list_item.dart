import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/Assets/assets.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/extensions/color_blinker.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/features/navbar/home/model/symbol_page_param.dart';
import 'package:suproxu/features/navbar/home/nse-future/page/nse_future_symbol_page.dart';
import 'package:suproxu/features/navbar/wishlist/repositories/wishlist_repo.dart';

class NFOListItem extends StatefulWidget {
  final dynamic itemData;
  final VoidCallback onWishlistChanged;
  final int index;

  const NFOListItem({
    Key? key,
    required this.itemData,
    required this.onWishlistChanged,
    required this.index,
  }) : super(key: key);

  @override
  State<NFOListItem> createState() => _NFOListItemState();
}

class _NFOListItemState extends State<NFOListItem> {
  String _formatNumber(dynamic value) {
    if (value == null) return '0.00';
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.itemData.symbol != null) {
          GoRouter.of(context).pushNamed(
            NseFutureSymbolPage.routeName,
            extra: SymbolScreenParams(
              symbol: widget.itemData.symbol!,
              index: widget.index,
              symbolKey: widget.itemData.symbolKey.toString(),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 5),
        child: Column(
          children: [
            _buildMainRow(),
            const SizedBox(height: 4),
            _buildSecondaryRow(),
            SizedBox(height: 5.h),
            _buildDetailsRow(),
            Divider(thickness: 1.5, color: Colors.grey.shade800),
          ],
        ),
      ),
    );
  }

  Widget _buildMainRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.itemData.symbolName.toString().toUpperCase(),
              ).textStyleH1(),
            ],
          ),
        ),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBlinkingPrice(
                  assetId: widget.itemData.symbolKey.toString(),
                  price: widget.itemData.ohlcNSE!.salePrice,
                  lastPrice: widget.itemData.ohlcNSE!.lastPrice,
                ),
                SizedBox(width: 20.w),
                _buildBlinkingPrice(
                  assetId: widget.itemData.symbol.toString(),
                  price: widget.itemData.ohlcNSE!.buyPrice,
                  lastPrice: widget.itemData.ohlcNSE!.lastPrice,
                ),
                SizedBox(width: 5.w),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBlinkingPrice({
    required String assetId,
    required dynamic price,
    required dynamic lastPrice,
  }) {
    return BlinkingPriceText(
      assetId: assetId,
      text: "₹${_formatNumber(price)}",
      compareValue: double.parse(lastPrice.toString()),
      currentValue: double.parse(price.toString()),
    );
  }

  Widget _buildSecondaryRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(widget.itemData.expiryDate ?? '').textStyleH3()],
        ),
        _buildWishlistButton(),
      ],
    );
  }

  Widget _buildWishlistButton() {
    return InkWell(
      onTap: () async {
        final success = await WishlistRepository.addToWishlist(
          category: 'NFO',
          symbolKey: widget.itemData.symbolKey.toString(),
          context: context,
        );

        if (success && mounted) {
          widget.onWishlistChanged();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.itemData.watchlist == 1
                ? Colors.green
                : kGoldenBraunColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        width: 20,
        height: 20,
        child: widget.itemData.watchlist == 1
            ? Icon(Icons.check, size: 16, color: Colors.green)
            : null,
      ),
      // child: Image.asset(
      //   widget.itemData.watchlist == 1
      //       ? Assets.assetsImagesSupertradeRomoveWishlist
      //       : Assets.assetsImagesSuperTradeAddWishlist,
      //   scale: 19,
      //   color: widget.itemData.watchlist == 1
      //       ? Colors.deepPurpleAccent
      //       : kGoldenBraunColor,
      // ),
    );
  }

  Widget _buildDetailsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDetailItem(
          label: "Chg: ",
          value: _formatNumber(widget.itemData.change ?? 0.0),
          color: widget.itemData.change.toString().contains('-')
              ? Colors.red
              : Colors.green,
        ),
        _buildDetailItem2(
          label: "LTP: ",
          value: _formatNumber(widget.itemData.ohlcNSE!.lastPrice),
        ),
        _buildDetailItem2(
          label: "H: ",
          value: _formatNumber(widget.itemData.ohlcNSE!.high),
        ),
        _buildDetailItem2(
          label: "L: ",
          value: _formatNumber(widget.itemData.ohlcNSE!.low),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    Color? color,
  }) {
    final textStyle = TextStyle(
      color: color ?? zBlack,
      fontSize: 11.5,
      fontWeight: FontWeight.bold,
    );

    return Row(
      children: [
        Text(label, style: textStyle),
        Text(value, style: textStyle),
      ],
    );
  }

  Widget _buildDetailItem2({
    required String label,
    required String value,
    Color? color,
  }) {
    final textStyle = TextStyle(
      color: color ?? zBlack,
      fontSize: 11.5,
      fontWeight: FontWeight.bold,
    );

    return Row(
      children: [
        Text(label, style: textStyle).textStyleH3(),
        Text(value, style: textStyle).textStyleH3(),
      ],
    );
  }
}
