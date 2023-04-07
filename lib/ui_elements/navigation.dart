import 'package:flutter/material.dart';
import 'package:marshall_event_notifier/ui_elements/settings.dart';
import 'package:marshall_event_notifier/ui_elements/events.dart';
import 'package:marshall_event_notifier/ui_elements/feed.dart';
import 'package:marshall_event_notifier/util/rss.dart';

enum DialogsAction { ok, cancel }

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentPageIndex = 0;

  Experience experience = Experience.none;

  // EventType
  bool? workshopsAndConferencesChecked = false;
  bool? receptionsChecked = false;
  bool? meetingsAndLecturesChecked = false;
  bool? concertsAndPerformancesChecked = false;
  bool? athleticsChecked = false;

  // Topic
  bool? academicChecked = false;
  bool? artsAndCultureChecked = false;
  bool? healthAndWellnessChecked = false;
  bool? researchChecked = false;
  bool? scienceAndTechnologyChecked = false;

  // Audience
  bool? studentsChecked = false;
  bool? facultyAndStaffChecked = false;
  bool? alumniChecked = false;
  bool? generalPublicChecked = false;
  bool? prospectiveStudentsChecked = false;


  buildFeed() async {
    var ff = FeedFilter();
    // Experience
    ff.setExperience(experience);
    // EventType
    workshopsAndConferencesChecked!
        ? ff.addEventType(EventType.workshopsAndConferences)
        : ff.removeEventType(EventType.workshopsAndConferences);
    receptionsChecked!
        ? ff.addEventType(EventType.receptions)
        : ff.removeEventType(EventType.receptions);
    meetingsAndLecturesChecked!
        ? ff.addEventType(EventType.meetingsAndLectures)
        : ff.removeEventType(EventType.meetingsAndLectures);
    concertsAndPerformancesChecked!
        ? ff.addEventType(EventType.concertsAndPerformances)
        : ff.removeEventType(EventType.concertsAndPerformances);
    athleticsChecked!
        ? ff.addEventType(EventType.athletics)
        : ff.removeEventType(EventType.athletics);
    // Topic
    academicChecked!
        ? ff.addTopic(Topic.academic)
        : ff.removeTopic(Topic.academic);
    artsAndCultureChecked!
        ? ff.addTopic(Topic.artsAndCulture)
        : ff.removeTopic(Topic.artsAndCulture);
    healthAndWellnessChecked!
        ? ff.addTopic(Topic.healthAndWellness)
        : ff.removeTopic(Topic.healthAndWellness);
    researchChecked!
        ? ff.addTopic(Topic.research)
        : ff.removeTopic(Topic.research);
    scienceAndTechnologyChecked!
        ? ff.addTopic(Topic.scienceAndTechnology)
        : ff.removeTopic(Topic.scienceAndTechnology);
    // Audience
    studentsChecked!
        ? ff.addAudience(Audience.students)
        : ff.removeAudience(Audience.students);
    facultyAndStaffChecked!
        ? ff.addAudience(Audience.facultyAndStaff)
        : ff.removeAudience(Audience.facultyAndStaff);
    alumniChecked!
        ? ff.addAudience(Audience.alumni)
        : ff.removeAudience(Audience.alumni);
    generalPublicChecked!
        ? ff.addAudience(Audience.generalPublic)
        : ff.removeAudience(Audience.generalPublic);
    prospectiveStudentsChecked!
        ? ff.addAudience(Audience.students)
        : ff.removeAudience(Audience.students);

    var rss = ff.buildRSSFromFilter();
    print(rss.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: [
          const Icon(Icons.event),
          IconButton(
              icon: const Icon(Icons.filter_alt_outlined),
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext ctx) {
                      return AlertDialog(
                          contentPadding:
                              const EdgeInsets.only(left: 25, right: 25),
                          scrollable: true,
                          title: const Center(child: Text("Filter")),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pop(DialogsAction.cancel),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                buildFeed();
                                Navigator.of(context).pop(DialogsAction.ok);
                                },
                              child: const Text(
                                "OK",
                                style: TextStyle(color: Colors.blue),
                              ),
                            )
                          ],
                          content: SingleChildScrollView(
                              child: Column(children: [
                            Row(children: const <Widget>[Text("Experience")]),
                            Row(children: <Widget>[
                              StatefulBuilder(
                                builder: (context, setState) =>
                                    DropdownButton(
                                      items: const [
                                        DropdownMenuItem(child: Text("In-person"), value: Experience.inPerson),
                                        DropdownMenuItem(child: Text("Virtual"), value: Experience.virtual),
                                        DropdownMenuItem(child: Text("None"), value: Experience.none)
                                      ],
                                      value: experience,
                                      onChanged: (value) {
                                        setState(() {
                                          experience = value!;
                                        });
                                      },

                                    )
                              )
                            ]),
                            Row(children: const <Widget>[Text("")]),
                            Row(children: const <Widget>[Text("Event Type")]),
                            Row(children: <Widget>[
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                              title: const Text(
                                                  "Workshops & Conferences"),
                                              value: workshopsAndConferencesChecked,
                                              onChanged: (value) {
                                                setState(() {
                                                  workshopsAndConferencesChecked = value!;
                                                });
                                              })))
                            ]),
                            Row(children: [
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                              title: const Text("Receptions"),
                                              value: receptionsChecked,
                                              onChanged: (value) {
                                                setState(() {
                                                  receptionsChecked = value!;
                                                });
                                              })))
                            ]),
                            Row(children: [
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                              title: const Text(
                                                  "Meetings & Lectures"),
                                              value: meetingsAndLecturesChecked,
                                              onChanged: (value) {
                                                setState(() {
                                                  meetingsAndLecturesChecked =
                                                      value!;
                                                });
                                              })))
                            ]),
                            Row(children: [
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                              title: const Text(
                                                  "Concerts & Performances"),
                                              value: concertsAndPerformancesChecked,
                                              onChanged: (value) {
                                                setState(() {
                                                  concertsAndPerformancesChecked = value!;
                                                });
                                              })))
                            ]),
                            Row(children: [
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                              title: const Text("Athletics"),
                                              value: athleticsChecked,
                                              onChanged: (value) {
                                                setState(() {
                                                  athleticsChecked = value!;
                                                });
                                              }))),
                            ])
                          ])));
                    });
              }),
          const Icon(Icons.settings)
        ][currentPageIndex],
        title: <Text>[
          const Text("Events"),
          const Text("Feed"),
          const Text("Settings")
        ][currentPageIndex],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.feed),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: <Widget>[
        const Events(),
        const Feed(),
        const SettingsWidget(),
      ][currentPageIndex],
    );
  }
}

class FeedFilter {
  var experience = Experience.none;
  var eventType = [];
  var topic = [];
  var audience = [];

  FeedFilter();

  void setExperience(Experience experience) {
    this.experience = experience;
  }

  void addEventType(EventType eventType) {
    this.eventType.add(eventType);
  }

  void addTopic(Topic topic) {
    this.topic.add(topic);
  }

  void addAudience(Audience audience) {
    this.audience.add(audience);
  }

  void unsetExperience(Experience experience) {
    this.experience = Experience.none;
  }

  void removeEventType(EventType eventType) {
    List<int> toRemove = const [];
    for (var i = 0; i < this.eventType.length; i++) {
      if (this.eventType[i] == eventType) {
        toRemove.add(i);
      }
      // reverse so we remove backwards instead of forwards
      // might cause some issues otherwise
      for (int i in toRemove.reversed) {
        this.eventType.removeAt(i);
      }
    }
  }

  void removeTopic(Topic topic) {
    List<int> toRemove = const [];
    for (var i = 0; i < this.topic.length; i++) {
      if (this.topic[i] == topic) {
        toRemove.add(i);
      }
      // reverse so we remove backwards instead of forwards
      // might cause some issues otherwise
      for (int i in toRemove.reversed) {
        this.topic.removeAt(i);
      }
    }
  }

  void removeAudience(Audience audience) {
    List<int> toRemove = const [];
    for (var i = 0; i < this.audience.length; i++) {
      if (this.audience[i] == audience) {
        toRemove.add(i);
      }
      // reverse so we remove backwards instead of forwards
      // might cause some issues otherwise
      for (int i in toRemove.reversed) {
        this.audience.removeAt(i);
      }
    }
  }

  RSS buildRSSFromFilter() {
    var rss = RSS();
    rss.addFilter(experience);
    for (EventType e in eventType) {
      rss.addFilter(e);
    }
    for (Topic t in topic) {
      rss.addFilter(t);
    }
    for (Audience a in audience) {
      rss.addFilter(a);
    }
    return rss;
  }
}
