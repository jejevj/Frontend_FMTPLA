class Photo {
  final String title;
  final String photoLink;
  final String imageUrl;
  final String published;
  final String updated;
  final String dateTaken;
  final String author;
  final String authorUrl;
  final String authorNsid;
  final String authorIcon;
  final List<String> tags;

  Photo({
    required this.title,
    required this.photoLink,
    required this.imageUrl,
    required this.published,
    required this.updated,
    required this.dateTaken,
    required this.author,
    required this.authorUrl,
    required this.authorNsid,
    required this.authorIcon,
    required this.tags,
  });

  // A factory constructor to create a Photo object from JSON
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      title: json['title'] ?? 'No Title',
      photoLink: json['photo_link'] ?? '',
      imageUrl: json['image_url'] ?? '',
      published: json['published'] ?? 'Unknown',
      updated: json['updated'] ?? '',
      dateTaken: json['date_taken'] ?? '',
      author: json['author'] ?? 'Unknown Author',
      authorUrl: json['author_url'] ?? '',
      authorNsid: json['author_nsid'] ?? '',
      authorIcon: json['author_buddyicon'] ?? 'https://via.placeholder.com/150',
      tags: List<String>.from(json['tags'] ?? []), // Convert tags list
    );
  }

  // Method to check if the image URL is a valid image format
  bool isValidImageUrl() {
    return imageUrl.endsWith('.jpg') ||
        imageUrl.endsWith('.jpeg') ||
        imageUrl.endsWith('.png');
  }
}
