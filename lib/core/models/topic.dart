import 'package:equatable/equatable.dart';

class Topic extends Equatable {
  final String id;
  final String name;
  final String icon;

  const Topic({required this.id, required this.name, required this.icon});

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'icon': icon};
  }

  @override
  List<Object?> get props => [id];
}

extension TopicLookup on List<Topic> {
  String nameFor(String id) {
    for (final topic in this) {
      if (topic.id == id) return topic.name;
    }
    return '';
  }
}
