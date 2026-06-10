class CartItem {
  final String productId;
  final String sizeId;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.sizeId,
    required this.quantity,
  });

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        sizeId: sizeId,
        quantity: quantity ?? this.quantity,
      );
}
