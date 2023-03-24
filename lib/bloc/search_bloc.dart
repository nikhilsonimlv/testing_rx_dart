import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:testing_rx_dart/bloc/api.dart';
import 'package:testing_rx_dart/bloc/search_result.dart';

@immutable
class SearchBloc {
  final Sink<String> inputString;
  final Stream<SearchResult?> resultedString;

  const SearchBloc._({
    required this.inputString,
    required this.resultedString,
  });

  void dispose(){
    inputString.close();
  }

  factory SearchBloc({required Api api}) {
    final textChanges = BehaviorSubject<String>();
    final Stream<SearchResult?> results = textChanges
        .distinct()
        .debounceTime(
          const Duration(milliseconds: 300),
        )
        .switchMap<SearchResult?>((String term) {
      if (term.isEmpty) {
        return Stream<SearchResult?>.value(null);
      } else {
        return Rx.fromCallable(() => api.search(term))
            .delay(const Duration(milliseconds: 200))
            .map((results) => results.isEmpty ? const SearchResultNoResult() : SearchResultWithResults(results))
            .startWith(const SearchResultLoading())
            .onErrorReturnWith((error, _) => SearchResultHasError(error));
      }
    });

    return SearchBloc._(inputString: textChanges.sink,resultedString:results );
  }


}
