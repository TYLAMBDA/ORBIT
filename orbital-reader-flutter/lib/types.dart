import 'package:flutter/material.dart';

enum DockPosition { center, left, right, top, bottom }
enum Language { en, zh }

class MenuItem {
  final String id;
  final String label;
  final IconData icon;
  final DockPosition targetDock;
  final Color color;
  final bool special;

  MenuItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.targetDock,
    required this.color,
    this.special = false,
  });
}

class Book {
  final String id;
  final String title;
  final String author;
  final String coverColor; // Tailwind class string in React, we'll map this manually or use a Color
  final Color parsedColor;
  final int progress;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverColor,
    required this.parsedColor,
    required this.progress,
  });
}

class User {
  final String username;
  final String email;
  final String avatar; // Tailwind color class string in React
  final Color parsedAvatarColor;
  final UserStats stats;

  User({
    required this.username,
    required this.email,
    required this.avatar,
    required this.parsedAvatarColor,
    required this.stats,
  });
}

class UserStats {
  final double totalReadingHours;
  final List<String> booksRead;
  final List<String> booksPublished;

  UserStats({
    required this.totalReadingHours,
    required this.booksRead,
    required this.booksPublished,
  });
}
class ExploreBook {
  final String title;
  final String author;
  final String coverColor;
  final String content;
  final String description;
  final Color parsedColor;

  ExploreBook({
    required this.title,
    required this.author,
    required this.coverColor,
    required this.content,
    required this.description,
    required this.parsedColor,
  });
}
