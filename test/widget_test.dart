import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fastbuy/data/product_repository.dart';
import 'package:fastbuy/viewmodel/catalog_viewmodel.dart';
import 'package:fastbuy/main.dart';

void main() {
  testWidgets('FastBuyApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<CatalogViewModel>(
        create: (_) => CatalogViewModel(ProductRepository()),
        child: const FastBuyApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
