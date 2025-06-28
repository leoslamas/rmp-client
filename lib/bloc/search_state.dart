part of 'search_cubit.dart';

@immutable
abstract class SearchState extends Equatable {
  final List<SearchResult> result;
  const SearchState({required this.result});
  
  @override
  List<Object> get props => [result];
}

class SearchInitialState extends SearchState {
  SearchInitialState() : super(result: []);
}

class SearchLoadingState extends SearchState {
  const SearchLoadingState({required super.result});
}

class SearchResultState extends SearchState {
  const SearchResultState({required super.result});
}

class SearchDownloadState extends SearchState {
  final String torrent;

  const SearchDownloadState({required this.torrent, required super.result});
  
  @override
  List<Object> get props => [result, torrent];
}

class SearchErrorState extends SearchState {
  final RepositoryException error;
  const SearchErrorState({required super.result, required this.error});
  
  @override
  List<Object> get props => [result, error];
}
