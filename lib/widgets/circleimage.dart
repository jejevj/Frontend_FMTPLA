import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class CustomCircleAvatar extends StatefulWidget {
  final String imageUrl;
  const CustomCircleAvatar({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  _CustomCircleAvatarState createState() => _CustomCircleAvatarState();
}

class _CustomCircleAvatarState extends State<CustomCircleAvatar> {
  Uint8List? imageData; // Store the image data
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImageWithCustomUserAgent(); // Fetch the image when the widget is created
  }

  // Fetch the image with custom User-Agent header
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
          imageData = response.bodyBytes; // Store image data as bytes
          isLoading = false;
        });
      } else {
        print('Failed to load image: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching image: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor:
          Colors.grey[300], // Fallback background color while loading
      backgroundImage: imageData != null
          ? MemoryImage(imageData!) // Use the loaded image
          : null, // Show nothing if the image is not loaded
      child: isLoading
          ? const CircularProgressIndicator() // Show a loader while fetching
          : null, // Show nothing if image is loaded
    );
  }
}
