import 'user_model.dart';

class ConversationModel {
  final int id;
  final int? userOneId;
  final int? userTwoId;
  final DateTime? createdAt;
  final User? otherUser;
  final String? lastMessageText;  // last_message is a String in the API
  final DateTime? lastMessageAt;
  final int? lastSenderId; // Added to track last sender locally/from API
  final int unreadCount;

  ConversationModel({
    required this.id,
    this.userOneId,
    this.userTwoId,
    this.createdAt,
    this.otherUser,
    this.lastMessageText,
    this.lastMessageAt,
    this.lastSenderId,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? 0,
      userOneId: json['user1_id'] ?? json['user_one_id'],
      userTwoId: json['user2_id'] ?? json['user_two_id'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      otherUser: json['other_user'] != null
          ? User.fromJson(json['other_user'])
          : (json['user1'] != null ? User.fromJson(json['user1']) : null),
      lastMessageText: json['last_message']?.toString(),
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'].toString())
          : null,
      lastSenderId: json['last_sender_id'] ?? (json['last_message_obj']?['sender_id']), 
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  ConversationModel copyWith({
    int? unreadCount,
    String? lastMessageText,
    DateTime? lastMessageAt,
    int? lastSenderId,
  }) {
    return ConversationModel(
      id: id,
      userOneId: userOneId,
      userTwoId: userTwoId,
      createdAt: createdAt,
      otherUser: otherUser,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String content;
  final DateTime? createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      conversationId: json['conversation_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'content': content};
}
