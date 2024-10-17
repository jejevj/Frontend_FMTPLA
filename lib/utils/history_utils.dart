import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:fmtpla_code/models/history.dart'; // Import your History model

class HistoryAPI {
  // The base URL for fetching history data
  static const String _baseUrl =
      'https://apps.syscloud.my.id/gambar_api/get-history';

  // Function to fetch history data from the API
  static Future<List<History>> fetchHistory() async {
    try {
      // Make the GET request to the API
      final response = await http.get(Uri.parse(_baseUrl));

      // Check if the response status is successful
      if (response.statusCode == 200) {
        // Decode the JSON response into a list of dynamic objects
        List<dynamic> jsonResponse = json.decode(response.body);

        // Convert the dynamic list into a list of History objects
        List<History> historyList =
            jsonResponse.map((data) => History.fromJson(data)).toList();

        return historyList; // Return the list of History objects
      } else {
        // If the response status is not 200, throw an error
        throw Exception('Failed to load history');
      }
    } catch (error) {
      // Handle and rethrow any errors that occurred during the request
      throw Exception('Error fetching history: $error');
    }
  }
}
