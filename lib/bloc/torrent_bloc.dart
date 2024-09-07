import 'package:bloc/bloc.dart';
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

      await _repo.listTorrents().then((torrents) {
        emit(TorrentResultState(torrents: torrents));
      }).catchError((e) {
        emit(TorrentCommandError(torrents: state.torrents, error: e));
      });
    });

    on<ResumeTorrentEvent>((event, emit) async {
      emit(TorrentLoadingState(torrents: state.torrents));

      await _repo.resumeTorrent(event.torrent.id).then((value) {
        emit(TorrentResumingState(
            torrentName: event.torrent.name, torrents: state.torrents));
      }).catchError((e) {
        emit(TorrentCommandError(torrents: state.torrents, error: e));
      });
    });

    on<PauseTorrentEvent>((event, emit) async {
      emit(TorrentLoadingState(torrents: state.torrents));

      await _repo.pauseTorrent(event.torrent.id).then((value) {
        emit(TorrentPausingState(
            torrentName: event.torrent.name, torrents: state.torrents));
      }).catchError((e) {
        emit(TorrentCommandError(torrents: state.torrents, error: e));
      });
    });

    on<DeleteTorrentEvent>((event, emit) async {
      emit(TorrentLoadingState(torrents: state.torrents));
      await _repo.deleteTorrent(event.torrent.id).then((value) {
        emit(TorrentDeletingState(
            torrentName: event.torrent.name, torrents: state.torrents));
      }).catchError((e) {
        emit(TorrentCommandError(torrents: state.torrents, error: e));
      });
    });
  }
}
