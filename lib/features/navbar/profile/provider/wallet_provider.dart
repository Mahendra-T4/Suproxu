import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suproxu/features/navbar/profile/model/balence_entity.dart';
import 'package:suproxu/features/navbar/profile/repository/profile_repo.dart';

final userWalletProvider = FutureProvider<BalanceEntity>(
  (ref) => ProfileRepository.userWallet(),
);
