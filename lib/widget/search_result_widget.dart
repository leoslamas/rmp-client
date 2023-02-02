import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmp_client/bloc/search_cubit.dart';
import 'package:rmp_client/model/search_result.dart';

class SearchResultWidget extends StatelessWidget {
  final List<SearchResult> _results;

  const SearchResultWidget({Key key, List<SearchResult> results})
      : _results = results,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
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
                              Text(" / "),
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
                        BlocProvider.of<SearchCubit>(context).download(item);
                      },
                      icon: Icon(Icons.download)),
                  contentPadding: EdgeInsets.only(left: 16),
                  onLongPress: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Full title: ${item.name}")));
                  },
                )))
            .toList(),
      ),
    );
  }
}
