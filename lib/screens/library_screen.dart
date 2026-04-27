import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../models/student_model.dart';
import '../services/database_service.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Library Inventory", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Book>>(
        stream: db.booksStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading library data"));
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return const Center(
              child: Text("No books in library. Tap + to add inventory."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: book.isAvailable ? Colors.green[100] : Colors.red[100],
                    child: Icon(
                      Icons.menu_book,
                      color: book.isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    book.isAvailable
                        ? "Author: ${book.author}\nISBN: ${book.isbn}"
                        : "Borrowed by: ${book.borrowedBy}\nDue: ${book.dueDate}",
                  ),
                  isThreeLine: true,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: book.isAvailable ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: book.isAvailable ? Colors.green : Colors.red),
                    ),
                    child: Text(
                      book.isAvailable ? "Available" : "Issued",
                      style: TextStyle(
                        color: book.isAvailable ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    if (book.isAvailable) {
                      _showIssueBookDialog(context, book, db);
                    } else {
                      _showReturnBookDialog(context, book, db);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () {
          _showAddBookDialog(context, db);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- 1. DIALOG: ADD NEW BOOK ---
  void _showAddBookDialog(BuildContext context, DatabaseService db) {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final isbnController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Book"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Book Title")),
            TextField(controller: authorController, decoration: const InputDecoration(labelText: "Author")),
            TextField(controller: isbnController, decoration: const InputDecoration(labelText: "ISBN Number")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final newBook = Book(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  author: authorController.text,
                  isbn: isbnController.text,
                );
                await db.saveBook(newBook);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --- 2. DIALOG: ISSUE BOOK TO STUDENT ---
  void _showIssueBookDialog(BuildContext context, Book book, DatabaseService db) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Issue: ${book.title}"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: StreamBuilder<List<Student>>(
            stream: db.studentsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final students = snapshot.data!;
              if (students.isEmpty) return const Center(child: Text("No students available."));

              return ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(student.name),
                    subtitle: Text("Class: ${student.studentClass}"),
                    onTap: () async {
                      // Due date set for 14 days from today
                      String dueDate = DateTime.now().add(const Duration(days: 14)).toString().split(' ')[0];
                      await db.issueBook(book.id, student.name, dueDate);
                      if (context.mounted) Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Book issued to ${student.name}")),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // --- 3. DIALOG: RETURN BOOK ---
  void _showReturnBookDialog(BuildContext context, Book book, DatabaseService db) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Return Book"),
        content: Text("Confirm return for '${book.title}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              await db.returnBook(book.id);
              if (context.mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Book returned to inventory")),
              );
            },
            child: const Text("Confirm Return", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}