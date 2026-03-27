import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/chat_model.dart';
import '../Dashboard/widgets/sidebar.dart';
import '../Dashboard/widgets/header.dart';

class ConversationsScreen extends StatefulWidget {
  final int? initialUserId; // If set, auto-open conversation with this user

  const ConversationsScreen({super.key, this.initialUserId});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<ConversationModel> _conversations = [];
  ConversationModel? _selected;
  List<MessageModel> _messages = [];
  bool _loadingConversations = true;
  bool _loadingMessages = false;
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  // Current logged-in user id (fetched once)
  int _myUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final me = await ApiService.getMyProfile();
    final convs = await ApiService.getConversations();
    if (!mounted) return;
    setState(() {
      _myUserId = me?.id ?? 0;
      _conversations = convs;
      _loadingConversations = false;
    });
    // Auto-open conversation if initialUserId is provided
    final initId = widget.initialUserId;
    if (initId != null) {
      final match = _conversations
          .where((c) => c.otherUser?.id == initId)
          .toList();
      if (match.isNotEmpty) {
        await _selectConversation(match.first);
      } else {
        // Conversation doesn't exist yet — create it by calling the endpoint
        final msgs = await ApiService.getMessages(initId);
        // Reload conversations to get the newly created one
        final refreshed = await ApiService.getConversations();
        if (!mounted) return;
        setState(() {
          _conversations = refreshed;
          final newMatch = _conversations
              .where((c) => c.otherUser?.id == initId)
              .toList();
          if (newMatch.isNotEmpty) {
            _selected = newMatch.first.copyWith(unreadCount: 0);
            // Update the item in the list too
            final idx = _conversations.indexOf(newMatch.first);
            _conversations[idx] = _selected!;
            _messages = msgs;
          }
        });
      }
    }
  }

  Future<void> _selectConversation(ConversationModel conv) async {
    // Clear unread count locally
    setState(() {
      final index = _conversations.indexWhere((c) => c.id == conv.id);
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
      }
      _selected =
          _conversations[index != -1 ? index : 0]; // Keep reference updated
      _loadingMessages = true;
      _messages = [];
    });
    // GET /conversations/{otherUserId} returns {conversation, messages}
    final otherUserId = conv.otherUser?.id;
    if (otherUserId == null) {
      setState(() => _loadingMessages = false);
      return;
    }
    final msgs = await ApiService.getMessages(otherUserId);
    if (!mounted) return;
    setState(() {
      _messages = msgs;
      _loadingMessages = false;
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _selected == null) return;
    _msgCtrl.clear();
    final msg = await ApiService.sendMessage(_selected!.id, text);
    if (msg != null && mounted) {
      setState(() {
        _messages.add(msg);

        // Update the conversation list local state
        final index = _conversations.indexWhere((c) => c.id == _selected!.id);
        if (index != -1) {
          final updated = _conversations[index].copyWith(
            lastMessageText: text,
            lastMessageAt: DateTime.now(),
            lastSenderId: _myUserId,
          );
          _conversations.removeAt(index);
          _conversations.insert(0, updated);
          _selected = updated;
        }
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate unread count manually to sync with sidebar immediately
    final totalUnread = _conversations.fold<int>(
      0,
      (sum, c) => sum + (c.unreadCount > 0 ? 1 : 0),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          Sidebar(
            currentRoute: 'conversations',
            manualUnreadCount: totalUnread,
          ),
          Expanded(
            child: Column(
              children: [
                Header(
                  title: 'Conversations',
                  showCreateButton: false,
                  showEditProfileButton: false,
                  onProjectCreated: _loadAll,
                ),
                Expanded(
                  child: Row(
                    children: [
                      // ── Left: Conversation List ──────────────────
                      _buildConversationList(),
                      // ── Right: Chat View ─────────────────────────
                      Expanded(child: _buildChatView()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList() {
    return Container(
      width: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Messages',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF23393E),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loadingConversations
                ? const Center(child: CircularProgressIndicator())
                : _conversations.isEmpty
                ? _buildEmptyConversations()
                : ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (_, i) =>
                        _buildConversationTile(_conversations[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(ConversationModel conv) {
    final isSelected = _selected?.id == conv.id;
    final other = conv.otherUser;
    final name = other?.name ?? 'Unknown';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final isMyLastMsg = conv.lastSenderId == _myUserId;
    final lastMsg =
        (isMyLastMsg ? 'You: ' : '') +
        (conv.lastMessageText ?? 'No messages yet');
    final unread = conv.unreadCount;

    return GestureDetector(
      onTap: () => _selectConversation(conv),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF23393E).withAlpha(12)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? const Color(0xFF23393E) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF23393E),
              backgroundImage: other?.profile?.profileImage != null
                  ? NetworkImage(other!.profile!.profileImage!)
                  : null,
              child: other?.profile?.profileImage == null
                  ? Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      fontSize: 14,
                      color: const Color(0xFF23393E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastMsg,
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (unread > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF23393E),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyConversations() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: Colors.black26),
          SizedBox(height: 12),
          Text(
            'No conversations yet',
            style: TextStyle(color: Colors.black45, fontSize: 14),
          ),
          SizedBox(height: 6),
          Text(
            'Click a user\'s profile to start chatting',
            style: TextStyle(color: Colors.black26, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildChatView() {
    if (_selected == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, size: 64, color: Colors.black26),
            SizedBox(height: 16),
            Text(
              'Select a conversation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    final other = _selected!.otherUser;
    final name = other?.name ?? 'Unknown';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF23393E),
                backgroundImage: other?.profile?.profileImage != null
                    ? NetworkImage(other!.profile!.profileImage!)
                    : null,
                child: other?.profile?.profileImage == null
                    ? Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF23393E),
                ),
              ),
            ],
          ),
        ),
        // Messages list
        Expanded(
          child: _loadingMessages
              ? const Center(child: CircularProgressIndicator())
              : _messages.isEmpty
              ? const Center(
                  child: Text(
                    'No messages yet. Say hello! 👋',
                    style: TextStyle(color: Colors.black38, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(24),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) => _buildMessageBubble(_messages[i]),
                ),
        ),
        // Input area
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageBubble(MessageModel msg) {
    final isMe = msg.senderId == _myUserId;
    final time = msg.createdAt != null
        ? '${msg.createdAt!.hour.toString().padLeft(2, '0')}:${msg.createdAt!.minute.toString().padLeft(2, '0')}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF23393E),
              child: Text(
                (_selected?.otherUser?.name ?? '?')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMe
                      ? const Color(0xFF23393E)
                      : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                ),
                child: Text(
                  msg.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              if (time.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(fontSize: 10, color: Colors.black38),
                ),
              ],
            ],
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: const TextStyle(color: Colors.black38),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF23393E),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
