import 'dart:convert';
import 'package:fmtpla_code/models/authors.dart';
import 'package:http/http.dart' as http;

class AuthorUtils {
  static const String apiUrl = 'https://apps.syscloud.my.id/gambar_api/authors';

  // Fetch authors from the API
  static Future<List<Author>> fetchAuthors() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> authorsJson = json.decode(response.body);

        List<Author> authors = authorsJson
            .map((authorJson) => Author.fromJson(authorJson))
            .toList();

        return authors;
      } else {
        throw Exception('Failed to load authors');
      }
    } catch (e) {
      print('Error fetching authors: $e');
      return [];
    }
  }
}
