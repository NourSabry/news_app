import 'package:equatable/equatable.dart';

class Author extends Equatable {
  final String id;
  final String name;
  final String? avatar;
  final String? bio;

  const Author({
    required this.id,
    required this.name,
    this.avatar,
    this.bio,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (avatar != null) 'avatar': avatar,
      if (bio != null) 'bio': bio,
    };
  }

  @override
  List<Object?> get props => [id, name];
}
