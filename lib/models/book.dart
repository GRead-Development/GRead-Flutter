class Book {
  final int id;
  final String title;
  final String? author;
  final String? description;
  final String? coverUrl;
  final int? totalPages;
  final String? isbn;
  final String? publishedDate;

  Book({
    required this.id,
    required this.title,
    this.author,
    this.description,
    this.coverUrl,
    this.totalPages,
    this.isbn,
    this.publishedDate,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      author: json['author'],
      description: json['content'],
      coverUrl: json['cover_url'],
      totalPages: json['page_count'],
      isbn: json['isbn'],
      publishedDate: json['published_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'content': description,
      'cover_url': coverUrl,
      'page_count': totalPages,
      'isbn': isbn,
      'published_date': publishedDate,
    };
  }
}

class LibraryItem {
  final int id;
  final Book? book;
  final int currentPage;
  final String? status; // "reading", "completed", "paused"
  final String? addedDate;
  final String? lastUpdated;

  LibraryItem({
    required this.id,
    this.book,
    required this.currentPage,
    this.status,
    this.addedDate,
    this.lastUpdated,
  });

  factory LibraryItem.fromJson(Map<String, dynamic> json) {
    return LibraryItem(
      id: json['id'] ?? 0,
      book: json['book'] != null ? Book.fromJson(json['book']) : null,
      currentPage: json['current_page'] ?? 0,
      status: json['status'],
      addedDate: json['added_date'],
      lastUpdated: json['last_updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book?.toJson(),
      'current_page': currentPage,
      'status': status,
      'added_date': addedDate,
      'last_updated': lastUpdated,
    };
  }
}
