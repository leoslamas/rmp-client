part of 'torrent_bloc.dart';

@immutable
abstract class TorrentState {
  final List<Torrent> torrents;
  TorrentState({required this.torrents});
}

class TorrentInitialState extends TorrentState {
  TorrentInitialState() : super(torrents: []);
}

class TorrentLoadingState extends TorrentState {
  TorrentLoadingState({required torrents}) : super(torrents: torrents);
}

class TorrentResultState extends TorrentState {
  TorrentResultState({required torrents}) : super(torrents: torrents);
}

class TorrentResumingState extends TorrentState {
  final String torrentName;

  TorrentResumingState({required this.torrentName, required torrents})
      : super(torrents: torrents);
}

class TorrentPausingState extends TorrentState {
  final String torrentName;

  TorrentPausingState({required this.torrentName, required torrents})
      : super(torrents: torrents);
}

class TorrentDeletingState extends TorrentState {
  final String torrentName;

  TorrentDeletingState({required this.torrentName, required torrents})
      : super(torrents: torrents);
}

class TorrentCommandError extends TorrentState {
  final RepositoryException error;
  TorrentCommandError({required torrents, required this.error})
      : super(torrents: torrents);
}
