import 'song.dart';

enum QueueItemType {
  manual,
  automatic,
}

class QueueItem {
  final String queueId;
  final Song song;
  final QueueItemType type;

  const QueueItem({
    required this.queueId,
    required this.song,
    required this.type,
  });

  bool get isManual => type == QueueItemType.manual;
  bool get isAutomatic => type == QueueItemType.automatic;

  QueueItem copyWith({
    String? queueId,
    Song? song,
    QueueItemType? type,
  }) {
    return QueueItem(
      queueId: queueId ?? this.queueId,
      song: song ?? this.song,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'queueId': queueId,
      'song': song.toMap(),
      'type': type.name,
    };
  }

  factory QueueItem.fromMap(Map<String, dynamic> map) {
    return QueueItem(
      queueId: map['queueId'] as String,
      song: Song.fromMap(map['song'] as Map<String, dynamic>),
      type: QueueItemType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => QueueItemType.automatic,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueueItem &&
          runtimeType == other.runtimeType &&
          queueId == other.queueId;

  @override
  int get hashCode => queueId.hashCode;
}
