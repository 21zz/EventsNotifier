import 'package:flutter/material.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      _getItems(context),
    ]);
  }

  SliverList _getItems(BuildContext context) {
    return SliverList(delegate: SliverChildListDelegate([]));
  }
}
