import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmp_client/bloc/search_cubit.dart';
import 'package:rmp_client/repository/torrent_repository.dart';
import 'package:rmp_client/widget/search_widget.dart';

class MockTorrentRepository extends Mock implements TorrentRepository {}
class MockSearchCubit extends Mock implements SearchCubit {}

void main() {
  group('SearchWidget', () {
    late MockSearchCubit mockSearchCubit;

    setUp(() {
      mockSearchCubit = MockSearchCubit();
      
      when(() => mockSearchCubit.state).thenReturn(SearchInitialState());
      when(() => mockSearchCubit.stream).thenAnswer((_) => const Stream.empty());
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<SearchCubit>.value(
            value: mockSearchCubit,
            child: const SearchWidget(),
          ),
        ),
      );
    }

    testWidgets('should display search input field', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('buscar mídia...'), findsOneWidget);
    });

    testWidgets('should have autofocus enabled', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autofocus, isTrue);
    });

    testWidgets('should trigger search when text changes (RxDart debouncing in cubit)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField), 'test movie');
      
      // With RxDart debouncing, the search call happens immediately to cubit
      // but cubit handles the debouncing internally
      verify(() => mockSearchCubit.search('test movie')).called(1);
    });

    testWidgets('should call search method for each text change (cubit handles debouncing)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField), 'test');
      await tester.enterText(find.byType(TextField), 'test movie');
      
      // Each call goes to cubit, but cubit debounces internally
      verify(() => mockSearchCubit.search('test')).called(1);
      verify(() => mockSearchCubit.search('test movie')).called(1);
    });

    testWidgets('should have correct text styling', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style?.color, Colors.white);
      expect(textField.decoration?.hintStyle?.color, Colors.white);
      expect(textField.decoration?.hintStyle?.fontStyle, FontStyle.italic);
    });
  });
}