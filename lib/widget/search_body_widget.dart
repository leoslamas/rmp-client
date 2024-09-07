import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmp_client/bloc/search_cubit.dart';
import 'package:rmp_client/widget/search_result_widget.dart';

class SearchBodyWidget extends StatelessWidget {
  const SearchBodyWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      bloc: BlocProvider.of(context),
      builder: (context, state) {
        if (state is SearchLoadingState) {
          return Stack(children: [
            LinearProgressIndicator(),
            SearchResultWidget(results: state.result)
          ]);
        } else {
          return SearchResultWidget(results: state.result);
        }
      },
    );
  }
}
