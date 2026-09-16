class FeedUpdate {
  final List<String> newItems;
  final List<String> updatedItems;
  final List<String> deletedItems;
  final DateTime serverTime;

  const FeedUpdate({
    required this.newItems,
    required this.updatedItems,
    required this.deletedItems,
    required this.serverTime,
  });

  bool get hasChanges =>
      newItems.isNotEmpty || updatedItems.isNotEmpty || deletedItems.isNotEmpty;

  factory FeedUpdate.fromJson(Map<String, dynamic> json) {
    return FeedUpdate(
      newItems: (json['newItems'] as List<dynamic>).map((e) => e as String).toList(),
      updatedItems: (json['updatedItems'] as List<dynamic>).map((e) => e as String).toList(),
      deletedItems: (json['deletedItems'] as List<dynamic>).map((e) => e as String).toList(),
      serverTime: DateTime.parse(json['serverTime'] as String),
    );
  }
}
