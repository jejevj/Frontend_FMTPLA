import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fmtpla_code/models/authors.dart';
import 'package:fmtpla_code/models/photo.dart';
import 'package:fmtpla_code/pages/detail.dart';
import 'package:fmtpla_code/utils/author_utils.dart';
import 'package:fmtpla_code/utils/tag_utils.dart'; // For tag-based search
import 'package:fmtpla_code/utils/id_utils.dart';
import 'package:fmtpla_code/widgets/circleimage.dart';
import 'package:fmtpla_code/widgets/imageload.dart';
import 'package:http/http.dart' as http; // Import IdUtils

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Author and photo lists
  List<Author> authors = [];
  List<Author> filteredAuthors = [];
  List<Photo> photos = []; // List of photos for tag and id search

  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  String selectedSearchType = 'Author'; // Default selected search type

  final List<String> searchOptions = [
    'Author',
    'Tag',
  ]; // Options for dropdown

  int currentPhotoIndex =
      0; // Track the current photo being processed, just like in HomePage

  @override
  void initState() {
    super.initState();
    fetchAuthorsData();
    searchController.addListener(_handleSearch);
  }

  // Function to fetch authors from API
  Future<void> fetchAuthorsData() async {
    List<Author> fetchedAuthors = await AuthorUtils.fetchAuthors();
    setState(() {
      authors = fetchedAuthors;
      filteredAuthors = fetchedAuthors;
      isLoading = false;
    });
  }

  // Function to fetch photos by tag (triggered when Enter key is pressed)
  Future<void> fetchPhotosByTag(String tag) async {
    if (tag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a tag to search.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      currentPhotoIndex =
          0; // Reset currentPhotoIndex when starting a new search
    });

    List<Photo> fetchedPhotos = await TagUtils.fetchPhotosByTag(tag);
    setState(() {
      photos = fetchedPhotos;
      isLoading = false;
    });
  }

  // Function to fetch photos by ID (triggered when Enter key is pressed)
  Future<void> fetchPhotosById(String id) async {
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an ID to search.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      currentPhotoIndex =
          0; // Reset currentPhotoIndex when starting a new search
    });

    List<Photo> fetchedPhotos = await IdUtils.fetchPhotosById(id);
    setState(() {
      photos = fetchedPhotos;
      isLoading = false;
    });
  }

  // Handle input in the search bar based on selected search type
  void _handleSearch() {
    String query = searchController.text.toLowerCase();
    if (selectedSearchType == 'Author') {
      setState(() {
        filteredAuthors = authors.where((author) {
          return author.author.toLowerCase().contains(query) ||
              author.authorNsid.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose(); // Dispose controller when no longer needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field with Dropdown inside
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: selectedSearchType == 'Author'
                      ? 'Search by author or NSID'
                      : selectedSearchType == 'Tag'
                          ? 'Search by tag'
                          : '',
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                  border: InputBorder.none,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                    child: DropdownButton<String>(
                      value: selectedSearchType,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSearchType = newValue!;
                          searchController.clear(); // Clear the search field
                          filteredAuthors = authors; // Reset filtered authors
                          photos = []; // Clear photo results
                          currentPhotoIndex = 0; // Reset photo index
                        });
                      },
                      items: searchOptions
                          .map<DropdownMenuItem<String>>((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      underline: Container(), // Remove the dropdown underline
                    ),
                  ),
                  suffixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) {
                  if (selectedSearchType == 'Author') {
                    _handleSearch(); // Search as you type for Author
                  }
                },
                onSubmitted: (value) {
                  if (selectedSearchType == 'Tag') {
                    fetchPhotosByTag(value); // Trigger tag search on Enter
                  } else if (selectedSearchType == 'ID') {
                    fetchPhotosById(value); // Trigger ID search on Enter
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            // Loading Indicator
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
            // Show author list if "Author" is selected
            if (selectedSearchType == 'Author')
              Expanded(
                child: ListView.builder(
                  itemCount: filteredAuthors.length,
                  itemBuilder: (context, index) {
                    final author = filteredAuthors[index];
                    return ListTile(
                      leading:
                          CustomCircleAvatar(imageUrl: author.authorBuddyIcon),
                      title: Text(author.author),
                      subtitle: Text(author.authorNsid),
                      onTap: () async {
                        await sendHistoryRequest(author.authorUrl,
                            "You Visiting ${author.authorNsid}'s Posts");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                                id: author.authorNsid), // Passing the NSID
                          ),
                        );
                        // Print the author's NSID when tapped
                        print('Opening author NSID: ${author.authorNsid}');
                      },
                    );
                  },
                ),
              )
            // Show photo cards if "Tag" or "ID" is selected
            else if ((selectedSearchType == 'Tag' ||
                    selectedSearchType == 'ID') &&
                photos.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return InkWell(
                      onTap: () async {
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
                        // Print the author's NSID when a card is tapped
                        print('Opening author NSID: ${photo.authorNsid}');
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
                            // Profile picture and name section
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  CustomCircleAvatar(
                                      imageUrl: photo.authorIcon),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        photo.author,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Published: ${photo.published.substring(0, 10)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Image section
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16.0),
                                topRight: Radius.circular(16.0),
                              ),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    photo.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
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
    );
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
}
