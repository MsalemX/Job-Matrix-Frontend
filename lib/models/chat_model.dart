import 'user_model.dart';

class ConversationModel {
  final int id;
  final int userOneId;
  final int userTwoId;
  final DateTime? createdAt;
  final User? otherUser;
  final MessageModel? lastMessage;

  ConversationModel({
    required this.id,
    required this.userOneId,
    required this.userTwoId,
    this.createdAt,
    this.otherUser,
    this.lastMessage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? 0,
      userOneId: json['user_one_id'] ?? 0,
      userTwoId: json['user_two_id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      otherUser: json['other_user'] != null
          ? User.fromJson(json['other_user'])
          : null,
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'])
          : null,
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
