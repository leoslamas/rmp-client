import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmp_client/bloc/search_cubit.dart';
import 'package:rmp_client/bloc/torrent_bloc.dart';
import 'package:rmp_client/repository/torrent_repository.dart';
import 'package:rmp_client/widget/search_body_widget.dart';
import 'package:rmp_client/widget/search_widget.dart';
import 'package:rmp_client/widget/torrent_body_widget.dart';

enum ScreenState { SEARCH, TORRENT }

class HomeScreen extends StatefulWidget {
  final String title;

  HomeScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Icon _customIcon = Icon(Icons.search);
  late Widget _customSearchBar;
  late ScreenState screenState;

  void _torrentState() {
    _customIcon = Icon(Icons.search);
    _customSearchBar = Text(widget.title);
    screenState = ScreenState.TORRENT;
  }

  void _searchState() {
    _customIcon = Icon(Icons.cancel);
    _customSearchBar = SearchWidget();
    screenState = ScreenState.SEARCH;
  }

  @override
  void initState() {
    super.initState();
    screenState = ScreenState.TORRENT;
    _customSearchBar = Text(widget.title);
    context.read<TorrentRepository>().ipDiscovery().then((value) {
      BlocProvider.of<TorrentBloc>(context).add(ListTorrentsEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: _customSearchBar,
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    if (screenState == ScreenState.TORRENT) {
                      _searchState();
                    } else {
                      _torrentState();
                    }
                  });
                },
                icon: _customIcon)
          ],
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<SearchCubit, SearchState>(
              listener: (context, state) {
                String? text;
                if (state is SearchDownloadState)
                  text = "Downloading: ${state.torrent}";

                if (state is SearchErrorState)
                  text = "Error: ${state.error.message}";

                if (text != null && text.isNotEmpty) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(text)));
                }
              },
            ),
            BlocListener<TorrentBloc, TorrentState>(
              listener: (context, state) {
                String? text;
                if (state is TorrentResumingState)
                  text = "Resuming: ${state.torrentName}";
                if (state is TorrentPausingState)
                  text = "Pausing: ${state.torrentName}";
                if (state is TorrentDeletingState)
                  text = "Deleting: ${state.torrentName}";

                if (state is TorrentCommandError)
                  text = "Error: ${state.error.message}";

                if (text != null && text.isNotEmpty) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(text)));
                }
              },
            ),
          ],
          child: screenState == ScreenState.SEARCH
              ? SearchBodyWidget()
              : TorrentBodyWidget(),
        ),
      ),
      onWillPop: () async {
        if (screenState == ScreenState.SEARCH) {
          setState(() {
            _torrentState();
          });
          return false;
        }
        return true;
      },
    );
  }
}
