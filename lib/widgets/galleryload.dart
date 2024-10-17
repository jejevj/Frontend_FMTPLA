import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class CustomImageLoader extends StatefulWidget {
  final String imageUrl;
  final int index; // Index of the current image
  final int currentIndex; // The current image index being processed
  final Function(int) onImageLoaded; // Callback when an image is loaded

  const CustomImageLoader({
    Key? key,
    required this.imageUrl,
    required this.index,
    required this.currentIndex,
    required this.onImageLoaded,
  }) : super(key: key);

  @override
  _CustomImageLoaderState createState() => _CustomImageLoaderState();
}

class _CustomImageLoaderState extends State<CustomImageLoader> {
  Uint8List? imageData; // To store the image bytes
  bool isLoading = true; // Track the loading state
  bool hasError = false; // Track if there was an error loading the image

  @override
  void initState() {
    super.initState();
    fetchImageWithCustomUserAgent();
  }

  // Fetch the image with a custom User-Agent header
  Future<void> fetchImageWithCustomUserAgent() async {
    try {
      final response = await http.get(
        Uri.parse(widget.imageUrl),
        headers: {
          "User-Agent":
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36"
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          imageData = response.bodyBytes; // Store image data
          isLoading = false;

          // Notify the parent that this image is loaded
          if (widget.index == widget.currentIndex) {
            widget.onImageLoaded(widget.index); // Move to the next image
          }
        });
      } else {
        print('Failed to load image: ${response.statusCode}');
        setState(() {
          hasError = true; // Mark as error to show error icon
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading image: $e');
      setState(() {
        hasError = true; // Mark as error in case of an exception
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Display error icon if there was an error loading the image
    if (hasError) {
      return const Icon(Icons.error, size: 40); // Show error icon on failure
    }

    return isLoading
        ? const Center(
            child: CircularProgressIndicator()) // Show loader while fetching
        : imageData != null
            ? Image.memory(
                imageData!,
                fit: BoxFit.cover,
              )
            : const SizedBox(); // Empty space if no image data
  }
}
