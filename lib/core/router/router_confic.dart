import 'package:go_router/go_router.dart';
import 'package:suproxu/core/widgets/trade_warning.dart';
import 'package:suproxu/features/auth/change-pass/changePassword.dart';
import 'package:suproxu/features/auth/forgot-pass/forgetPassword.dart';
import 'package:suproxu/features/auth/login/loginPage.dart';
import 'package:suproxu/features/navbar/Portfolio/portfolio.dart';
import 'package:suproxu/features/navbar/TradeScreen/tradeTab.dart';
import 'package:suproxu/features/navbar/demo_nav.dart';
import 'package:suproxu/features/navbar/home/mcx/page/home/mcx_home.dart';
import 'package:suproxu/features/navbar/home/mcx/page/symbol/mcx_symbol.dart';
import 'package:suproxu/features/navbar/home/model/symbol_page_param.dart';
import 'package:suproxu/features/navbar/home/nse-future/page/nse_future.dart';
import 'package:suproxu/features/navbar/home/nse-future/page/nse_future_symbol_page.dart';
import 'package:suproxu/features/navbar/navbar.dart';
import 'package:suproxu/features/navbar/profile/accountScreen.dart';
import 'package:suproxu/features/navbar/profile/complaint/lodgeComplaint.dart';
import 'package:suproxu/features/navbar/profile/diposit/depositeScreen.dart';
import 'package:suproxu/features/navbar/profile/ledger/ledgerScreen.dart';
import 'package:suproxu/features/navbar/profile/notification/notificationScreen.dart';
import 'package:suproxu/features/navbar/profile/payment/paymentScreen.dart';
import 'package:suproxu/features/navbar/profile/profile/profile_info.dart';
import 'package:suproxu/features/navbar/profile/roles/superoxu_rules.dart';
import 'package:suproxu/features/navbar/profile/wallet/user_wallet.dart';
import 'package:suproxu/features/navbar/profile/withdraw/withdraw.dart';
import 'package:suproxu/features/navbar/wishlist/model/mcx_symbol_param.dart';
import 'package:suproxu/features/navbar/wishlist/wishlist-tabs/MCX-Tab/page/mcx_stock_wishlist_fixed.dart';
import 'package:suproxu/features/navbar/wishlist/wishlist.dart';
import 'package:suproxu/features/splash/splash_screen.dart';

final GoRouter routerConfig = GoRouter(
  initialLocation: SplashScreen.routeName,
  routes: [
    ShellRoute(
      builder: (context, state, child) => GlobalNavBar(child: child),
      routes: [
        // GoRoute(
        //   path: Mcxscreen.routeName,
        //   name: Mcxscreen.routeName,
        //   builder: (context, state) => Mcxscreen(),
        // ),
        // GoRoute(
        //   path: MCXStockPage.routeName,
        //   name: MCXStockPage.routeName,
        //   builder: (context, state) => const MCXStockPage(),
        // ),
        GoRoute(
          path: McxHome.routeName,
          name: McxHome.routeName,
          builder: (context, state) => const McxHome(),
        ),

        GoRoute(
          path: McxStockWishlist.routeName,
          name: McxStockWishlist.routeName,
          builder: (context, state) => const McxStockWishlist(),
        ),
        // GoRoute(
        //   path: NseFutureMain.routeName,
        //   name: NseFutureMain.routeName,
        //   builder: (context, state) => NseFutureMain(),
        // ),
        GoRoute(
          path: NotificationScreen.routeName,
          name: NotificationScreen.routeName,
          builder: (context, state) => const NotificationScreen(),
        ),
        GoRoute(
          path: WishList.routeName,
          name: WishList.routeName,
          builder: (context, state) => const WishList(),
        ),

        GoRoute(
          path: TradeTabsScreen.routeName,
          name: TradeTabsScreen.routeName,
          builder: (context, state) => const TradeTabsScreen(),
        ),
        GoRoute(
          path: LedgerReportScreen.routeName,
          name: LedgerReportScreen.routeName,
          builder: (context, state) => const LedgerReportScreen(),
        ),
        GoRoute(
          path: LodgeComplaintScreen.routeName,
          name: LodgeComplaintScreen.routeName,
          builder: (context, state) => const LodgeComplaintScreen(),
        ),
        GoRoute(
          path: DepositScreen.routeName,
          name: DepositScreen.routeName,
          builder: (context, state) => const DepositScreen(),
        ),
        GoRoute(
          path: PaymentScreen.routeName,
          name: PaymentScreen.routeName,
          builder: (context, state) => const PaymentScreen(),
        ),
        GoRoute(
          path: ProfileInfo.routeName,
          name: ProfileInfo.routeName,
          builder: (context, state) => const ProfileInfo(),
        ),
        GoRoute(
          path: NseFuture.routeName,
          name: NseFuture.routeName,
          builder: (context, state) => const NseFuture(),
        ),
        GoRoute(
          path: SuproxuRulesPage.routeName,
          name: SuproxuRulesPage.routeName,
          builder: (context, state) => const SuproxuRulesPage(),
        ),

        GoRoute(
          path: MCXSymbolRecordPage.routeName,
          name: MCXSymbolRecordPage.routeName,
          builder: (context, state) {
            final mcxSymbolParam = state.extra as MCXSymbolParams;
            return MCXSymbolRecordPage(params: mcxSymbolParam);
          },
        ),
        GoRoute(
          path: NseFutureSymbolPage.routeName,
          name: NseFutureSymbolPage.routeName,
          builder: (context, state) {
            final params = state.extra as SymbolScreenParams;
            return NseFutureSymbolPage(params: params);
          },
        ),
        // GoRoute(
        //   path: NseFutureStockWishlist.routeName,
        //   name: NseFutureStockWishlist.routeName,
        //   builder: (context, state) {
        //     return const NseFutureStockWishlist();
        //   },
        // ),
        GoRoute(
          path: DemoUi.routeName,
          name: DemoUi.routeName,
          builder: (context, state) => const DemoUi(),
        ),
        GoRoute(
          path: Portfolioclose.routeName,
          name: Portfolioclose.routeName,
          builder: (context, state) => Portfolioclose(
            showCloseTab:
                (state.extra as Map<String, dynamic>?)?['showCloseTab'] ??
                false,
          ),
        ),
        GoRoute(
          path: Accountscreen.routeName,
          name: Accountscreen.routeName,
          builder: (context, state) => const Accountscreen(),
        ),
        GoRoute(
          path: WithdrawPage.routeName,
          name: WithdrawPage.routeName,
          builder: (context, state) => const WithdrawPage(),
        ),
        GoRoute(
          path: UserWalletPage.routeName,
          name: UserWalletPage.routeName,
          builder: (context, state) => const UserWalletPage(),
        ),
        GoRoute(
          path: ChangePasswordScreen.routeName,
          name: ChangePasswordScreen.routeName,
          builder: (context, state) => const ChangePasswordScreen(),
        ),
      ],
    ),
    GoRoute(
      path: TradeWarning.routeName,
      name: TradeWarning.routeName,
      builder: (context, state) {
        final updatePassword = state.extra as String;
        return TradeWarning(updatePassword: updatePassword);
      },
    ),
    GoRoute(
      path: LoginPages.routeName,
      name: LoginPages.routeName,
      builder: (context, state) => const LoginPages(),
    ),
    GoRoute(
      path: GlobalNavBar.routeName,
      name: GlobalNavBar.routeName,
      builder: (context, state) => const GlobalNavBar(),
    ),
    GoRoute(
      path: SplashScreen.routeName,
      name: SplashScreen.routeName,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: Forgetpassword.routeName,
      name: Forgetpassword.routeName,
      builder: (context, state) => const Forgetpassword(),
    ),
  ],
);
