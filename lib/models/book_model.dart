class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final bool isAvailable;
  final String? borrowedBy; // Student ID
  final String? dueDate;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    this.isAvailable = true,
    this.borrowedBy,
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'isbn': isbn,
    'isAvailable': isAvailable,
    'borrowedBy': borrowedBy,
    'dueDate': dueDate,
  };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'],
    title: json['title'],
    author: json['author'],
    isbn: json['isbn'],
    isAvailable: json['isAvailable'] ?? true,
    borrowedBy: json['borrowedBy'],
    dueDate: json['dueDate'],
  );
}