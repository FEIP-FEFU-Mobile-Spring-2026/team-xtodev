import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fastbuy/data/product_repository.dart';
import 'package:fastbuy/viewmodel/catalog_viewmodel.dart';
import 'package:fastbuy/viewmodel/cart_viewmodel.dart';
import 'package:fastbuy/viewmodel/theme_notifier.dart';
import 'package:fastbuy/main.dart';

void main() {
  testWidgets('FastBuyApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ThemeNotifier(),
          ),
          ChangeNotifierProvider(
            create: (_) => CatalogViewModel(
              ProductRepository(),
              connectivityStream: const Stream.empty(),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => CartViewModel(),
          ),
        ],
        child: const FastBuyApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
