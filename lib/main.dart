import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmp_client/bloc/search_cubit.dart';
import 'package:rmp_client/bloc/torrent_bloc.dart';
import 'package:rmp_client/repository/torrent_repository.dart';
import 'package:rmp_client/screen/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String title = 'Remote Media PI';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => TorrentRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                SearchCubit(repository: context.read<TorrentRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                TorrentBloc(repository: context.read<TorrentRepository>()),
          ),
        ],
        child: MaterialApp(
          title: title,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: HomeScreen(title: title),
        ),
      ),
    );
  }
}
