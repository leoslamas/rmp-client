part of 'torrent_bloc.dart';

@immutable
abstract class TorrentEvent {}

class ListTorrentsEvent extends TorrentEvent {}

class ListTorrentsDelayedEvent extends TorrentEvent {}

class ResumeTorrentEvent extends TorrentEvent {
  final Torrent torrent;
  ResumeTorrentEvent({@required this.torrent});
}

class PauseTorrentEvent extends TorrentEvent {
  final Torrent torrent;
  PauseTorrentEvent({@required this.torrent});
}

class DeleteTorrentEvent extends TorrentEvent {
  final Torrent torrent;
  DeleteTorrentEvent({@required this.torrent});
}
