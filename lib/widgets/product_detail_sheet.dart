import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/price_formatter.dart';

class ProductDetailSheet extends StatefulWidget {
  final Product product;

  const ProductDetailSheet({super.key, required this.product});

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  String? _selectedSizeId;

  void _showInfoDialog() {
    final p = widget.product;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Характеристики'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _InfoRow('Материал', p.material),
            _InfoRow('Вес', p.weight),
            _InfoRow('Сезон', p.season),
            _InfoRow('Страна', p.countryOfOrigin),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(onClose: () => Navigator.pop(context)),
          Stack(
            children: [
              Image.network(
                product.imageUrl,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 240,
                    color: Colors.grey.shade100,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  height: 240,
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey),
                  ),
                ),
              ),
              if (product.tags.isNotEmpty)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Wrap(
                    spacing: 6,
                    children: product.tags.map((t) => _TagBadge(tag: t)).toList(),
                  ),
                ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: _showInfoDialog,
                        padding: const EdgeInsets.only(left: 8),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(product.priceInKopecks),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.longDescription,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  if (product.sizes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Размер',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.sizes.map((size) {
                        return ChoiceChip(
                          label: Text(size.name),
                          selected: _selectedSizeId == size.id,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _selectedSizeId = size.id),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                child: const Text('В корзину'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _SheetHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 48),
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
      ],
    );
  }
}

class _TagBadge extends StatelessWidget {
  final String tag;

  const _TagBadge({required this.tag});

  @override
  Widget build(BuildContext context) {
    final color = switch (tag) {
      'New' => Colors.green,
      'Sale' => Colors.red,
      'Popular' => Colors.indigo,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
