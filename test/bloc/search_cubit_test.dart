import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmp_client/bloc/search_cubit.dart';
import 'package:rmp_client/error/exception.dart';
import 'package:rmp_client/model/search_result.dart';
import 'package:rmp_client/repository/torrent_repository.dart';

class MockTorrentRepository extends Mock implements TorrentRepository {}

void main() {
  group('SearchCubit', () {
    late SearchCubit searchCubit;
    late MockTorrentRepository mockRepository;

    final testSearchResults = [
      SearchResult('Test Movie 1', '10', '5', '1024', 'http://example.com/1.torrent'),
      SearchResult('Test Movie 2', '20', '8', '2048', 'http://example.com/2.torrent'),
    ];

    setUp(() {
      mockRepository = MockTorrentRepository();
      searchCubit = SearchCubit(repository: mockRepository);
    });

    tearDown(() {
      searchCubit.close();
    });

    test('initial state should be SearchInitialState', () {
      expect(searchCubit.state, isA<SearchInitialState>());
      expect(searchCubit.state.result, isEmpty);
    });

    group('search', () {
      blocTest<SearchCubit, SearchState>(
        'emits [SearchLoadingState, SearchResultState] when search succeeds with debouncing',
        build: () {
          when(() => mockRepository.searchTorrents(any()))
              .thenAnswer((_) async => testSearchResults);
          return searchCubit;
        },
        act: (cubit) => cubit.search('test query'),
        wait: const Duration(milliseconds: 600), // Wait for debounce
        expect: () => [
          const SearchLoadingState(result: []),
          SearchResultState(result: testSearchResults),
        ],
        verify: (_) {
          verify(() => mockRepository.searchTorrents('test query')).called(1);
        },
      );

      blocTest<SearchCubit, SearchState>(
        'emits [SearchLoadingState, SearchErrorState] when search fails with debouncing',
        build: () {
          when(() => mockRepository.searchTorrents(any()))
              .thenThrow(RepositoryException('Search failed'));
          return searchCubit;
        },
        act: (cubit) => cubit.search('test query'),
        wait: const Duration(milliseconds: 600), // Wait for debounce
        expect: () => [
          const SearchLoadingState(result: []),
          isA<SearchErrorState>(),
        ],
        verify: (_) {
          verify(() => mockRepository.searchTorrents('test query')).called(1);
        },
      );

      blocTest<SearchCubit, SearchState>(
        'does not emit anything when search query is empty (filtered by stream)',
        build: () => searchCubit,
        act: (cubit) => cubit.search(''),
        wait: const Duration(milliseconds: 600),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockRepository.searchTorrents(any()));
        },
      );

      blocTest<SearchCubit, SearchState>(
        'does not emit anything when search query is only whitespace (filtered by stream)',
        build: () => searchCubit,
        act: (cubit) => cubit.search('   '),
        wait: const Duration(milliseconds: 600),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockRepository.searchTorrents(any()));
        },
      );

      blocTest<SearchCubit, SearchState>(
        'debounces multiple rapid searches and only executes the last one',
        build: () {
          when(() => mockRepository.searchTorrents(any()))
              .thenAnswer((_) async => testSearchResults);
          return searchCubit;
        },
        act: (cubit) {
          cubit.search('test');
          cubit.search('test query');
          cubit.search('test query final');
        },
        wait: const Duration(milliseconds: 600),
        expect: () => [
          const SearchLoadingState(result: []),
          SearchResultState(result: testSearchResults),
        ],
        verify: (_) {
          // Should only call the final search term
          verify(() => mockRepository.searchTorrents('test query final')).called(1);
          verifyNever(() => mockRepository.searchTorrents('test'));
          verifyNever(() => mockRepository.searchTorrents('test query'));
        },
      );

      blocTest<SearchCubit, SearchState>(
        'filters out duplicate consecutive searches',
        build: () {
          when(() => mockRepository.searchTorrents(any()))
              .thenAnswer((_) async => testSearchResults);
          return searchCubit;
        },
        act: (cubit) {
          cubit.search('same query');
          cubit.search('same query'); // Should be filtered out
        },
        wait: const Duration(milliseconds: 600),
        expect: () => [
          const SearchLoadingState(result: []),
          SearchResultState(result: testSearchResults),
        ],
        verify: (_) {
          // Should only call once despite two identical searches
          verify(() => mockRepository.searchTorrents('same query')).called(1);
        },
      );
    });

    group('download', () {
      final testSearchResult = SearchResult(
        'Test Movie',
        '10',
        '5',
        '1024',
        'http://example.com/test.torrent'
      );

      blocTest<SearchCubit, SearchState>(
        'emits [SearchDownloadState, SearchResultState] when download succeeds',
        build: () {
          when(() => mockRepository.downloadTorrent(any()))
              .thenAnswer((_) async => 'Success');
          return searchCubit;
        },
        seed: () => SearchResultState(result: testSearchResults),
        act: (cubit) => cubit.download(testSearchResult),
        expect: () => [
          SearchDownloadState(
            torrent: 'Test Movie',
            result: testSearchResults,
          ),
          SearchResultState(result: testSearchResults),
        ],
        verify: (_) {
          verify(() => mockRepository.downloadTorrent('http://example.com/test.torrent')).called(1);
        },
      );

      blocTest<SearchCubit, SearchState>(
        'emits [SearchDownloadState, SearchErrorState] when download fails',
        build: () {
          when(() => mockRepository.downloadTorrent(any()))
              .thenThrow(RepositoryException('Download failed'));
          return searchCubit;
        },
        seed: () => SearchResultState(result: testSearchResults),
        act: (cubit) => cubit.download(testSearchResult),
        expect: () => [
          SearchDownloadState(
            torrent: 'Test Movie',
            result: testSearchResults,
          ),
          isA<SearchErrorState>(),
        ],
        verify: (_) {
          verify(() => mockRepository.downloadTorrent('http://example.com/test.torrent')).called(1);
        },
      );
    });
  });
}