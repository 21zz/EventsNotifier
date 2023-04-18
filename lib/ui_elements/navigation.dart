import 'package:flutter/material.dart';
import 'package:marshall_event_notifier/ui_elements/settings.dart';
import 'package:marshall_event_notifier/util/rss.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:marshall_event_notifier/util/storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';


enum DialogsAction { ok, cancel }

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  var feedItems = [];
  var eventItems = [];
  Isar? _isar;
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

  @override
  void initState() {
    super.initState();
    _getIsar();
  }


  _getIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [FeedItemDataIsarSchema],
      directory: dir.path,
    );
    buildEvents();
  }

  buildEvents() async {
    var events = await _isar!.feedItemDataIsars.where().findAll();
    if(events.isEmpty) {
      return;
    }
    // clear current list
    while(eventItems.isNotEmpty) {
    setState(() {
        eventItems.removeLast();
      });
    }

    // build new list
    debugPrint('$events...${events.length}');
    for (FeedItemDataIsar event in events) {
      var feedItemData = FeedItemData();
      feedItemData.title = event.title;
      feedItemData.description = event.description;
      feedItemData.link = event.link;
      feedItemData.locationLat = event.locationLat;
      feedItemData.locationLong = event.locationLong;
      feedItemData.publicationDate = event.publicationDate;
      feedItemData.mediaContent = event.mediaContent;
      feedItemData.eventDate = event.eventDate;

      // update
      setState(() {
        debugPrint('adding ${feedItemData.title}');
        eventItems.add(feedItemData);
      });
    }
  }

  buildFeed(context) async {
    if (feedItems.isNotEmpty) {
      while (feedItems.isNotEmpty) {
        setState(() {
          feedItems.removeLast();
        });
      }
    }
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

    // build rss from the filter
    var rss = ff.buildRSSFromFilter();
    debugPrint('built RSS from filter');
    debugPrint('${rss.url}${rss.getFilter}');
    // get the feed as text
    var feed = await rss.getRSSFeed();
    debugPrint('got RSS Feed');
    // parse XML
    var document = XmlDocument.parse(feed);
    debugPrint('awaited feed and parsed XML');
    // get the element with children <item>
    var root = document.findElements('rss').first.findElements('channel').first;
    // list of each item aka list of events
    var events = root.findElements('item');
    // go through each event and build objects to put into feed
    if (events.isEmpty) {
      showEmpty(context);
      return;
    }
    for (var event in events) {
      var feedItemData = FeedItemData();
      var title = event.findElements('title');
      var description = event.findElements('description');
      var link = event.findElements('link');
      var locationLat = event.findElements('geo:lat');
      var locationLong = event.findElements('geo:long');
      var publicationDate = event.findElements('pubDate');
      var mediaContent = event.findElements('media:content');
      var eventDate = event.findElements('dc:date');
      title.isEmpty ? null : feedItemData.title = title.first.innerText;
      description.isEmpty
          ? null
          : feedItemData.description = description.first.innerText;
      link.isEmpty ? null : feedItemData.link = link.first.innerText;
      locationLat.isEmpty
          ? null
          : feedItemData.locationLat = locationLat.first.innerText;
      locationLong.isEmpty
          ? null
          : feedItemData.locationLong = locationLong.first.innerText;
      publicationDate.isEmpty
          ? null
          : feedItemData.publicationDate = publicationDate.first.innerText;
      mediaContent.isEmpty
          ? null
          : feedItemData.mediaContent = mediaContent.first.getAttribute("url");
      eventDate.isEmpty
          ? null
          : feedItemData.eventDate =
              DateTime.tryParse(eventDate.first.innerText);
      setState(() {
        feedItems.add(feedItemData);
      });
    }
  }

  showEmpty(context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              contentPadding: const EdgeInsets.all(15),
              scrollable: false,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const <Widget>[
                  Text("No events found for current filter.")
                ],
              ));
        });
  }

  Widget giveHtml(int index) {
    return Html(
        data: feedItems[index].description,
        onLinkTap: (url, context, attributes, element) {
          if (url != null) {
            var newUrl = url.replaceFirst('http://', 'https://');
            launchUrl(Uri.tryParse(newUrl)!,
                mode: LaunchMode.platformDefault,
                webOnlyWindowName: url,
                webViewConfiguration: const WebViewConfiguration(
                    enableJavaScript: true, enableDomStorage: false));
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: [
          const Icon(Icons.event),
          IconButton(
              icon: const Icon(Icons.refresh_outlined),
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext ctx) {
                      return AlertDialog(
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          contentPadding: const EdgeInsets.all(30),
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
                                buildFeed(context);
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
                            Row(children: const <Widget>[
                              Text(
                                "Experience",
                                style: TextStyle(color: Colors.blue),
                              )
                            ]),
                            Row(children: <Widget>[
                              StatefulBuilder(
                                  builder: (context, setState) =>
                                      DropdownButton(
                                        items: const [
                                          DropdownMenuItem(
                                              value: Experience.inPerson,
                                              child: Text("In-person")),
                                          DropdownMenuItem(
                                              value: Experience.virtual,
                                              child: Text("Virtual")),
                                          DropdownMenuItem(
                                              value: Experience.none,
                                              child: Text("Both"))
                                        ],
                                        value: experience,
                                        onChanged: (value) {
                                          setState(() {
                                            experience = value!;
                                          });
                                        },
                                        itemHeight: 48,
                                      ))
                            ]),
                            Row(children: const <Widget>[Text("")]),
                            Row(children: const <Widget>[
                              Text(
                                "Event Type",
                                style: TextStyle(color: Colors.blue),
                              )
                            ]),
                            Row(children: <Widget>[
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                              title: const Text(
                                                  "Workshops & Conferences"),
                                              value:
                                                  workshopsAndConferencesChecked,
                                              onChanged: (value) {
                                                setState(() {
                                                  workshopsAndConferencesChecked =
                                                      value!;
                                                });
                                              },
                                              contentPadding: EdgeInsets.zero)))
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
                                              },
                                              contentPadding: EdgeInsets.zero)))
                            ]), // receptions
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
                                            },
                                            contentPadding: EdgeInsets.zero,
                                          )))
                            ]), // meetings and lectures
                            Row(children: [
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                            title: const Text(
                                                "Concerts & Performances"),
                                            value:
                                                concertsAndPerformancesChecked,
                                            onChanged: (value) {
                                              setState(() {
                                                concertsAndPerformancesChecked =
                                                    value!;
                                              });
                                            },
                                            contentPadding: EdgeInsets.zero,
                                          )))
                            ]), // concert and performances
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
                                            },
                                            contentPadding: EdgeInsets.zero,
                                          ))),
                            ]), // athletics
                            Row(children: const <Widget>[Text("")]),
                            Row(children: const <Widget>[
                              Text(
                                "Topic",
                                style: TextStyle(color: Colors.blue),
                              )
                            ]),
                            Row(children: [
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                            title: const Text("Academic"),
                                            value: academicChecked,
                                            onChanged: (value) {
                                              setState(() {
                                                academicChecked = value!;
                                              });
                                            },
                                            contentPadding: EdgeInsets.zero,
                                          )))
                            ]), //academic
                            Row(children: [
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                            title: const Text("Arts & Culture"),
                                            value: artsAndCultureChecked,
                                            onChanged: (value) {
                                              setState(() {
                                                artsAndCultureChecked = value!;
                                              });
                                            },
                                            contentPadding: EdgeInsets.zero,
                                          )))
                            ]), // arts & culture
                            Row(children: [
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                            title:
                                                const Text("Health & Wellness"),
                                            value: healthAndWellnessChecked,
                                            onChanged: (value) {
                                              setState(() {
                                                healthAndWellnessChecked =
                                                    value!;
                                              });
                                            },
                                            contentPadding: EdgeInsets.zero,
                                          ))),
                            ]), // health & wellness
                            Row(children: [
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                            title: const Text("Research"),
                                            value: researchChecked,
                                            onChanged: (value) {
                                              setState(() {
                                                researchChecked = value!;
                                              });
                                            },
                                            contentPadding: EdgeInsets.zero,
                                          )))
                            ]), // research
                            Row(children: [
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                            title: const Text(
                                                "Science & Technology"),
                                            value: scienceAndTechnologyChecked,
                                            onChanged: (value) {
                                              setState(() {
                                                scienceAndTechnologyChecked =
                                                    value!;
                                              });
                                            },
                                            contentPadding: EdgeInsets.zero,
                                          )))
                            ]), // science & technology
                            Row(children: const <Widget>[Text("")]),
                            Row(children: const <Widget>[
                              Text(
                                "Audience",
                                style: TextStyle(color: Colors.blue),
                              )
                            ]),
                            Row(children: [
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                            title: const Text("Students"),
                                            value: studentsChecked,
                                            onChanged: (value) {
                                              setState(() {
                                                studentsChecked = value!;
                                              });
                                            },
                                            contentPadding: EdgeInsets.zero,
                                          )))
                            ]), // students
                            Row(children: [
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                            title:
                                                const Text("Faculty & Staff"),
                                            value: facultyAndStaffChecked,
                                            onChanged: (value) {
                                              setState(() {
                                                facultyAndStaffChecked = value!;
                                              });
                                            },
                                            contentPadding: EdgeInsets.zero,
                                          )))
                            ]), // faculty & staff
                            Row(children: [
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                            title: const Text("Alumni"),
                                            value: alumniChecked,
                                            onChanged: (value) {
                                              setState(() {
                                                alumniChecked = value!;
                                              });
                                            },
                                            contentPadding: EdgeInsets.zero,
                                          )))
                            ]), // alumni
                            Row(children: [
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                            title: const Text("General Public"),
                                            value: generalPublicChecked,
                                            onChanged: (value) {
                                              setState(() {
                                                generalPublicChecked = value!;
                                              });
                                            },
                                            contentPadding: EdgeInsets.zero,
                                          )))
                            ]), // general public
                            Row(children: [
                              Expanded(
                                  child: StatefulBuilder(
                                      builder: (context, setState) =>
                                          CheckboxListTile(
                                            title: const Text(
                                                "Prospective Students"),
                                            value: prospectiveStudentsChecked,
                                            onChanged: (value) {
                                              setState(() {
                                                prospectiveStudentsChecked =
                                                    value!;
                                              });
                                            },
                                            contentPadding: EdgeInsets.zero,
                                          )))
                            ]), // prospective students
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
        // Events scroll view
        CustomScrollView(slivers: <Widget>[
          SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext ctx, int index) {
                  return Container(
                      alignment: Alignment.center,
                      height: 120,
                      padding: const EdgeInsets.all(15),
                      child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext ctx2) {
                                  return AlertDialog(
                                      contentPadding: const EdgeInsets.all(15),
                                      scrollable: false,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                      ),
                                      actions: [
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
                                            Navigator.of(context).pop(DialogsAction.ok);
                                          },
                                          child: const Text(
                                            "Ok",
                                            style: TextStyle(color: Colors.blue),
                                          ),
                                        )
                                      ],
                                      content: ConstrainedBox(
                                        constraints:
                                        const BoxConstraints(maxHeight: 1000),
                                        child: Column(
                                          children: <Widget>[
                                            Flexible(
                                                flex: 1,
                                                fit: FlexFit.loose,
                                                child: Row(children: [
                                                  Expanded(
                                                      child: Text(
                                                          eventItems[index].title +
                                                              '\n',
                                                          textAlign:
                                                          TextAlign.center,
                                                          style: const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                              FontWeight.bold)))
                                                ])),
                                            Flexible(
                                                flex: 0,
                                                fit: FlexFit.loose,
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                        child: Image.network(
                                                            eventItems[index]
                                                                .mediaContent)),
                                                  ],
                                                )),
                                            Flexible(
                                                flex: 1,
                                                fit: FlexFit.tight,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        child:
                                                        SingleChildScrollView(
                                                            child: giveHtml(
                                                                index)))
                                                  ],
                                                ))
                                          ],
                                        ),
                                      ));
                                });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Row(children: [
                                    Expanded(
                                      flex: 1,
                                      child: FadeInImage.memoryNetwork(
                                          fit: BoxFit.fitHeight,
                                          image: eventItems[index].mediaContent,
                                          placeholder: kTransparentImage),
                                    ),
                                    Expanded(
                                      child: Column(children: [
                                        Expanded(
                                          child: Text(eventItems[index].title,
                                              overflow: TextOverflow.visible,
                                              style: const TextStyle(fontSize: 13)),
                                        )
                                      ]),
                                    )
                                  ]))
                            ],
                          )));
                },
                childCount: eventItems.length,
              )),
        ]),




        // Feed scroll view
        CustomScrollView(slivers: <Widget>[
          SliverList(
              delegate: SliverChildBuilderDelegate(
            (BuildContext ctx, int index) {
              return Container(
                  alignment: Alignment.center,
                  height: 120,
                  padding: const EdgeInsets.all(15),
                  child: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext ctx2) {
                              return AlertDialog(
                                  contentPadding: const EdgeInsets.all(15),
                                  scrollable: false,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context)
                                          .pop(DialogsAction.cancel),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final newEvent = FeedItemDataIsar(
                                          description: feedItems[index].description,
                                          eventDate: feedItems[index].eventDate,
                                          link: feedItems[index].link,
                                          locationLat: feedItems[index].locationLat,
                                          locationLong: feedItems[index].locationLong,
                                          mediaContent: feedItems[index].mediaContent,
                                          publicationDate: feedItems[index].publicationDate,
                                          title: feedItems[index].title
                                        );
                                        _isar?.writeTxn(() async {
                                          _isar?.feedItemDataIsars.put(newEvent);
                                        }
                                        );
                                        buildEvents();
                                        Navigator.of(context)
                                            .pop(DialogsAction.ok);
                                      },
                                      child: const Text(
                                        "Add",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    )
                                  ],
                                  content: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxHeight: 1000),
                                    child: Column(
                                      children: <Widget>[
                                        Flexible(
                                            flex: 1,
                                            fit: FlexFit.loose,
                                            child: Row(children: [
                                              Expanded(
                                                  child: Text(
                                                      feedItems[index].title +
                                                          '\n',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold)))
                                            ])),
                                        Flexible(
                                            flex: 0,
                                            fit: FlexFit.loose,
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                    child: Image.network(
                                                        feedItems[index]
                                                            .mediaContent)),
                                              ],
                                            )),
                                        Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child:
                                                        SingleChildScrollView(
                                                            child: giveHtml(
                                                                index)))
                                              ],
                                            ))
                                      ],
                                    ),
                                  ));
                            });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Row(children: [
                            Expanded(
                              flex: 1,
                              child: FadeInImage.memoryNetwork(
                                  fit: BoxFit.fitHeight,
                                  image: feedItems[index].mediaContent,
                                  placeholder: kTransparentImage),
                            ),
                            Expanded(
                              child: Column(children: [
                                Expanded(
                                  child: Text(feedItems[index].title,
                                      overflow: TextOverflow.visible,
                                      style: const TextStyle(fontSize: 13)),
                                )
                              ]),
                            )
                          ]))
                        ],
                      )));
            },
            childCount: feedItems.length,
          )),
        ]),
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

class FeedItemData {
  String? title;
  String? description;
  String? link;
  String? locationLat;
  String? locationLong;
  String? publicationDate;
  String? mediaContent;
  DateTime? eventDate;

  FeedItemData();
}
