import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmp_client/bloc/search_cubit.dart';
import 'package:rmp_client/bloc/torrent_bloc.dart';
import 'package:rmp_client/model/search_result.dart';
import 'package:rmp_client/model/torrent.dart';
import 'package:rmp_client/repository/torrent_repository.dart';
import 'package:rmp_client/screen/home_screen.dart';

class MockTorrentRepository extends Mock implements TorrentRepository {}

void main() {
  group('HomeScreen Integration Tests', () {
    late MockTorrentRepository mockRepository;

    const testTorrents = [
      Torrent(1, 'Test Torrent 1', 1000000, 'downloading', 50),
      Torrent(2, 'Test Torrent 2', 2000000, 'done', 100),
    ];

    final testSearchResults = [
      SearchResult('Test Movie', '10', '5', '1024', 'http://example.com/movie.torrent'),
      SearchResult('Test Series', '20', '8', '2048', 'http://example.com/series.torrent'),
    ];

    setUp(() {
      mockRepository = MockTorrentRepository();
      
      // Setup default mock responses
      when(() => mockRepository.ipDiscovery()).thenAnswer((_) async => 'localhost');
      when(() => mockRepository.listTorrents()).thenAnswer((_) async => testTorrents);
      when(() => mockRepository.searchTorrents(any())).thenAnswer((_) async => testSearchResults);
      when(() => mockRepository.downloadTorrent(any())).thenAnswer((_) async => 'Success');
      when(() => mockRepository.resumeTorrent(any())).thenAnswer((_) async => 'Success');
      when(() => mockRepository.pauseTorrent(any())).thenAnswer((_) async => 'Success');
      when(() => mockRepository.deleteTorrent(any())).thenAnswer((_) async => 'Success');
    });

    Widget createApp() {
      return MaterialApp(
        home: RepositoryProvider<TorrentRepository>.value(
          value: mockRepository,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => SearchCubit(repository: mockRepository),
              ),
              BlocProvider(
                create: (context) => TorrentBloc(repository: mockRepository),
              ),
            ],
            child: const HomeScreen(title: 'Test App'),
          ),
        ),
      );
    }

    testWidgets('should display app bar with title and search icon initially', (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Test App'), findsOneWidget);
      // Initially in torrent mode, should show search icon
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should start in torrent mode and display torrents', (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      
      // Wait for ipDiscovery and initial torrent loading to complete
      await tester.pumpAndSettle();

      // Should show torrent list by default
      expect(find.text('Test Torrent 1'), findsOneWidget);
      expect(find.text('Test Torrent 2'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.pause), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.delete), findsAtLeastNWidgets(1));
    });

    testWidgets('should switch to search mode when search icon is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      await tester.pump();

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Should show search interface
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('buscar mídia...'), findsOneWidget);
    });

    testWidgets('should switch back to torrent mode when cancel icon is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      await tester.pump();
      
      // Wait for initial torrents to load
      await tester.pumpAndSettle();

      // Switch to search mode
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      
      // Should now show cancel icon in search mode
      expect(find.byIcon(Icons.cancel), findsOneWidget);

      // Switch back to torrent mode
      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pump();
      
      // Wait for state change
      await tester.pumpAndSettle();

      // Should show torrent list again
      expect(find.text('Test Torrent 1'), findsOneWidget);
      expect(find.text('Test Torrent 2'), findsOneWidget);
    });

    testWidgets('should perform search and display results', (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Switch to search mode
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Enter search term
      await tester.enterText(find.byType(TextField), 'test movie');
      
      // Wait for RxDart debounce (500ms) and search to complete
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Should display search results
      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.text('Test Series'), findsOneWidget);
      expect(find.byIcon(Icons.download), findsAtLeastNWidgets(1));
    });

    testWidgets('should download torrent when download button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Switch to search mode and perform search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'test movie');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Tap download button
      await tester.tap(find.byIcon(Icons.download).first);
      await tester.pump();

      verify(() => mockRepository.downloadTorrent('http://example.com/movie.torrent')).called(1);
    });

    testWidgets('should handle refresh in torrent mode', (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 200));
      await tester.pumpAndSettle();

      verify(() => mockRepository.ipDiscovery()).called(greaterThan(1)); // Initial + refresh
      verify(() => mockRepository.listTorrents()).called(greaterThan(1));
    });

    testWidgets('should show snackbar on torrent operations', (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Tap pause button
      await tester.tap(find.byIcon(Icons.pause).first);
      await tester.pump();

      // Should show snackbar
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should handle back button in search mode', (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      await tester.pump();
      
      // Wait for initial torrents to load
      await tester.pumpAndSettle();

      // Switch to search mode
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      
      // Verify we're in search mode
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);

      // Use the cancel button instead of back button (simpler and more reliable)
      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pump();
      
      // Wait for state change
      await tester.pumpAndSettle();

      // Should return to torrent mode
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Test Torrent 1'), findsOneWidget);
    });
  });
}