import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:suproxu/core/Database/key.dart';
import 'package:suproxu/core/Database/user_db.dart';
import 'package:suproxu/core/constants/apis/api_urls.dart';
import 'package:suproxu/core/service/repositorie/global_respo.dart';
import 'package:suproxu/features/navbar/home/model/nse_enity.dart';

abstract class StockRepository {
  static final _dioClient = Dio(BaseOptions(
    contentType: 'application/json',
    responseType: ResponseType.json,
  ));

  static Future<NSEDataEntity> nseTradeDataLoader() async {
    try {
      final stockList = await GlobalRepository.stocksMapper();
      final databaseService = DatabaseService();
      final uKey = await databaseService.getUserData(key: userIDKey);
       DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final deviceID = androidInfo.id.toString();
      final stockName = stockList.stocks!
          .firstWhere((stock) => stock.categoryName == 'NSE')
          .categoryCode;

      final response = await _dioClient.post(
        superTradeBaseApiEndPointUrl,
        data: {
          'activity': "get-stock-list",
          'userKey': uKey,
          'dataRelatedTo': stockName,
          "deviceID": deviceID.toString(),
        },
      );

      if (response.statusCode == 200) {
        // Dio automatically converts JSON response to Map
        return NSEDataEntity.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load NSE data from server',
        );
      }
    } on DioException catch (e) {
      throw 'Network error: ${e.message}';
    } catch (e) {
      throw 'Error loading NSE data: $e';
    }
  }
}
