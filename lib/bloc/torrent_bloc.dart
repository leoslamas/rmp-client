import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rmp_client/error/exception.dart';
import 'package:rmp_client/model/torrent.dart';
import 'package:rmp_client/repository/torrent_repository.dart';

part 'torrent_event.dart';
part 'torrent_state.dart';

class TorrentBloc extends Bloc<TorrentEvent, TorrentState> {
  final TorrentRepository _repo;

  TorrentBloc({required TorrentRepository repository})
      : _repo = repository,
        super(TorrentInitialState()) {
    on<ListTorrentsEvent>((event, emit) async {
      emit(TorrentLoadingState(torrents: state.torrents));

      try {
        final torrents = await _repo.listTorrents();
        emit(TorrentResultState(torrents: torrents));
      } catch (e) {
        final error = e is RepositoryException ? e : RepositoryException(e.toString());
        emit(TorrentCommandError(torrents: state.torrents, error: error));
      }
    });

    on<ResumeTorrentEvent>((event, emit) async {
      emit(TorrentResumingState(
          torrentName: event.torrent.name, torrents: state.torrents));

      try {
        await _repo.resumeTorrent(event.torrent.id);
        final torrents = await _repo.listTorrents();
        emit(TorrentResultState(torrents: torrents));
      } catch (e) {
        final error = e is RepositoryException ? e : RepositoryException(e.toString());
        emit(TorrentCommandError(torrents: state.torrents, error: error));
      }
    });

    on<PauseTorrentEvent>((event, emit) async {
      emit(TorrentPausingState(
          torrentName: event.torrent.name, torrents: state.torrents));

      try {
        await _repo.pauseTorrent(event.torrent.id);
        final torrents = await _repo.listTorrents();
        emit(TorrentResultState(torrents: torrents));
      } catch (e) {
        final error = e is RepositoryException ? e : RepositoryException(e.toString());
        emit(TorrentCommandError(torrents: state.torrents, error: error));
      }
    });

    on<DeleteTorrentEvent>((event, emit) async {
      emit(TorrentDeletingState(
          torrentName: event.torrent.name, torrents: state.torrents));
      
      try {
        await _repo.deleteTorrent(event.torrent.id);
        final torrents = await _repo.listTorrents();
        emit(TorrentResultState(torrents: torrents));
      } catch (e) {
        final error = e is RepositoryException ? e : RepositoryException(e.toString());
        emit(TorrentCommandError(torrents: state.torrents, error: error));
      }
    });
  }
}
