import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/catalog_viewmodel.dart';
import '../widgets/product_card.dart';

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

class _CatalogContent extends StatelessWidget {
  final CatalogViewModel vm;

  const _CatalogContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    final tabs = vm.tabs;
    final products = vm.filteredProducts;

    return Column(
      children: [
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
                  itemBuilder: (_, i) => ProductCard(product: products[i]),
                ),
        ),
      ],
    );
  }
}
