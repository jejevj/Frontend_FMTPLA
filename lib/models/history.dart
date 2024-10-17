class History {
  final int historyId;
  final String accessUrl;
  final String searchQuery;

  History({
    required this.historyId,
    required this.accessUrl,
    required this.searchQuery,
  });

  // Factory constructor to create a History object from JSON
  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      historyId: json['history_id'],
      accessUrl: json['access_url'],
      searchQuery: json['search_query'],
    );
  }

  // Method to convert a History object into JSON
  Map<String, dynamic> toJson() {
    return {
      'history_id': historyId,
      'access_url': accessUrl,
      'search_query': searchQuery,
    };
  }
}
