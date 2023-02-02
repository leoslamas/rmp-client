import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmp_client/bloc/search_cubit.dart';
import 'package:rmp_client/util/debouncer.dart';

class SearchWidget extends StatelessWidget {
  final Debouncer _debouncer = Debouncer(milliseconds: 1000);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'buscar mídia...',
          hintStyle: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
          border: InputBorder.none,
        ),
        style: TextStyle(
          color: Colors.white,
        ),
        onChanged: (text) {
          _debouncer.run(() {
            BlocProvider.of<SearchCubit>(context).search(text);
          });
        },
      ),
    );
  }
}
