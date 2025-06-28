import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmp_client/bloc/torrent_bloc.dart';
import 'package:rmp_client/error/exception.dart';
import 'package:rmp_client/model/torrent.dart';
import 'package:rmp_client/repository/torrent_repository.dart';

class MockTorrentRepository extends Mock implements TorrentRepository {}
class FakeResumeTorrentEvent extends Fake implements ResumeTorrentEvent {}
class FakePauseTorrentEvent extends Fake implements PauseTorrentEvent {}
class FakeDeleteTorrentEvent extends Fake implements DeleteTorrentEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeResumeTorrentEvent());
    registerFallbackValue(FakePauseTorrentEvent());
    registerFallbackValue(FakeDeleteTorrentEvent());
  });
  group('TorrentBloc', () {
    late TorrentBloc torrentBloc;
    late MockTorrentRepository mockRepository;

    const testTorrents = [
      Torrent(1, 'Test Torrent 1', 1000000, 'downloading', 50),
      Torrent(2, 'Test Torrent 2', 2000000, 'done', 100),
    ];

    setUp(() {
      mockRepository = MockTorrentRepository();
      torrentBloc = TorrentBloc(repository: mockRepository);
    });

    tearDown(() {
      torrentBloc.close();
    });

    test('initial state should be TorrentInitialState', () {
      expect(torrentBloc.state, isA<TorrentInitialState>());
      expect(torrentBloc.state.torrents, isEmpty);
    });

    group('ListTorrentsEvent', () {
      blocTest<TorrentBloc, TorrentState>(
        'emits [TorrentLoadingState, TorrentResultState] when listTorrents succeeds',
        build: () {
          when(() => mockRepository.listTorrents())
              .thenAnswer((_) async => testTorrents);
          return torrentBloc;
        },
        act: (bloc) => bloc.add(ListTorrentsEvent()),
        expect: () => [
          const TorrentLoadingState(torrents: []),
          const TorrentResultState(torrents: testTorrents),
        ],
        verify: (_) {
          verify(() => mockRepository.listTorrents()).called(1);
        },
      );

      blocTest<TorrentBloc, TorrentState>(
        'emits [TorrentLoadingState, TorrentCommandError] when listTorrents fails',
        build: () {
          when(() => mockRepository.listTorrents())
              .thenThrow(RepositoryException('Network error'));
          return torrentBloc;
        },
        act: (bloc) => bloc.add(ListTorrentsEvent()),
        expect: () => [
          const TorrentLoadingState(torrents: []),
          isA<TorrentCommandError>(),
        ],
        verify: (_) {
          verify(() => mockRepository.listTorrents()).called(1);
        },
      );
    });

    group('ResumeTorrentEvent', () {
      const testTorrent = Torrent(1, 'Test Torrent', 1000000, 'paused', 50);

      blocTest<TorrentBloc, TorrentState>(
        'emits [TorrentResumingState, TorrentResultState] when resumeTorrent succeeds',
        build: () {
          when(() => mockRepository.resumeTorrent(any()))
              .thenAnswer((_) async => 'Success');
          when(() => mockRepository.listTorrents())
              .thenAnswer((_) async => testTorrents);
          return torrentBloc;
        },
        act: (bloc) => bloc.add(ResumeTorrentEvent(torrent: testTorrent)),
        expect: () => [
          const TorrentResumingState(torrentName: 'Test Torrent', torrents: []),
          const TorrentResultState(torrents: testTorrents),
        ],
        verify: (_) {
          verify(() => mockRepository.resumeTorrent(testTorrent.id)).called(1);
          verify(() => mockRepository.listTorrents()).called(1);
        },
      );

      blocTest<TorrentBloc, TorrentState>(
        'emits [TorrentResumingState, TorrentCommandError] when resumeTorrent fails',
        build: () {
          when(() => mockRepository.resumeTorrent(any()))
              .thenThrow(RepositoryException('Resume failed'));
          return torrentBloc;
        },
        act: (bloc) => bloc.add(ResumeTorrentEvent(torrent: testTorrent)),
        expect: () => [
          const TorrentResumingState(torrentName: 'Test Torrent', torrents: []),
          isA<TorrentCommandError>(),
        ],
        verify: (_) {
          verify(() => mockRepository.resumeTorrent(testTorrent.id)).called(1);
        },
      );
    });

    group('PauseTorrentEvent', () {
      const testTorrent = Torrent(1, 'Test Torrent', 1000000, 'downloading', 50);

      blocTest<TorrentBloc, TorrentState>(
        'emits [TorrentPausingState, TorrentResultState] when pauseTorrent succeeds',
        build: () {
          when(() => mockRepository.pauseTorrent(any()))
              .thenAnswer((_) async => 'Success');
          when(() => mockRepository.listTorrents())
              .thenAnswer((_) async => testTorrents);
          return torrentBloc;
        },
        act: (bloc) => bloc.add(PauseTorrentEvent(torrent: testTorrent)),
        expect: () => [
          const TorrentPausingState(torrentName: 'Test Torrent', torrents: []),
          const TorrentResultState(torrents: testTorrents),
        ],
        verify: (_) {
          verify(() => mockRepository.pauseTorrent(testTorrent.id)).called(1);
          verify(() => mockRepository.listTorrents()).called(1);
        },
      );

      blocTest<TorrentBloc, TorrentState>(
        'emits [TorrentPausingState, TorrentCommandError] when pauseTorrent fails',
        build: () {
          when(() => mockRepository.pauseTorrent(any()))
              .thenThrow(RepositoryException('Pause failed'));
          return torrentBloc;
        },
        act: (bloc) => bloc.add(PauseTorrentEvent(torrent: testTorrent)),
        expect: () => [
          const TorrentPausingState(torrentName: 'Test Torrent', torrents: []),
          isA<TorrentCommandError>(),
        ],
        verify: (_) {
          verify(() => mockRepository.pauseTorrent(testTorrent.id)).called(1);
        },
      );
    });

    group('DeleteTorrentEvent', () {
      const testTorrent = Torrent(1, 'Test Torrent', 1000000, 'downloading', 50);

      blocTest<TorrentBloc, TorrentState>(
        'emits [TorrentDeletingState, TorrentResultState] when deleteTorrent succeeds',
        build: () {
          when(() => mockRepository.deleteTorrent(any()))
              .thenAnswer((_) async => 'Success');
          when(() => mockRepository.listTorrents())
              .thenAnswer((_) async => testTorrents);
          return torrentBloc;
        },
        act: (bloc) => bloc.add(DeleteTorrentEvent(torrent: testTorrent)),
        expect: () => [
          const TorrentDeletingState(torrentName: 'Test Torrent', torrents: []),
          const TorrentResultState(torrents: testTorrents),
        ],
        verify: (_) {
          verify(() => mockRepository.deleteTorrent(testTorrent.id)).called(1);
          verify(() => mockRepository.listTorrents()).called(1);
        },
      );

      blocTest<TorrentBloc, TorrentState>(
        'emits [TorrentDeletingState, TorrentCommandError] when deleteTorrent fails',
        build: () {
          when(() => mockRepository.deleteTorrent(any()))
              .thenThrow(RepositoryException('Delete failed'));
          return torrentBloc;
        },
        act: (bloc) => bloc.add(DeleteTorrentEvent(torrent: testTorrent)),
        expect: () => [
          const TorrentDeletingState(torrentName: 'Test Torrent', torrents: []),
          isA<TorrentCommandError>(),
        ],
        verify: (_) {
          verify(() => mockRepository.deleteTorrent(testTorrent.id)).called(1);
        },
      );
    });
  });
}