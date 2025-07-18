import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmp_client/bloc/search_cubit.dart';
import 'package:rmp_client/model/search_result.dart';

class SearchResultWidget extends StatelessWidget {
  final List<SearchResult> _results;

  const SearchResultWidget({super.key, required List<SearchResult> results})
      : _results = results;

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: _results
            .map((item) => Card(
                    child: ListTile(
                  horizontalTitleGap: 0,
                  title: Text(item.name, overflow: TextOverflow.ellipsis),
                  subtitle: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("Seeds: ${item.seeders}",
                                  style: TextStyle(color: Colors.green[300])),
                              const Text(" / "),
                              Text("Leechs: ${item.seeders}",
                                  style: TextStyle(color: Colors.red[200])),
                            ],
                          ),
                          Text("Size: ${item.size} MB"),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        context.read<SearchCubit>().download(item);
                      },
                      icon: const Icon(Icons.download)),
                  contentPadding: const EdgeInsets.only(left: 16),
                  onLongPress: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Full title: ${item.name}")));
                  },
                )))
            .toList(),
    );
  }
}
