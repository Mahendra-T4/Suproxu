// import 'package:trading_app/core/Database/key.dart';
// import 'package:trading_app/core/Database/user_db.dart';

// class ClientConfig {
//   static late String userFirstName;
//   static late String userLastName;
//   static late String userEmail;
//   static late String mobileNumber;
//   static late String alternateMobile;
//   static late String tradeBalance;
//   static late String userProfilePic;
//   static late String userTrade;
//   static late String userPoints;
//   static late String agentQr;
//   static late String uKey;

//   static Future<void> initStudents() async {
//     DatabaseService service = DatabaseService();
//     userFirstName = await service.getUserData(key: userFirstNameKey);
//     userLastName = await service.getUserData(key: userLastNameKey);
//     userEmail = await service.getUserData(key: userEmailIDKey);
//     mobileNumber = await service.getUserData(key: mobileNumberKey);
//     alternateMobile = await service.getUserData(key: alternateMobileKey);
//     tradeBalance = await service.getUserData(key: userBalanceKey);
//     userProfilePic = await service.getUserData(key: userImageKey);
//     uKey = await service.getUserData(key: userKey);
//     userTrade = await service.getUserData(key: userTradeKey);
//     userPoints = await service.getUserData(key: userPointsKey);
//     agentQr = await service.getUserData(key: agentQR);
//   }
// }
