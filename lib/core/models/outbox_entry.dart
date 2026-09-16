class OutboxEntry {
  final String idempotencyKey;
  final String operation;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  const OutboxEntry({
    required this.idempotencyKey,
    required this.operation,
    required this.payload,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'op': operation,
      'idempotencyKey': idempotencyKey,
      'payload': payload,
    };
  }

  factory OutboxEntry.fromJson(Map<String, dynamic> json) {
    return OutboxEntry(
      idempotencyKey: json['idempotencyKey'] as String,
      operation: json['op'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toStorageJson() {
    return {
      'idempotencyKey': idempotencyKey,
      'op': operation,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
