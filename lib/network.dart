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
  final int id;
  final String title;
  final String author;
  final int date;
  bool isFav;

  NewsItem({this.id, this.title, this.author, this.date, this.isFav});


  NewsItem.name(this.id, this.title, this.author, this.date, this.isFav);

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

  factory NewsId.fromJson(dynamic json) {
    return NewsId(
        idList: List<int>.from(json)
    );
  }

}

class Network {
  HashMap<int, NewsItem> _cachedNewsList;
  static const _baseUrl = 'https://hacker-news.firebaseio.com/v0/';

  var _newsList = <NewsItem>[];
  final _isLoadingSubject = BehaviorSubject<bool>(seedValue: false);
  final _newsListSubject = BehaviorSubject<UnmodifiableListView<NewsItem>>();

  Network() {
    _cachedNewsList = HashMap<int, NewsItem>();
    _initializNewsList();
  }

  Stream<bool> get isLoading => _isLoadingSubject.stream;
  Stream<UnmodifiableListView<NewsItem>> get newsItem => _newsListSubject.stream;

  Future<void> _initializNewsList() async {
    _getNewsandUpdate(await _getIds());
  }

  _getNewsandUpdate(List<int> ids) async {
    _isLoadingSubject.add(true);
    await _updateNews(ids);

    _newsListSubject.add(UnmodifiableListView(_newsList));
  _isLoadingSubject.add(false);
  }

  Future<Null> _updateNews(List<int> ids) async {
    final futuresNews = ids.map((id) => _fetchNewsItem(id));
    final newsList = await Future.wait(futuresNews);
    _newsList = newsList;
  }

  Future<List<int>> _getIds() async {
    final url = '${_baseUrl}topstories.json?print=pretty';
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw NewsAppError("Stories couldn't be fetched.");
    }
    return NewsId.fromJson(json.decode(response.body)).idList.take(10).toList();
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
