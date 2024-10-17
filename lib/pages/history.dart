import 'package:flutter/material.dart';
import 'package:fmtpla_code/models/history.dart';
import 'package:fmtpla_code/utils/history_utils.dart'; // Import your HistoryAPI and History model

// Stateful HistoryPage to fetch and display history data
class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<History>> _historyList; // Future to hold history data

  @override
  void initState() {
    super.initState();
    _fetchHistory(); // Fetch history data when the page loads
  }

  // Function to fetch history
  Future<void> _fetchHistory() async {
    setState(() {
      _historyList = HistoryAPI.fetchHistory(); // Fetch history data
    });
  }

  // Function to refresh data on pull
  Future<void> _refreshHistory() async {
    await _fetchHistory(); // Fetch new data when pulled
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshHistory, // Called when the user pulls to refresh
        child: FutureBuilder<List<History>>(
          future: _historyList, // The future that will provide the history data
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator()); // Show loading indicator
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                      'Error: ${snapshot.error}')); // Show error message if there's an error
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text(
                      'No history available.')); // Show this if there's no history
            } else {
              // Data is loaded, show the list of history
              final historyList =
                  snapshot.data!; // Extract the list of History objects
              return ListView.builder(
                itemCount: historyList.length, // Number of items
                itemBuilder: (context, index) {
                  final history =
                      historyList[index]; // Get the history item at the index
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      title:
                          Text(history.searchQuery), // Display the search query
                      subtitle:
                          Text(history.accessUrl), // Display the access URL
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
