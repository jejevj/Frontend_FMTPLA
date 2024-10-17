class Author {
  final String author;
  final String authorUrl;
  final String authorNsid;
  final String authorBuddyIcon;

  Author({
    required this.author,
    required this.authorUrl,
    required this.authorNsid,
    required this.authorBuddyIcon,
  });

  // Factory constructor to create an Author object from JSON
  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      author: json['author'] ?? 'Unknown Author',
      authorUrl: json['author_url'] ?? '',
      authorNsid: json['author_nsid'] ?? '',
      authorBuddyIcon: json['author_buddyicon'] ??
          'https://via.placeholder.com/150', // Placeholder for missing icons
    );
  }
}
