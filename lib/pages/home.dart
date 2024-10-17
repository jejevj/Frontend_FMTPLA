import 'package:flutter/material.dart';
import 'package:fmtpla_code/models/photo.dart';
import 'package:fmtpla_code/pages/detail.dart';
import 'package:fmtpla_code/utils/api_utils.dart';
import 'package:fmtpla_code/widgets/circleimage.dart';
import 'package:fmtpla_code/widgets/imageload.dart';
import 'dart:convert'; // For encoding the body to JSON
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Photo> photos = [];
  bool isLoading = true;
  bool isLoadingMore = false; // Track if more data is loading
  int currentPage = 1; // Track the current page
  int currentPhotoIndex = 0; // Track the current photo being processed
  final ScrollController _scrollController =
      ScrollController(); // Scroll controller for ListView
  bool showScrollToTopButton =
      false; // Track visibility of FAB for scrolling to top

  @override
  void initState() {
    super.initState();
    fetchPhotoData(currentPage); // Fetch initial photos

    // Add a scroll listener to detect when the user has reached the end or scrolled far
    _scrollController.addListener(() {
      // Show the FAB when scrolled down 400 pixels or more
      if (_scrollController.position.pixels > 400) {
        setState(() {
          showScrollToTopButton = true;
        });
      } else {
        setState(() {
          showScrollToTopButton = false;
        });
      }

      // Detect when user has reached the bottom
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoadingMore) {
        fetchMorePhotos();
      }
    });
  }

  // Fetch photos for the initial page or subsequent pages
  Future<void> fetchPhotoData(int page) async {
    try {
      List<Photo> fetchedPhotos = await ApiUtils.fetchPhotos(page);
      // print(fetchedPhotos[0]);
      setState(() {
        photos.addAll(fetchedPhotos); // Append new photos
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching photos: $e');
    }
  }

  // Fetch more photos when user scrolls to the bottom
  Future<void> fetchMorePhotos() async {
    setState(() {
      isLoadingMore = true; // Set loading more to true
    });

    currentPage++; // Increment the page number
    List<Photo> newPhotos = await ApiUtils.fetchPhotos(currentPage);

    if (newPhotos.isNotEmpty) {
      setState(() {
        photos.addAll(newPhotos); // Append the new photos to the list
      });
    }

    setState(() {
      isLoadingMore = false; // Done loading more
    });
  }

  // Scroll to top function
  void scrollToTop() {
    _scrollController.animateTo(
      0, // Scroll to the top
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the scroll controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController, // Attach scroll controller
                      itemCount: currentPhotoIndex +
                          1, // Render only up to the current photo index
                      itemBuilder: (context, index) {
                        if (index >= photos.length) return const SizedBox();

                        final photo = photos[index];
                        return InkWell(
                          onTap: () async {
                            // After successfully opening the URL, send the POST request to add history
                            await sendHistoryRequest(photo.photoLink,
                                "You Visiting ${photo.authorNsid}'s Images");
                            // Navigating to the detail page with a Photo object
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                    id: photo.authorNsid,
                                    photo: photo), // Pass Photo
                              ),
                            );
                            print('Tapped on: ${photo.authorNsid}');
                          },
                          child: Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      CustomCircleAvatar(
                                          imageUrl: photo.authorIcon),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              photo.author,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Published: ${photo.published.substring(0, 10)}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16.0),
                                    topRight: Radius.circular(16.0),
                                  ),
                                  //TODO: THIS SHOULD BE USE CUSTOM IMAGE NETWORK
                                  child: CustomNetworkImage(
                                    imageUrl: photo.imageUrl,
                                    index: index,
                                    currentPhotoIndex: currentPhotoIndex,
                                    onImageLoaded: (loadedIndex) {
                                      setState(() {
                                        currentPhotoIndex = loadedIndex +
                                            1; // Update currentPhotoIndex to load the next card
                                      });
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    photo.title,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      // Add the FloatingActionButton to scroll to the top
      floatingActionButton: showScrollToTopButton
          ? FloatingActionButton(
              onPressed: scrollToTop,
              child: const Icon(Icons.arrow_upward),
              backgroundColor:
                  const Color(0xFF9CBAA8), // Customize color as needed
            )
          : null,
    );
  }
}

// Function to send POST request on tap
Future<void> sendHistoryRequest(String accessUrl, String searchQuery) async {
  const String apiUrl =
      'https://apps.syscloud.my.id/gambar_api/add-history'; // API URL

  // Create the body of the POST request
  Map<String, String> requestBody = {
    'access_url': accessUrl,
    'search_query': searchQuery,
  };

  try {
    // Send POST request
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type':
            'application/json', // Ensure the server knows you're sending JSON
      },
      body: json.encode(requestBody), // Encode the body as JSON
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print('History successfully added');
    } else {
      print('Failed to add history: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred while sending history: $e');
  }
}
