import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmp_client/bloc/torrent_bloc.dart';
import 'package:rmp_client/model/torrent.dart';
import 'package:rmp_client/repository/torrent_repository.dart';
import 'package:rmp_client/widget/torrent_status_widget.dart';

class MockTorrentRepository extends Mock implements TorrentRepository {}
class MockTorrentBloc extends Mock implements TorrentBloc {}

// Fake classes for fallback values
class FakeResumeTorrentEvent extends Fake implements ResumeTorrentEvent {}
class FakePauseTorrentEvent extends Fake implements PauseTorrentEvent {}
class FakeDeleteTorrentEvent extends Fake implements DeleteTorrentEvent {}

void main() {
  setUpAll(() {
    // Register fallback values for TorrentEvent types
    registerFallbackValue(FakeResumeTorrentEvent());
    registerFallbackValue(FakePauseTorrentEvent());
    registerFallbackValue(FakeDeleteTorrentEvent());
  });

  group('TorrentStatusWidget', () {
    late MockTorrentRepository mockRepository;
    late MockTorrentBloc mockTorrentBloc;

    const testTorrents = [
      Torrent(1, 'Test Torrent 1', 1000000, 'downloading', 50),
      Torrent(2, 'Test Torrent 2', 2000000, 'done', 100),
      Torrent(3, 'Test Torrent 3', 500000, 'error', 25),
    ];

    setUp(() {
      mockRepository = MockTorrentRepository();
      mockTorrentBloc = MockTorrentBloc();
      
      when(() => mockTorrentBloc.state).thenReturn(const TorrentResultState(torrents: testTorrents));
      when(() => mockTorrentBloc.stream).thenAnswer((_) => Stream<TorrentState>.fromIterable([
        const TorrentResultState(torrents: testTorrents)
      ]));
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: MultiRepositoryProvider(
            providers: [
              RepositoryProvider<TorrentRepository>.value(value: mockRepository),
            ],
            child: BlocProvider<TorrentBloc>.value(
              value: mockTorrentBloc,
              child: const TorrentStatusWidget(torrents: testTorrents),
            ),
          ),
        ),
      );
    }

    testWidgets('should display all torrents in a ListView', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('should display torrent names', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Test Torrent 1'), findsOneWidget);
      expect(find.text('Test Torrent 2'), findsOneWidget);
      expect(find.text('Test Torrent 3'), findsOneWidget);
    });

    testWidgets('should display torrent status and size', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.textContaining('Status: downloading'), findsOneWidget);
      expect(find.textContaining('Status: done'), findsOneWidget);
      expect(find.textContaining('Status: error'), findsOneWidget);
      
      expect(find.textContaining('1.0 MB'), findsOneWidget);
      expect(find.textContaining('2.0 MB'), findsOneWidget);
      expect(find.textContaining('0.5 MB'), findsOneWidget);
    });

    testWidgets('should display progress indicators', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final progressIndicators = find.byType(LinearProgressIndicator);
      expect(progressIndicators, findsNWidgets(3));
    });

    testWidgets('should display action buttons for each torrent', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Each torrent should have play, pause, and delete buttons
      expect(find.byIcon(Icons.play_arrow), findsNWidgets(3));
      expect(find.byIcon(Icons.pause), findsNWidgets(3));
      expect(find.byIcon(Icons.delete), findsNWidgets(3));
    });

    testWidgets('should trigger resume event when play button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.play_arrow).first);
      await tester.pump();

      verify(() => mockTorrentBloc.add(any<ResumeTorrentEvent>())).called(1);
    });

    testWidgets('should trigger pause event when pause button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.pause).first);
      await tester.pump();

      verify(() => mockTorrentBloc.add(any<PauseTorrentEvent>())).called(1);
    });

    testWidgets('should trigger delete event when delete button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pump();

      verify(() => mockTorrentBloc.add(any<DeleteTorrentEvent>())).called(1);
    });

    testWidgets('should show snackbar when long pressed', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.longPress(find.byType(Card).first);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining(TorrentRepository.baseUrl), findsOneWidget);
    });
  });
}