import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'network.dart';

import 'dart:async';
import 'dart:convert'as jsonC;
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Hacker News',
    );
  }
}

class NewsList extends StatefulWidget{

  @override
  State createState() => new NewsListState();
}

class NewsListState extends State<NewsList> {

  @override
  Widget build(BuildContext context) {

  }

  @override
  void initState() {

  }
}

Future<List<int>> _fetchNewsIdList() async {
  final url = 'https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty';
  final response = await http.get(url);
  if (response.statusCode != 200) {
    throw NewsAppError("Cannot get story id list");
  }
  return parseIdList(response.body).take(10).toList();
}

List<int> parseIdList(String jsonStr) {
  final parsed = jsonC.jsonDecode(jsonStr);
  final listOfIds = List<int>.from(parsed);
  return listOfIds;
}

Future<NewsItem> _fetchNewsItem(int id) async {
  final url = 'https://hacker-news.firebaseio.com/v0/item/$id.json?print=pretty';
  final response = await http.get(url);
  if (response.statusCode != 200) {
    throw NewsAppError("News #$id cannot be fetched");
  }
  return NewsItem.fromJson(json.decode(response.body));
}


