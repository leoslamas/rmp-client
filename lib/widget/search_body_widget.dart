import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmp_client/bloc/search_cubit.dart';
import 'package:rmp_client/widget/search_result_widget.dart';

class SearchBodyWidget extends StatelessWidget {
  const SearchBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      bloc: context.read<SearchCubit>(),
      builder: (context, state) {
        if (state is SearchLoadingState) {
          return Stack(children: [
            const LinearProgressIndicator(),
            SearchResultWidget(results: state.result)
          ]);
        } else {
          return SearchResultWidget(results: state.result);
        }
      },
    );
  }
}
