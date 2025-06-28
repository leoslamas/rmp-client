part of 'torrent_bloc.dart';

@immutable
abstract class TorrentState extends Equatable {
  final List<Torrent> torrents;
  const TorrentState({required this.torrents});
  
  @override
  List<Object> get props => [torrents];
}

class TorrentInitialState extends TorrentState {
  TorrentInitialState() : super(torrents: []);
}

class TorrentLoadingState extends TorrentState {
  const TorrentLoadingState({required super.torrents});
}

class TorrentResultState extends TorrentState {
  const TorrentResultState({required super.torrents});
}

class TorrentResumingState extends TorrentState {
  final String torrentName;

  const TorrentResumingState({required this.torrentName, required super.torrents});
  
  @override
  List<Object> get props => [torrents, torrentName];
}

class TorrentPausingState extends TorrentState {
  final String torrentName;

  const TorrentPausingState({required this.torrentName, required super.torrents});
  
  @override
  List<Object> get props => [torrents, torrentName];
}

class TorrentDeletingState extends TorrentState {
  final String torrentName;

  const TorrentDeletingState({required this.torrentName, required super.torrents});
  
  @override
  List<Object> get props => [torrents, torrentName];
}

class TorrentCommandError extends TorrentState {
  final RepositoryException error;
  const TorrentCommandError({required super.torrents, required this.error});
  
  @override
  List<Object> get props => [torrents, error];
}
