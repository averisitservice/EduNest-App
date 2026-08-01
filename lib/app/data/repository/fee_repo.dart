import 'package:edunest/app/core/base/base_repo.dart';
import 'package:edunest/app/core/network/dio_client.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/utils/app_urls.dart';
import 'package:edunest/app/data/model/fee/fee_detail_model.dart';
import 'package:edunest/app/data/model/fee/fee_order_model.dart';

class FeeRepo extends BaseRepo {
  Future<FeeDetailModel> getFeeDetail() async {
    try {
      var res = await DioClient.getInstance().get(AppUrls.getFeeDetail());
      return FeeDetailModel.fromJson(res.data['data']);
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }

  Future<FeeOrderModel> createFeeOrder(double amount) async {
    try {
      var res = await DioClient.getInstance().post(
        AppUrls.createFeeOrder(),
        data: {'amount': amount},
      );
      return FeeOrderModel.fromJson(res.data['data']);
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }

  Future<bool> verifyFeePayment({
    required int razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      var res = await DioClient.getInstance().post(
        AppUrls.verifyFeePayment(),
        data: {
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
        },
      );
      return res.data['data']['verified'] == true;
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }
}
