import 'package:flutter/material.dart';

class NewsSearchDelegate extends SearchDelegate {
  final Function loadNewsData;

  NewsSearchDelegate(this.loadNewsData);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear the query
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close search
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    loadNewsData(query: query); // Fetch filtered results
    return Center(
      child: Text("Searching for \"$query\"..."),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text("Suggestions will appear here"),
    );
  }
}

