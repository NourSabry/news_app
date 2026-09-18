import 'package:equatable/equatable.dart';

class ContentBlock extends Equatable {
  final String type;
  final String? text;
  final String? url;

  const ContentBlock({required this.type, this.text, this.url});

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    return ContentBlock(
      type: json['type'] as String,
      text: json['text'] as String?,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (text != null) 'text': text,
      if (url != null) 'url': url,
    };
  }

  @override
  List<Object?> get props => [type, text, url];
}
