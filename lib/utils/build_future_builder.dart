import 'package:flutter/material.dart';

Widget buildFutureBuilder(List<Future<dynamic>> futures, Widget Function(List<dynamic>) builder) {
  return FutureBuilder(
    // Pass in the list of futures
    future: Future.wait(futures),
    // Build the page callback
    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
      return _handleSnapshot(snapshot, builder);
    },
  );
}

Widget _handleSnapshot(AsyncSnapshot<List<dynamic>> snapshot, Widget Function(List<dynamic>) builder) {
  if (snapshot.connectionState == ConnectionState.waiting ||
      snapshot.connectionState == ConnectionState.active) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  } else if (snapshot.connectionState == ConnectionState.done) {
    if (snapshot.hasData) {
      // Data preparation is complete, build the page
      final dataList = snapshot.data!;
      return builder(dataList);
    } else {
      return const Center(
        child: Text('Not Found Data'),
      );
    }
  } else if (snapshot.hasError) {
    // If an error occurs, display the error message
    return Center(
      child: Text('Error: ${snapshot.error}'),
    );
  } else {
    return const Center(
      child: Text('Unknown Error'),
    );
  }
}
