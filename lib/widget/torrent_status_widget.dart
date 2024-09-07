import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmp_client/bloc/torrent_bloc.dart';
import 'package:rmp_client/model/torrent.dart';
import 'package:rmp_client/repository/torrent_repository.dart';
import 'package:rmp_client/widget/torrent_listtile_widget.dart';

class TorrentStatusWidget extends StatelessWidget {
  final List<Torrent> torrents;

  const TorrentStatusWidget({Key? key, required this.torrents})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TorrentBloc bloc = BlocProvider.of(context);

    return Container(
      child: ListView(
        children: torrents
            .map((item) => Card(
                    child: TorrentListTileWidget(
                        title: Text(item.name, overflow: TextOverflow.ellipsis),
                        status: Text(
                            "Status: ${item.status}\n(${(item.size / 1000000).toStringAsFixed(1)} MB)",
                            style: TextStyle(color: item.statusColor)),
                        progress: LinearProgressIndicator(
                            value: item.progress / 100,
                            backgroundColor: Colors.blue[50]),
                        onLongPress: () {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("${TorrentRepository.baseUrl}")));
                        },
                        buttons: [
                      IconButton(
                        onPressed: () =>
                            bloc.add(ResumeTorrentEvent(torrent: item)),
                        icon: Icon(Icons.play_arrow),
                      ),
                      IconButton(
                          onPressed: () =>
                              bloc.add(PauseTorrentEvent(torrent: item)),
                          icon: Icon(Icons.pause)),
                      IconButton(
                          onPressed: () =>
                              bloc.add(DeleteTorrentEvent(torrent: item)),
                          icon: Icon(Icons.delete)),
                    ])))
            .toList(),
      ),
    );
  }
}
