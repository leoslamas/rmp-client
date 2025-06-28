import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rmp_client/error/exception.dart';
import 'package:rmp_client/model/search_result.dart';
import 'package:rmp_client/repository/torrent_repository.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final TorrentRepository _repo;
  final _searchController = StreamController<String>();
  late final StreamSubscription _searchSubscription;

  SearchCubit({required TorrentRepository repository})
      : _repo = repository,
        super(SearchInitialState()) {
    _searchSubscription = _searchController.stream
        .debounceTime(const Duration(milliseconds: 500))
        .distinct()
        .where((terms) => terms.trim().isNotEmpty)
        .listen(_performSearch);
  }

  void search(String terms) {
    _searchController.add(terms);
  }

  void _performSearch(String terms) async {
    emit(SearchLoadingState(result: state.result));

    try {
      final result = await _repo.searchTorrents(terms);
      emit(SearchResultState(result: result));
    } catch (e) {
      emit(SearchErrorState(result: state.result, error: e as RepositoryException));
    }
  }

  @override
  Future<void> close() {
    _searchSubscription.cancel();
    _searchController.close();
    return super.close();
  }

  void download(SearchResult torrent) async {
    emit(SearchDownloadState(torrent: torrent.name, result: state.result));

    try {
      await _repo.downloadTorrent(torrent.url);
      emit(SearchResultState(result: state.result));
    } catch (e) {
      emit(SearchErrorState(result: state.result, error: e as RepositoryException));
    }
  }
}
