import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Student name should not be empty', () {
    var studentName = "Mushtaq"; // Imagine this comes from your UI
    expect(studentName.isNotEmpty, true);
  });
}