class SupportRequest {
  final String id;
  final String? userId;
  final String subject;
  final String message;
  final String status;
  final String? audioUrl;
  final String? adminResponse;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? senderName;
  final String? senderPhone;

  SupportRequest({
    required this.id,
    this.userId,
    required this.subject,
    required this.message,
    required this.status,
    this.audioUrl,
    this.adminResponse,
    required this.createdAt,
    this.updatedAt,
    this.senderName,
    this.senderPhone,
  });

  factory SupportRequest.fromJson(Map<String, dynamic> json) {
    return SupportRequest(
      id: json['id'],
      userId: json['user_id'],
      subject: json['subject'],
      message: json['message'],
      status: json['status'],
      audioUrl: json['audio_url'],
      adminResponse: json['admin_response'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      senderName: json['sender_name'],
      senderPhone: json['sender_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subject': subject,
      'message': message,
      'status': status,
      'audio_url': audioUrl,
      'admin_response': adminResponse,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'sender_name': senderName,
      'sender_phone': senderPhone,
    };
  }
}
