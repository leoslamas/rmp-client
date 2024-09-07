import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rmp_client/error/exception.dart';
import 'package:rmp_client/model/search_result.dart';
import 'package:rmp_client/repository/torrent_repository.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final TorrentRepository _repo;

  SearchCubit({required TorrentRepository repository})
      : _repo = repository,
        super(SearchInitialState());

  void search(String terms) async {
    emit(SearchLoadingState(result: state.result));

    await _repo.searchTorrents(terms).then((result) {
      emit(SearchResultState(result: result));
    }).catchError((e) {
      emit(SearchErrorState(result: state.result, error: e));
    });
  }

  void download(SearchResult torrent) async {
    emit(SearchLoadingState(result: state.result));

    await _repo.downloadTorrent(torrent.url).then((value) {
      emit(SearchDownloadState(torrent: torrent.name, result: state.result));
    }).catchError((e) {
      emit(SearchErrorState(result: state.result, error: e));
    });
  }
}
