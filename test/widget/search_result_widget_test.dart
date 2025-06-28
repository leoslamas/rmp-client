import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmp_client/bloc/search_cubit.dart';
import 'package:rmp_client/model/search_result.dart';
import 'package:rmp_client/widget/search_result_widget.dart';

class MockSearchCubit extends Mock implements SearchCubit {}

void main() {
  group('SearchResultWidget', () {
    late MockSearchCubit mockSearchCubit;

    final testResults = [
      SearchResult('Test Movie 1', '10', '5', '1024', 'http://example.com/1.torrent'),
      SearchResult('Test Movie 2', '20', '8', '2048', 'http://example.com/2.torrent'),
      SearchResult('Test Series 1', '15', '3', '1536', 'http://example.com/3.torrent'),
    ];

    setUp(() {
      mockSearchCubit = MockSearchCubit();
      when(() => mockSearchCubit.state).thenReturn(SearchResultState(result: testResults));
      when(() => mockSearchCubit.stream).thenAnswer((_) => const Stream.empty());
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<SearchCubit>.value(
            value: mockSearchCubit,
            child: SearchResultWidget(results: testResults),
          ),
        ),
      );
    }

    testWidgets('should display all search results in a ListView', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));
      expect(find.byType(ListTile), findsNWidgets(3));
    });

    testWidgets('should display search result names', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Test Movie 1'), findsOneWidget);
      expect(find.text('Test Movie 2'), findsOneWidget);
      expect(find.text('Test Series 1'), findsOneWidget);
    });

    testWidgets('should display seeders and leechers information', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.textContaining('Seeds: 10'), findsOneWidget);
      expect(find.textContaining('Seeds: 20'), findsOneWidget);
      expect(find.textContaining('Seeds: 15'), findsOneWidget);
      
      expect(find.textContaining('Leechs: 10'), findsOneWidget); // Note: using seeders value as in original code
      expect(find.textContaining('Leechs: 20'), findsOneWidget);
      expect(find.textContaining('Leechs: 15'), findsOneWidget);
    });

    testWidgets('should display size information', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.textContaining('Size: 1024 MB'), findsOneWidget);
      expect(find.textContaining('Size: 2048 MB'), findsOneWidget);
      expect(find.textContaining('Size: 1536 MB'), findsOneWidget);
    });

    testWidgets('should display download buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.download), findsNWidgets(3));
    });

    testWidgets('should trigger download when download button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.download).first);
      await tester.pump();

      verify(() => mockSearchCubit.download(testResults.first)).called(1);
    });

    testWidgets('should show snackbar with full title on long press', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.longPress(find.byType(ListTile).first);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Full title: Test Movie 1'), findsOneWidget);
    });

    testWidgets('should handle empty results list', (WidgetTester tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: BlocProvider<SearchCubit>.value(
            value: mockSearchCubit,
            child: const SearchResultWidget(results: []),
          ),
        ),
      );

      await tester.pumpWidget(widget);

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsNothing);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('should truncate long titles with ellipsis', (WidgetTester tester) async {
      final longTitleResult = [
        SearchResult(
          'This is a very long movie title that should be truncated with ellipsis when displayed in the list tile',
          '5',
          '2',
          '512',
          'http://example.com/long.torrent'
        ),
      ];

      final widget = MaterialApp(
        home: Scaffold(
          body: BlocProvider<SearchCubit>.value(
            value: mockSearchCubit,
            child: SearchResultWidget(results: longTitleResult),
          ),
        ),
      );

      await tester.pumpWidget(widget);

      final titleText = tester.widget<Text>(find.text(longTitleResult.first.name));
      expect(titleText.overflow, TextOverflow.ellipsis);
    });
  });
}