import 'package:flutter/material.dart';
import 'package:testing_rx_dart/bloc/api.dart';
import 'package:testing_rx_dart/bloc/search_bloc.dart';
import 'package:testing_rx_dart/view/search_result_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final SearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    _searchBloc = SearchBloc(api: Api());
  }

  @override
  void dispose() {
    _searchBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children:  [
            TextField(
              decoration: const InputDecoration(hintText: "Enter your search"),
              onChanged:  _searchBloc.inputString.add,
            ),
            const SizedBox(height: 20,),
            SearchResultView(searchResults: _searchBloc.resultedString)
          ],
        ),
      ),
    );
  }
}
