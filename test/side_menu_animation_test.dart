import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:side_menu_animation/side_menu_animation.dart';

void main() {
  group('SideMenuAnimation::Tests', () {
    testWidgets('SideMenuAnimation:: Press menu - Show Scrim Widget',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SideMenuAnimation(
            appBarBuilder: (showMenu) => AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: showMenu),
            ),
            views: List.generate(4, (index) => Container()),
            items: List.generate(4, (index) => const SizedBox())
                .map((value) => value)
                .toList(),
            tapOutsideToDismiss: true,
            onItemSelected: (value) {},
          ),
        ),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets(
        'SideMenuAnimation:: Press menu, press scrim widget and hide menu',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SideMenuAnimation(
            appBarBuilder: (showMenu) => AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: showMenu),
            ),
            views: List.generate(4, (index) => Container()),
            items: List.generate(4, (index) => const SizedBox())
                .map((value) => value)
                .toList(),
            tapOutsideToDismiss: true,
            onItemSelected: (value) {},
          ),
        ),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedContainer), findsOneWidget);
      await tester.tap(find.byType(AnimatedContainer));
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedContainer), findsNothing);
    });

    testWidgets(
        'SideMenuAnimation:: Press menu, press item 2 and display page 2',
        (tester) async {
      int? _indexSelected;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SideMenuAnimation(
            appBarBuilder: (showMenu) => AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: showMenu),
            ),
            views: List.generate(
                4,
                (index) => Container(
                    color: Colors.red,
                    child: Center(child: Text('Page ${index + 1}')))),
            items: List.generate(
              4,
              (index) => Center(
                child: Text('Item $index'),
              ),
            ).map((value) => value).toList(),
            tapOutsideToDismiss: true,
            scrimColor: Colors.black45,
            onItemSelected: (value) {
              _indexSelected = value;
            },
          ),
        ),
      ));
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Item 3'));
      await tester.pumpAndSettle();
      expect(find.text('Page 3'), findsOneWidget);
      expect(_indexSelected, 3);
    });

        testWidgets(
        'SideMenuAnimation:: Press menu, if press item at index 0 page should not change',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SideMenuAnimation(
            appBarBuilder: (showMenu) => AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: showMenu),
            ),
            views: List.generate(
                4,
                (index) => Container(
                    color: Colors.red,
                    child: Center(child: Text('Page ${index + 1}')))),
            items: List.generate(
              4,
              (index) => Center(
                child: Text('Item $index'),
              ),
            ).map((value) => value).toList(),
            tapOutsideToDismiss: true,
            scrimColor: Colors.black45,
            onItemSelected: (value) {},
          ),
        ),
      ));
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Item 2'));
      await tester.pumpAndSettle();
      expect(find.text('Page 2'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Item 0'));
      await tester.pumpAndSettle();
      expect(find.text('Page 2'), findsOneWidget);
    });

    testWidgets(
        'SideMenuAnimation:: Press menu, when in page 1, press item 1 and stay in same page',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SideMenuAnimation(
            appBarBuilder: (showMenu) => AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: showMenu),
            ),
            views: List.generate(
                4,
                (index) => Container(
                    color: Colors.red,
                    child: Center(child: Text('Page ${index + 1}')))),
            items: List.generate(
              4,
              (index) => Center(
                child: Text('Item $index'),
              ),
            ).map((value) => value).toList(),
            tapOutsideToDismiss: true,
            scrimColor: Colors.black45,
            onItemSelected: (value) {},
          ),
        ),
      ));
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Item 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Item 1'));
      await tester.pumpAndSettle();
      expect(find.text('Page 1'), findsOneWidget);
    });

    testWidgets(
        'SideMenuAnimation:: Press menu, when pressed outside and tapOutsideToDismiss is false keep menu open',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SideMenuAnimation(
            appBarBuilder: (showMenu) => AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: showMenu),
            ),
            views: List.generate(
                4,
                (index) => Container(
                    color: Colors.red,
                    child: Center(child: Text('Page ${index + 1}')))),
            items: List.generate(
              4,
              (index) => Center(
                child: Text('Item $index'),
              ),
            ).map((value) => value).toList(),
            tapOutsideToDismiss: false,
            scrimColor: Colors.black45,
            onItemSelected: (value) {},
          ),
        ),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedContainer), findsNothing);
      await tester.tapAt(const Offset(400, 100));
      expect(find.byType(AnimatedContainer), findsNothing);
    });

    testWidgets(
        'SideMenuAnimation:: Press menu, when pressed outside and tapOutsideToDismiss is true close menu',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SideMenuAnimation(
            appBarBuilder: (showMenu) => AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: showMenu),
            ),
            views: List.generate(
                4,
                (index) => Container(
                    color: Colors.red,
                    child: Center(child: Text('Page ${index + 1}')))),
            items: List.generate(
              4,
              (index) => Center(
                child: Text('Item $index'),
              ),
            ).map((value) => value).toList(),
            tapOutsideToDismiss: true,
            scrimColor: Colors.black45,
            onItemSelected: (value) {},
          ),
        ),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(400, 100));
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedContainer), findsNothing);
    });

    testWidgets('SideMenuAnimation:: show AppBar', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SideMenuAnimation(
            appBarBuilder: (showMenu) => AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {},
              ),
            ),
            views: [
              Container(
                color: Colors.red,
                child: const Center(
                  child: Text('Page 1'),
                ),
              )
            ],
            items: [
              const Center(
                child: Text('Item 1'),
              )
            ],
            onItemSelected: (value) {},
          ),
        ),
      ));

      expect(find.byType(AppBar), findsOne);
    });
  });
}
