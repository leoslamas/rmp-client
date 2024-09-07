part of 'search_cubit.dart';

@immutable
abstract class SearchState {
  final List<SearchResult> result;
  SearchState({required this.result});
}

class SearchInitialState extends SearchState {
  SearchInitialState() : super(result: []);
}

class SearchLoadingState extends SearchState {
  SearchLoadingState({required result}) : super(result: result);
}

class SearchResultState extends SearchState {
  SearchResultState({required result}) : super(result: result);
}

class SearchDownloadState extends SearchState {
  final String torrent;

  SearchDownloadState({required this.torrent, required result})
      : super(result: result);
}

class SearchErrorState extends SearchState {
  final RepositoryException error;
  SearchErrorState({required result, required this.error})
      : super(result: result);
}
