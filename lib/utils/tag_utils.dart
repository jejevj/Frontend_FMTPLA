import 'dart:convert';
import 'package:fmtpla_code/models/photo.dart';
import 'package:http/http.dart' as http;

class TagUtils {
  static const String apiUrl =
      'https://apps.syscloud.my.id/gambar_api/flickr-feed';

  // Fetch photos by tag from the API
  static Future<List<Photo>> fetchPhotosByTag(String tag) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl?tags=$tag'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> photosJson = data['photos'];

        List<Photo> photos = [];
        for (var photoJson in photosJson) {
          try {
            Photo photo = Photo.fromJson(photoJson);

            // Check if imageUrl is not empty, is absolute, and ends with valid image formats
            if (photo.imageUrl.isNotEmpty &&
                Uri.parse(photo.imageUrl).isAbsolute &&
                photo.isValidImageUrl()) {
              photos.add(photo);
            }
          } catch (e) {
            print('Error parsing photo: $e');
          }
        }
        return photos;
      } else {
        throw Exception('Failed to load photos by tag');
      }
    } catch (e) {
      print('Error fetching photos by tag: $e');
      return [];
    }
  }
}
