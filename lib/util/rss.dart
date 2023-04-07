import 'dart:io';
import 'package:http/http.dart' as http;

enum Experience {
  inPerson('inperson'),
  virtual('virtual'),
  none('');

  const Experience(this.type);

  final String type;

  String get() {
    return "experience=$type";
  }
}

enum EventType {
  workshopsAndConferences('42048191212397'),
  receptions('42048192983133'),
  meetingsAndLectures('42048189116089'),
  concertsAndPerformances('41853180888803'),
  athletics('42048192045827');

  const EventType(this.type);

  final String type;

  String get() {
    return "event_types[]=$type";
  }
}

enum Topic {
  academic('42048194702848'),
  artsAndCulture('42048195451856'),
  healthAndWellness('42048196170441'),
  research('42048196943827'),
  scienceAndTechnology('42048198253275');

  const Topic(this.type);

  final String type;

  String get() {
    return "event_types[]=$type";
  }
}

enum Audience {
  students('42048199597409'),
  facultyAndStaff('42048200312540'),
  alumni('42048201054598'),
  generalPublic('42048201870895'),
  prospectiveStudents('42048202639325');

  const Audience(this.type);

  final String type;

  String get() {
    return "event_types[]=$type";
  }
}

class RSS {
  final String url = 'https://events.marshall.edu/calendar.xml';
  List filterList = [];

  RSS();

  // filter is one of Experience, EventType, Topic, or Audience
  Future<String> getRSSFeed() async {
    var response = await http.get(Uri.parse('$url$getFilter'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw HttpException('response code is ${response.statusCode}');
    }
  }

  void addFilter(filter) {
    if (filterList.contains('${filter.get()}')) {
      return;
    }
    filterList.add('${filter.get()}');
  }

  void removeFilter(filter) {
    if (filterList.contains('${filter.get()}')) {
      return;
    }
    filterList.removeAt(filterList.indexOf('${filter.get()}'));
  }

  String get getFilter {
    if (filterList.isEmpty) {
      // if the filter is empty, you have to add an empty
      // ?experience=
      // at the end for some reason...
      return '?${Experience.none.get()}';
    }
    String filterString = '';
    for (var i = 0; i < filterList.length; i++) {
      i == 0
          ? filterString += '?${filterList[i]}'
          : filterString += '&${filterList[i]}';
    }
    return filterString;
  }
}
