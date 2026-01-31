import 'package:flutter/material.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/service/connectivity/internet_connection_service.dart';
import 'package:suproxu/core/service/page/not_connected.dart';
import 'package:suproxu/core/widgets/app_bar.dart';
import 'package:suproxu/features/navbar/wishlist/repositories/wishlist_repo.dart';
import 'package:suproxu/features/navbar/wishlist/wishlist-tabs/MCX-Tab/page/mcx_stock_wishlist_fixed.dart';
import 'package:suproxu/features/navbar/wishlist/wishlist-tabs/NFO-Tab/page/nse_future_stock_wishlist.dart';

class WishList extends StatefulWidget {
  const WishList({super.key});
  static const String routeName = '/wishlist-screen';

  @override
  State<WishList> createState() => _WishListState();
}

class _WishListState extends State<WishList>
    with SingleTickerProviderStateMixin {
  // late WishlistBloc _wishlistBloc;
  late TabController _tabController;

  // Timer? _timer;
  // bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Keys to force rebuild of child wishlist pages when cleared
  Key _mcxKey = const ValueKey('mcx_wishlist_0');
  Key _nfoKey = const ValueKey('nfo_wishlist_0');

  Future<void> _handleClearMCX() async {
    try {
      await WishlistRepository.clearWatchListSymbols(category: 'MCX');
      if (!mounted) return;
      setState(() {
        // change key to force child rebuild
        _mcxKey = UniqueKey();
        isMCX = true;
        isNFO = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('MCX Wishlist Cleared')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing MCX Wishlist: $e')),
        );
      }
    }
  }

  Future<void> _handleClearNFO() async {
    try {
      await WishlistRepository.clearWatchListSymbols(category: 'NFO');
      if (!mounted) return;
      setState(() {
        _nfoKey = UniqueKey();
        isNFO = true;
        isMCX = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('NFO Wishlist Cleared')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing NFO Wishlist: $e')),
        );
      }
    }
  }

  bool isNFO = false;
  bool isMCX = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: InternetConnectionService().connectionStream,
      initialData: true, // Assume connected initially
      builder: (context, snapshot) {
        // Handle error state
        if (snapshot.hasError) {
          return const NoInternetConnection();
        }

        // Handle disconnected state
        if (snapshot.data == false) {
          return const NoInternetConnection();
        }

        // Handle loading state
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          color: greyColor,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: kWhiteColor,
              appBar: customAppBar(
                context: context,
                isShowNotify: true,
                clearMCX: _handleClearMCX,
                clearNFO: _handleClearNFO,
              ),
              body: SizedBox.expand(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => setState(() {
                        isMCX = true;
                        isNFO = false;
                      }),
                      child: Container(
                        height: 60,
                        width: double.infinity,
                        decoration: const BoxDecoration(color: zBlack),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              alignment: Alignment.center,
                              width: MediaQuery.sizeOf(context).width / 2,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      'MCX',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: kGoldenBraunColor,
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    thickness: 3,
                                    color: isMCX
                                        ? kGoldenBraunColor
                                        : Colors.transparent,
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => setState(() {
                                isNFO = true;
                                isMCX = false;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 10,
                                ),
                                alignment: Alignment.center,
                                width: MediaQuery.sizeOf(context).width / 2,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        'NFO',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: kGoldenBraunColor,
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      thickness: 3,
                                      color: isNFO
                                          ? kGoldenBraunColor
                                          : Colors.transparent,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    isMCX
                        ? Expanded(child: McxStockWishlist(key: _mcxKey))
                        : Expanded(child: NseFutureStockWishlist(key: _nfoKey)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    // : const NoInternetConnection();
  }
}
