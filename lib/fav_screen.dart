
import 'package:flutter/material.dart';
import 'network.dart';

class FavScreen extends StatelessWidget {

  final List<NewsItem> favList;


  FavScreen({
    Key key,
    this.favList}) :super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: ListView.separated(
          itemBuilder: (context, i) {
            return ListTile(
              title: Text(favList[i].title),
            );
          },
          separatorBuilder: (context, i) => Divider(),
          itemCount: favList.length),
    );
  }
}