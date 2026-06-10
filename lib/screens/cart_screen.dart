import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../utils/price_formatter.dart';
import '../viewmodel/cart_viewmodel.dart';
import '../viewmodel/catalog_viewmodel.dart';
import '../viewmodel/theme_notifier.dart';

typedef _DisplayItem = ({CartItem item, Product product, ProductSize? size});

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_onFormChanged);
    _emailCtrl.addListener(_onFormChanged);
  }

  void _onFormChanged() => setState(() {});

  @override
  void dispose() {
    _nameCtrl.removeListener(_onFormChanged);
    _emailCtrl.removeListener(_onFormChanged);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    return name.isNotEmpty && RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  List<_DisplayItem> _buildDisplayItems(List<CartItem> items, List<Product> products) {
    final result = <_DisplayItem>[];
    for (final item in items) {
      final product = products.cast<Product?>().firstWhere(
            (p) => p?.id == item.productId,
            orElse: () => null,
          );
      if (product == null) continue;
      final size = product.sizes.cast<ProductSize?>().firstWhere(
            (s) => s?.id == item.sizeId,
            orElse: () => null,
          );
      result.add((item: item, product: product, size: size));
    }
    return result;
  }

  Future<void> _confirmClear(BuildContext ctx, CartViewModel cartVm) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Очистить корзину?'),
        content: const Text('Все товары будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
    if (confirmed == true) await cartVm.clear();
  }

  Future<void> _placeOrder(CartViewModel cartVm) async {
    await cartVm.clear();
    _nameCtrl.clear();
    _emailCtrl.clear();
    _commentCtrl.clear();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Заказ оформлен!'),
        content: const Text('Спасибо за покупку. Ваш заказ принят в обработку.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отлично!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer2<CartViewModel, CatalogViewModel>(
      builder: (ctx, cartVm, catalogVm, _) {
        final displayItems = _buildDisplayItems(cartVm.items, catalogVm.products);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Корзина'),
            backgroundColor: Theme.of(ctx).colorScheme.primary,
            foregroundColor: Colors.white,
            actions: [
              if (displayItems.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: () => _confirmClear(ctx, cartVm),
                ),
              IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () =>
                    ctx.read<ThemeNotifier>().toggle(Theme.of(ctx).brightness),
              ),
            ],
          ),
          body: displayItems.isEmpty
              ? const _EmptyCartView()
              : _CartBody(
                  displayItems: displayItems,
                  cartVm: cartVm,
                  nameCtrl: _nameCtrl,
                  emailCtrl: _emailCtrl,
                  commentCtrl: _commentCtrl,
                  isFormValid: _isFormValid,
                  onPlaceOrder: () => _placeOrder(cartVm),
                ),
        );
      },
    );
  }
}

class _CartBody extends StatelessWidget {
  final List<_DisplayItem> displayItems;
  final CartViewModel cartVm;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController commentCtrl;
  final bool isFormValid;
  final VoidCallback onPlaceOrder;

  const _CartBody({
    required this.displayItems,
    required this.cartVm,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.commentCtrl,
    required this.isFormValid,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    final total = displayItems.fold<int>(
      0,
      (sum, e) => sum + e.product.priceInKopecks * e.item.quantity,
    );
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        ...displayItems.map(
          (e) => _CartItemRow(
            displayItem: e,
            onDecrement: () => cartVm.updateQuantity(
                e.item.productId, e.item.sizeId, e.item.quantity - 1),
            onIncrement: () => cartVm.updateQuantity(
                e.item.productId, e.item.sizeId, e.item.quantity + 1),
            onRemove: () => cartVm.removeItem(e.item.productId, e.item.sizeId),
          ),
        ),
        const Divider(height: 32, indent: 16, endIndent: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Итого',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                formatPrice(total),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 32, indent: 16, endIndent: 16),
        _OrderForm(
          nameCtrl: nameCtrl,
          emailCtrl: emailCtrl,
          commentCtrl: commentCtrl,
          isValid: isFormValid,
          onSubmit: onPlaceOrder,
        ),
      ],
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final _DisplayItem displayItem;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onRemove;

  const _CartItemRow({
    required this.displayItem,
    required this.onDecrement,
    required this.onIncrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final item = displayItem.item;
    final product = displayItem.product;
    final size = displayItem.size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                if (size != null)
                  Text(
                    'Размер: ${size.name}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                const SizedBox(height: 4),
                Text(
                  formatPrice(product.priceInKopecks * item.quantity),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _RoundButton(icon: Icons.remove, onPressed: onDecrement),
              SizedBox(
                width: 32,
                child: Text(
                  '${item.quantity}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              _RoundButton(icon: Icons.add, onPressed: onIncrement),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _OrderForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController commentCtrl;
  final bool isValid;
  final VoidCallback onSubmit;

  const _OrderForm({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.commentCtrl,
    required this.isValid,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Оформление заказа',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Имя *',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Email *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: commentCtrl,
            decoration: const InputDecoration(
              labelText: 'Комментарий',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isValid ? onSubmit : null,
              child: const Text('Оформить'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Корзина пуста',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Добавьте товары из каталога',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
