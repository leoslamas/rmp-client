import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmp_client/bloc/search_cubit.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextField(
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'buscar mídia...',
          hintStyle: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          color: Colors.white,
        ),
        onChanged: (text) {
          context.read<SearchCubit>().search(text);
        },
      ),
    );
  }
}
