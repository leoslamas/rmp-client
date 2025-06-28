import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmp_client/bloc/torrent_bloc.dart';
import 'package:rmp_client/repository/torrent_repository.dart';
import 'package:rmp_client/widget/torrent_status_widget.dart';

class TorrentBodyWidget extends StatelessWidget {
  const TorrentBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    TorrentBloc bloc = context.read<TorrentBloc>();

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<TorrentRepository>().ipDiscovery();
        bloc.add(ListTorrentsEvent());
      },
      child: BlocBuilder<TorrentBloc, TorrentState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is TorrentLoadingState) {
            return Stack(children: [
              const LinearProgressIndicator(),
              TorrentStatusWidget(torrents: state.torrents)
            ]);
          } else {
            return TorrentStatusWidget(torrents: state.torrents);
          }
        },
      ),
    );
  }
}
