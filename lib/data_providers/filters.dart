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

class Filter {
  String urlFilter = '';

  Filter();

  String get() {
    return urlFilter;
  }

  void addFilter(Enum filter) {
    if (urlFilter.compareTo('') == 0) {
      urlFilter += '?$filter';
    }
    else {
      urlFilter += '&$filter';
    }
  }
}