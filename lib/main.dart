import 'package:flutter/material.dart';
import 'network.dart';
import 'dart:collection';
import 'package:intl/intl.dart';

void main() {
  final network = Network();
  runApp(new MyApp(network: network,));
}

class MyApp extends StatelessWidget {
  final Network network;

  MyApp({
    Key key,
    this.network
  }) : super(key: key);

  static const primaryColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Hacker News',
      home: NewsList(network: network,),
    );
  }
}

class NewsList extends StatefulWidget {
  final Network network;

  NewsList({
    Key key,
    this.network
  }) : super(key: key);

  @override
  State createState() => new NewsListState();
}

class NewsListState extends State<NewsList> {

  List<NewsItem> newsList = new List();

  List<NewsItem> getFavList(List<NewsItem> list) {
    List<NewsItem> favList = list;
    favList.retainWhere((item) => item.isFav);
    return favList;
  }

  String _dateFormatter(int date) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(date * 1000);
    var formatter = new DateFormat('MMM dd, yyyy');
    String formatted = formatter.format(dateTime);
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hacker News'),
        actions: <Widget>[
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(
                    builder: (context) =>
                        FavScreen(favList: getFavList(newsList))));
              },
              child: Padding(
                  padding: EdgeInsetsDirectional.only(end : 20.0),
                  child: Icon(Icons.favorite)
              )
          )
        ],
      ),
      body: StreamBuilder<bool>(
        stream: widget.network.isLoading,
        initialData: false,
        builder: (context, snapshot) =>
        snapshot.data ? Container(
            child: Center(child: CircularProgressIndicator(),)) :
        StreamBuilder<UnmodifiableListView<NewsItem>>(
            stream: widget.network.newsItem,
            initialData: UnmodifiableListView<NewsItem>([]),
            builder: (context, snapshot) {
              newsList = (snapshot.data.toList());
              return ListView.separated(
                  itemCount: newsList.length,
                  separatorBuilder: (context, i) => Divider(),
                  itemBuilder: (context, i) {
                    return _buildItem(newsList[i], i);
                  });
//              return ListView(
//                children: snapshot.data.map(_buildItem).toList(),
//              );
            }
        ),
      ),
    );
  }

  Widget _buildItem(NewsItem item, int position) {
    return Padding(
      key: Key(item.id.toString()),
      padding: const EdgeInsets.all(10.0),
      child: Container(
          child: ListTile(
            onTap: () {
              setState(() {
                newsList[position].isFav = !newsList[position].isFav;
              });
            },
            title:
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('#${item.id.toString()}'),
                Text(item.title),
                Text('Author : ${item.author}'),
                Text(_dateFormatter(item.date))
              ],
            ),
            trailing: Container(
                child: new Icon(
                  item.isFav ? Icons.favorite : Icons.favorite_border,
                  color: item.isFav ? Colors.red : null,
                )),
          )
      ),
    );
  }
}


