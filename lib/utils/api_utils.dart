import 'dart:convert';
import 'dart:async'; // For Future and Timer
import 'package:fmtpla_code/models/photo.dart';
import 'package:http/http.dart' as http;

class ApiUtils {
  static const String apiUrl =
      'https://apps.syscloud.my.id/gambar_api/flickr-feed';

  // Fetch photos with all fields from the API and handle rate-limiting (status 429)
  static Future<List<Photo>> fetchPhotos(int page, {int retryCount = 3}) async {
    int attempt = 0; // To track retry attempts
    int delay = 3; // Initial delay for exponential backoff (in seconds)

    while (attempt < retryCount) {
      try {
        final response = await http.get(Uri.parse('$apiUrl?page=$page'));

        if (response.statusCode == 200) {
          // Success - Parse the photos and return them
          final data = json.decode(response.body);
          List<dynamic> photosJson = data['photos'];

          List<Photo> photos = [];
          for (var photoJson in photosJson) {
            try {
              Photo photo = Photo.fromJson(photoJson);

              // Clean the imageUrl to remove any query parameters or extra strings after the image format
              String cleanedUrl = _removeQueryParams(photo.imageUrl);
              photo = Photo(
                title: photo.title,
                photoLink: photo.photoLink,
                imageUrl: cleanedUrl, // Use the cleaned URL here
                published: photo.published,
                updated: photo.updated,
                dateTaken: photo.dateTaken,
                author: photo.author,
                authorUrl: photo.authorUrl,
                authorNsid: photo.authorNsid,
                authorIcon: photo.authorIcon,
                tags: photo.tags,
              );

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
        } else if (response.statusCode == 429) {
          // Rate-limiting (Too many requests), handle exponential backoff
          print('Received 429 status code. Too many requests.');

          // Check if the server sent a Retry-After header
          int retryAfter =
              delay; // Use the default delay if no Retry-After header
          if (response.headers.containsKey('retry-after')) {
            retryAfter = int.parse(response.headers['retry-after']!);
          }

          // Wait for the retry time before attempting again
          await Future.delayed(Duration(seconds: retryAfter));

          // Exponential backoff: Double the delay for the next attempt
          delay *= 2;
          attempt++;
          print(
              'Retrying... Attempt: $attempt after waiting $retryAfter seconds');
        } else {
          // Handle other errors (non-200 and non-429 responses)
          throw Exception('Failed to load photos: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching photos: $e');
        return [];
      }
    }

    // If retries are exhausted, return an empty list or handle appropriately
    throw Exception(
        'Failed to load photos after $retryCount attempts due to rate-limiting.');
  }

  // Helper method to remove query parameters or extra strings after the image format
  static String _removeQueryParams(String url) {
    // Define a regular expression to capture the URL part before any extra strings or query parameters
    final regExp =
        RegExp(r'(.+\.(jpg|jpeg|png|gif|bmp|webp))', caseSensitive: false);

    final match = regExp.firstMatch(url);
    if (match != null) {
      // Return the part of the URL that matches the image format
      return match.group(1)!;
    } else {
      // If no match, return the original URL (optional, depending on your use case)
      return url;
    }
  }
}
