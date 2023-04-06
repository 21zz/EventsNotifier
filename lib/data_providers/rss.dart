import 'dart:io';
import 'filters.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart' as webfeed;

class RSS {
  final String url = 'https://events.marshall.edu/calendar.xml';

  RSS();

  Future<webfeed.RssFeed> getRSSFeed(Filter filter) async {
    var response = await http.get(Uri.parse('$url${filter.get()}'));
    if (response.statusCode == 200) {
      return webfeed.RssFeed.parse(response.body);
    }
    else {
      throw HttpException('response code is ${response.statusCode}');
    }
  }
}