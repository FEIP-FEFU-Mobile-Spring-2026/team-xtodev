import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../viewmodel/catalog_viewmodel.dart';
import '../widgets/product_card.dart';
import '../widgets/product_detail_sheet.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FastBuy'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CatalogViewModel>(
        builder: (context, vm, _) => switch (vm.status) {
          CatalogStatus.initial || CatalogStatus.loading => const _LoadingView(),
          CatalogStatus.error => _ErrorView(
              message: vm.error ?? 'Ошибка загрузки',
              onRetry: vm.load,
            ),
          CatalogStatus.success => _CatalogContent(vm: vm),
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

void _openDetail(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ProductDetailSheet(product: product),
  );
}

class _CatalogContent extends StatelessWidget {
  final CatalogViewModel vm;

  const _CatalogContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    final tabs = vm.tabs;
    final products = vm.filteredProducts;

    return Column(
      children: [
        if (vm.isOffline)
          Container(
            width: double.infinity,
            color: Colors.orange.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.wifi_off, size: 16, color: Colors.deepOrange.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Нет сети. Показаны сохранённые данные.',
                    style: TextStyle(fontSize: 12, color: Colors.deepOrange.shade900),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 48,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (int i = 0; i < tabs.length; i++) ...[
                  FilterChip(
                    label: Text(tabs[i].name),
                    selected: vm.selectedTabIndex == i,
                    showCheckmark: false,
                    onSelected: (_) => vm.selectTab(i),
                  ),
                  if (i < tabs.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? const Center(
                  child: Text('Нет товаров', style: TextStyle(color: Colors.grey)),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, i) => ProductCard(
                    product: products[i],
                    onTap: () => _openDetail(context, products[i]),
                  ),
                ),
        ),
      ],
    );
  }
}
