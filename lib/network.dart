import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:rxdart/rxdart.dart';

class NewsAppError extends Error {
  final String message;

  NewsAppError(this.message);
}

class NewsItem {
  final String id;
  final String title;
  final String author;
  final String date;
  final bool isFav;

  NewsItem({this.id, this.title, this.author, this.date, this.isFav});

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
        id : json['id'],
        title: json['title'],
        author : json['by'],
        date : json['time'],
        isFav: false
    );
  }
}

class NewsId {
  final List<int> idList;

  NewsId({this.idList});

  factory NewsId.fromJson(Map<String, dynamic> json) {
    return NewsId(
        idList: json['']
    );
  }

}

class NewsAppBlock {
  HashMap<int, NewsItem> _cachedNewsList;
  static const _baseUrl = 'https://hacker-news.firebaseio.com/v0/';

  var _newsList = <NewsItem>[];

  final _newsListSubject = BehaviorSubject<UnmodifiableListView<NewsItem>>();

  NewsAppBlock() {
    _cachedNewsList = HashMap<int, NewsItem>();
    _initializeArticles();
  }

  Future<void> _initializeArticles() async {
    _getNewsandUpdate(await _getIds());
  }

  _getNewsandUpdate(List<int> ids) async {
    await _updateNews(ids);

    _newsListSubject.add(UnmodifiableListView(_newsList));
  }

  Future<Null> _updateNews(List<int> ids) async {
    final futuresNews = ids.map((id) => _fetchNewsItem(id));
    final newsList = await Future.wait(futuresNews);
    _newsList = newsList;
  }

  Future<List<int>> _getIds() async {
    final url = '${_baseUrl}item/topstories.json?print=pretty';
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw NewsAppError("Stories couldn't be fetched.");
    }
    return NewsId.fromJson(json.decode(response.body)).idList;
  }

  Future<NewsItem> _fetchNewsItem(int id) async {
    if (!_cachedNewsList.containsKey(id)){
      final url = '${_baseUrl}item/$id.json?print=pretty';
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw NewsAppError("News #$id cannot be fetched");
      } else {
        _cachedNewsList[id] = NewsItem.fromJson(json.decode(response.body));
      }
    }
    return _cachedNewsList[id];
  }
}
