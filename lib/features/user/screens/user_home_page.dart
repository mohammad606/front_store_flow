import 'package:flutter/material.dart';
import 'package:storeflow/core/api/api_exception.dart';
import 'package:storeflow/core/api/api_response.dart';
import 'package:storeflow/features/home/data/models/top_selling_product_model.dart';
import 'package:storeflow/features/home/data/services/top_selling_products_service.dart';
import 'package:storeflow/features/user/widgets/custom_app_bar.dart';
import 'package:storeflow/features/user/widgets/custom_drawer.dart';

const Color _primaryBlue = Color(0xFF2563EB);
const Color _secondaryGray = Color(0xFF64748B);

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final TopSellingProductsService _topSellingProductsService =
      TopSellingProductsService();
  bool _isLoading = true;
  String _errorMessage = '';
  List<TopSellingProductModel> _topProducts = const [];

  @override
  void initState() {
    super.initState();
    _loadTopSellingProducts();
  }

  Future<void> _loadTopSellingProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final ApiResponse<List<TopSellingProductModel>> response =
          await _topSellingProductsService.getTopSellingProducts();

      if (!mounted) return;

      setState(() {
        _topProducts = response.data ?? const <TopSellingProductModel>[];
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      endDrawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up_rounded, color: _primaryBlue),
                      const SizedBox(width: 8),
                      const Text(
                        'أكثر 6 عناصر مبيعة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _loadTopSellingProducts,
                        icon: const Icon(Icons.refresh_rounded, color: _primaryBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: _primaryBlue,
                          ),
                        ),
                      ),
                    )
                  else if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    )
                  else if (_topProducts.isEmpty)
                    const Text(
                      'لا توجد بيانات حالياً.',
                      style: TextStyle(
                        color: _secondaryGray,
                        fontSize: 14,
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _topProducts.length > 6 ? 6 : _topProducts.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 12,
                        color: Color(0xFFE2E8F0),
                      ),
                      itemBuilder: (context, index) {
                        final product = _topProducts[index];
                        return Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _primaryBlue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: _primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'الكمية المتاحة: ${product.quantity}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _secondaryGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _primaryBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'تم بيع ${product.soldQuantity}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'المبيعات',
                    value: 'SAR 2,430',
                    color: _primaryBlue,
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'الطلبات',
                    value: '128',
                    color: const Color(0xFF64748B),
                    icon: Icons.shopping_bag_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معلومات سريعة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'حالة المخزون جيدة، وهناك 12 منتجاً يحتاج إلى متابعة خلال اليوم.',
                    style: TextStyle(
                      color: _secondaryGray,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: _secondaryGray,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

