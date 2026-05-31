import 'package:flutter/material.dart';

void main() {
  runApp(const FastBuyApp());
}

class FastBuyApp extends StatelessWidget {
  const FastBuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FastBuy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _categories = ['Электроника', 'Одежда', 'Дом', 'Спорт', 'Красота'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FastBuy'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SearchBar(
            hintText: 'Поиск товаров...',
            leading: const Icon(Icons.search),
            onChanged: (_) {},
          ),
          const SizedBox(height: 20),
          const Text('Категории', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => FilterChip(
                label: Text(_categories[i]),
                onSelected: (_) {},
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Популярные товары', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: 6,
            itemBuilder: (context, i) => _ProductCard(index: i),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final int index;

  const _ProductCard({required this.index});

  static const _names = [
    'Наушники Pro', 'Кроссовки Air', 'Рюкзак Urban',
    'Смарт-часы X', 'Куртка Winter', 'Лампа LED',
  ];

  static const _prices = ['3 990 ₽', '7 490 ₽', '2 190 ₽', '12 990 ₽', '5 690 ₽', '890 ₽'];

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.indigo.withAlpha(30),
              child: const Center(child: Icon(Icons.image_outlined, size: 48, color: Colors.indigo)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_names[index], style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(_prices[index], style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
