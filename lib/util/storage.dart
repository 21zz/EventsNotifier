import 'package:isar/isar.dart';

part 'storage.g.dart';

@Collection()
class FeedItemDataIsar {
  Id id;

  String? title;
  String? description;
  String? link;
  String? locationLat;
  String? locationLong;
  String? publicationDate;
  String? mediaContent;
  DateTime? eventDate;

  FeedItemDataIsar({
    required this.id,
    this.title,
    this.description,
    this.link,
    this.locationLat,
    this.locationLong,
    this.publicationDate,
    this.mediaContent,
    this.eventDate,
  });
}
