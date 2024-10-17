import 'package:flutter/material.dart';
import 'package:fmtpla_code/models/photo.dart';
import 'package:fmtpla_code/utils/id_utils.dart';
import 'package:fmtpla_code/widgets/circleimage.dart';
import 'package:fmtpla_code/widgets/galleryload.dart';
import 'package:fmtpla_code/widgets/imageload.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  final String id; // ID passed from the previous page
  final Photo? photo; // Optional Photo argument

  const DetailPage({
    required this.id,
    this.photo, // Optional Photo passed in constructor
    super.key,
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<List<Photo>> _photoDetail; // Future to hold photo details
  late Future<List<Photo>> _userPhotos; // Future to hold user's gallery photos
  Photo? mainPhoto; // Store the main photo to be displayed at the top

  @override
  void initState() {
    super.initState();

    // If a photo is passed, use it; otherwise, fetch the photo by ID
    if (widget.photo != null) {
      mainPhoto = widget.photo;
    } else {
      _photoDetail =
          IdUtils.fetchPhotosById(widget.id); // Fetch main photo by ID
    }

    // Fetch user's gallery photos
    _userPhotos = IdUtils.fetchPhotosById(widget.id);
  }

  // Function to show a popup with the image
  void _showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // Close the dialog when tapped
            },
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Page"),
        backgroundColor: const Color(0xFF9CBAA8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Check if mainPhoto is available (either passed in or fetched)
              if (mainPhoto != null)
                _buildMainPhotoContent(mainPhoto!)
              else
                FutureBuilder<List<Photo>>(
                  future: _photoDetail, // Use Future to fetch the photo details
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child:
                              CircularProgressIndicator()); // Loading indicator
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No details found.'));
                    }

                    final photo = snapshot
                        .data![0]; // We assume there's at least one photo
                    mainPhoto =
                        photo; // Set the fetched photo as the main photo
                    return _buildMainPhotoContent(photo);
                  },
                ),
              const SizedBox(height: 20),
              // Show gallery section for user's other photos
              const Text(
                'User Gallery',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Photo>>(
                future: _userPhotos, // Fetch other photos by the same user
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No other photos available.');
                  }

                  final userPhotos = snapshot.data!;
                  int currentPhotoIndex =
                      0; // Track the current photo index to load progressively

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true, // To avoid scroll issues inside Column
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Show 3 photos per row
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1, // Make the grid items square
                    ),
                    itemCount: userPhotos.length,
                    itemBuilder: (context, index) {
                      final userPhoto = userPhotos[index];

                      return GestureDetector(
                        onTap: () {
                          // Show the full image in a popup when tapped
                          _showImagePopup(context, userPhoto.imageUrl);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CustomImageLoader(
                            imageUrl: userPhoto.imageUrl,
                            index: index,
                            currentIndex:
                                currentPhotoIndex, // Control progressive loading
                            onImageLoaded: (loadedIndex) {
                              setState(() {
                                currentPhotoIndex =
                                    loadedIndex + 1; // Load the next image
                              });
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build the main photo content
  Widget _buildMainPhotoContent(Photo photo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display image
        ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: CustomNetworkImage(imageUrl: photo.imageUrl)),
        const SizedBox(height: 16),
        // Display photo title
        Text(
          photo.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Display author and publish date
        Row(
          children: [
            CustomCircleAvatar(imageUrl: photo.authorIcon),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo.author,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Published: ${photo.published.substring(0, 10)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Display description or other details
        Text(
          'Taken on: ${photo.dateTaken.substring(0, 10)}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Tags: ${photo.tags.join(", ")}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        // Button with Flickr logo that opens the URL in the browser
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // Black background for the button
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            try {
              await _openInBrowser(photo.photoLink);
            } catch (e) {
              print('Error: $e');
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/9/9b/Flickr_logo.png', // Flickr logo URL
                height: 24, // Set the height of the logo
                width: 24, // Set the width of the logo
              ),
              const SizedBox(width: 10),
              const Text('View on Flickr',
                  style: TextStyle(color: Colors.white)), // Button label
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openInBrowser(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Open in the external browser
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
