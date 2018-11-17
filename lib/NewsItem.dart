import 'dart:convert' as json;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializers.dart';

abstract class NewsItem implements Built<NewsItem, NewsItemBuilder> {
  static Serializer<NewsItem> get serializer => _$newsItemSerializer;

  String get id;
  String get title;
  String get author;
  String get date;
  bool get isFav;
}
