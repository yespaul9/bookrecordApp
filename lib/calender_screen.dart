import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatelessWidget {
  final List<Map<String, dynamic>> books;

  const CalendarScreen({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("만화 기록 달력")),
      body: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: DateTime.now(),
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),

        // 달력 날짜에 맞춰 커스텀 위젯 배치
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            // 해당 날짜에 기록된 책 찾기 (구매일 기준)
            final booksOnDay = books.where((book) =>
                isSameDay(book['date'] as DateTime, date)).toList();

            if (booksOnDay.isEmpty) return null;

            // 해당 날짜에 책이 있다면 첫 번째 책의 이미지를 작게 표시
            final firstBook = booksOnDay.first;
            return Positioned(
              bottom: 1,
              child: Container(
                width: 24,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: firstBook['imagePath'] != null
                    ? (kIsWeb
                    ? Image.network(firstBook['imagePath'], fit: BoxFit.cover)
                    : Image.file(File(firstBook['imagePath']), fit: BoxFit.cover))
                    : const Icon(Icons.book, size: 10, color: Colors.orange),
              ),
            );
          },
        ),
      ),
    );
  }
}