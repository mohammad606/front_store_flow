import 'package:shared_preferences/shared_preferences.dart';
import 'package:storeflow/core/api/api_response.dart';
import 'package:storeflow/core/api/base_api_service.dart';
import 'package:storeflow/features/home/data/models/top_selling_product_model.dart';

class TopSellingProductsService extends BaseApiService {
  Future<ApiResponse<List<TopSellingProductModel>>> getTopSellingProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    return request<List<TopSellingProductModel>>(
      method: 'GET',
      path: '/orders/top-selling-products',
      token: token,
      fromJson: (data) {
        if (data is! List) {
          return <TopSellingProductModel>[];
        }

        return data
            .map((item) => TopSellingProductModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      },
    );
  }
}
