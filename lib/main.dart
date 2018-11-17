import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Hacker News',
    );
  }
}

class NewsItem {
  final String id;
  final String title;
  final String author;
  final String date;
  final bool isFav;

  NewsItem({this.id, this.title, this.author, this.date, this.isFav});
}

