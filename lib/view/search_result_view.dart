import 'package:flutter/material.dart';
import 'package:testing_rx_dart/animal.dart';
import 'package:testing_rx_dart/person.dart';

import '../bloc/search_result.dart';

class SearchResultView extends StatelessWidget {
  final Stream<SearchResult?> searchResults;

  const SearchResultView({Key? key, required this.searchResults}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.hasData) {
          final results = snapshot.data;
          if (results is SearchResultHasError) {
            return const Text("Error");
          } else if (results is SearchResultLoading) {
            return const CircularProgressIndicator();
          } else if (results is SearchResultNoResult) {
            return const Text("No result for the query");
          } else if (results is SearchResultWithResults) {
            final listData = results.results;
            return Expanded(
              child: ListView.builder(
                itemCount: listData.length,
                itemBuilder: (context, index) {
                  final item = listData[index];
                  final String title;
                  if (item is Animal) {
                    title = "Animal";
                  } else if (item is Person) {
                    title = "Person";
                  } else {
                    title = "Unknown";
                  }
                  return ListTile(
                    title: Text(title),
                    subtitle: Text(
                      item.toString(),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Text("Unknown ");
          }
        }
        return const Text("Waiting");
      },
      stream: searchResults,
    );
  }
}
