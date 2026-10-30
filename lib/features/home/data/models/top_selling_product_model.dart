class TopSellingProductModel {
  final int id;
  final String name;
  final int quantity;
  final int box;
  final int soldQuantity;

  const TopSellingProductModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.box,
    required this.soldQuantity,
  });

  factory TopSellingProductModel.fromJson(Map<String, dynamic> json) {
    return TopSellingProductModel(
      id: int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      quantity: int.tryParse('${json['quantity']}') ?? 0,
      box: int.tryParse('${json['box']}') ?? 0,
      soldQuantity: int.tryParse('${json['sold_quantity']}') ?? 0,
    );
  }
}
