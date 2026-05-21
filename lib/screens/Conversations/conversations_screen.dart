import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/chat_model.dart';
import '../../models/user_model.dart';
import '../Dashboard/widgets/sidebar.dart';
import '../Dashboard/widgets/header.dart';
import '../Invite/invite_handler_screen.dart';

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
  bool _showArchived = false;

  // Current logged-in user id (fetched once)
  int _myUserId = 0;

  // Selection mode for messages
  bool _isSelectMode = false;
  final Set<int> _selectedMessageIds = {};
  MessageModel? _replyingToMessage;
  final Set<int> _highlightedMessageIds = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final me = await ApiService.getMyProfile();
    final convs = await ApiService.getConversations(archived: _showArchived);
    if (!mounted) return;
    setState(() {
      _myUserId = me?.id ?? 0;
      _conversations = convs;
      _loadingConversations = false;
    });
    // Auto-open conversation if initialUserId is provided
    final initId = widget.initialUserId;
    if (initId != null) {
      await _openConversationWithUser(initId);
    }
  }

  Future<void> _toggleView(bool showArchived) async {
    if (_showArchived == showArchived) return;
    setState(() {
      _showArchived = showArchived;
      _loadingConversations = true;
      _selected = null; // Clear active chat when switching views
      _messages = [];
    });
    await _loadAll();
  }

  Future<void> _archiveChat(ConversationModel conv) async {
    final success = await ApiService.archiveConversation(conv.id, !conv.isArchived);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              conv.isArchived
                  ? 'Conversation unarchived successfully'
                  : 'Conversation archived successfully',
            ),
            backgroundColor: const Color(0xFF23393E),
          ),
        );
        // If the archived chat was selected, clear selected
        if (_selected?.id == conv.id) {
          setState(() {
            _selected = null;
            _messages = [];
          });
        }
        _loadAll();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while processing the request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteChat(ConversationModel conv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Conversation',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF23393E)),
        ),
        content: const Text(
          'Are you sure you want to permanently delete this conversation? This will delete all messages and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ApiService.deleteConversation(conv.id);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conversation deleted successfully'),
            backgroundColor: Colors.redAccent,
          ),
        );
        // If the deleted chat was selected, clear selected
        if (_selected?.id == conv.id) {
          setState(() {
            _selected = null;
            _messages = [];
          });
        }
        _loadAll();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while deleting the conversation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF23393E) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Future<void> _openConversationWithUser(int targetUserId) async {
    final match = _conversations
        .where((c) => c.otherUser?.id == targetUserId)
        .toList();
    if (match.isNotEmpty) {
      await _selectConversation(match.first);
    } else {
      setState(() => _loadingMessages = true);
      // Conversation doesn't exist yet — create it by calling the endpoint
      final msgs = await ApiService.getMessages(targetUserId);
      // Reload conversations to get the newly created one
      final refreshed = await ApiService.getConversations(archived: _showArchived);
      if (!mounted) return;
      setState(() {
        _conversations = refreshed;
        final newMatch = _conversations
            .where((c) => c.otherUser?.id == targetUserId)
            .toList();
        if (newMatch.isNotEmpty) {
          _selected = newMatch.first.copyWith(unreadCount: 0);
          // Update the item in the list too
          final idx = _conversations.indexOf(newMatch.first);
          _conversations[idx] = _selected!;
          _messages = msgs;
        }
        _loadingMessages = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _selectConversation(ConversationModel conv) async {
    // Clear unread count locally
    setState(() {
      _isSelectMode = false;
      _selectedMessageIds.clear();
      _replyingToMessage = null;
      _highlightedMessageIds.clear();
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
    final replyId = _replyingToMessage?.id;
    setState(() {
      _replyingToMessage = null;
    });
    final msg = await ApiService.sendMessage(_selected!.id, text, replyToId: replyId);
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

  Future<void> _deleteMessagesBulk({required String deleteType, List<int>? targetIds}) async {
    final ids = targetIds ?? _selectedMessageIds.toList();
    if (ids.isEmpty) return;

    if (deleteType == 'everyone') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Delete for Everyone',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF23393E)),
          ),
          content: Text(
            ids.length == 1
                ? 'Are you sure you want to delete this message for everyone?'
                : 'Are you sure you want to delete these ${ids.length} messages for everyone?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    final success = await ApiService.deleteMessages(ids, deleteType: deleteType);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              deleteType == 'everyone'
                  ? 'Message(s) deleted for everyone successfully'
                  : 'Message(s) deleted for me successfully',
            ),
            backgroundColor: const Color(0xFF23393E),
          ),
        );
        setState(() {
          _isSelectMode = false;
          _selectedMessageIds.clear();
        });
        if (_selected != null) {
          await _selectConversation(_selected!);
          await _loadAll();
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while deleting the message(s)'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToAndHighlightMessage(int msgId) {
    final idx = _messages.indexWhere((m) => m.id == msgId);
    if (idx == -1) return;

    if (_scrollCtrl.hasClients) {
      final ratio = idx / _messages.length;
      final target = ratio * _scrollCtrl.position.maxScrollExtent;
      _scrollCtrl.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    setState(() {
      _highlightedMessageIds.add(msgId);
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _highlightedMessageIds.remove(msgId);
        });
      }
    });
  }

  Future<void> _forwardSelectedMessages() async {
    if (_selectedMessageIds.isEmpty) return;

    final sortedSelectedMsgs = _messages
        .where((m) => _selectedMessageIds.contains(m.id) && !m.isDeleted)
        .toList();

    if (sortedSelectedMsgs.isEmpty) return;

    final selectedConv = await showDialog<ConversationModel?>(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = _conversations.where((c) {
              final name = c.otherUser?.name ?? '';
              return name.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return AlertDialog(
              title: const Text(
                'Forward Messages',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF23393E)),
              ),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search active chats...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: filtered.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text('No active chats found'),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final c = filtered[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: const Color(0xFF23393E),
                                    backgroundImage: c.otherUser?.profile?.profileImage != null
                                        ? NetworkImage(c.otherUser!.profile!.profileImage!)
                                        : null,
                                    child: c.otherUser?.profile?.profileImage == null
                                        ? Text(
                                            (c.otherUser?.name ?? '?')[0].toUpperCase(),
                                            style: const TextStyle(color: Colors.white, fontSize: 10),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    c.otherUser?.name ?? 'Unknown',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () => Navigator.pop(context, c),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedConv == null) return;

    int successCount = 0;
    for (final msg in sortedSelectedMsgs) {
      final result = await ApiService.sendMessage(selectedConv.id, msg.content);
      if (result != null) {
        successCount++;
        if (_selected?.id == selectedConv.id && mounted) {
          setState(() {
            _messages.add(result);
          });
        }
      }
    }

    if (successCount > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$successCount messages forwarded successfully'),
          backgroundColor: const Color(0xFF23393E),
        ),
      );
      if (_selected?.id == selectedConv.id) {
        _scrollToBottom();
      }
    }

    setState(() {
      _isSelectMode = false;
      _selectedMessageIds.clear();
    });
  }

  Future<void> _forwardMessage(MessageModel msg) async {
    final selectedConv = await showDialog<ConversationModel?>(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = _conversations.where((c) {
              final name = c.otherUser?.name ?? '';
              return name.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return AlertDialog(
              title: const Text(
                'Forward Message',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF23393E)),
              ),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search active chats...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: filtered.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text('No active chats found'),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final c = filtered[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: const Color(0xFF23393E),
                                    backgroundImage: c.otherUser?.profile?.profileImage != null
                                        ? NetworkImage(c.otherUser!.profile!.profileImage!)
                                        : null,
                                    child: c.otherUser?.profile?.profileImage == null
                                        ? Text(
                                            (c.otherUser?.name ?? '?')[0].toUpperCase(),
                                            style: const TextStyle(color: Colors.white, fontSize: 10),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    c.otherUser?.name ?? 'Unknown',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () => Navigator.pop(context, c),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedConv == null) return;

    final result = await ApiService.sendMessage(selectedConv.id, msg.content);
    if (result != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message forwarded successfully'),
            backgroundColor: Color(0xFF23393E),
          ),
        );
        if (_selected?.id == selectedConv.id) {
          setState(() {
            _messages.add(result);
          });
          _scrollToBottom();
        }
        _loadAll();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to forward message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF23393E),
                      ),
                    ),
                    Row(
                      children: [
                        _buildTabButton(
                          title: 'Active',
                          isActive: !_showArchived,
                          onTap: () => _toggleView(false),
                        ),
                        const SizedBox(width: 8),
                        _buildTabButton(
                          title: 'Archived',
                          isActive: _showArchived,
                          onTap: () => _toggleView(true),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Autocomplete<User>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<User>.empty();
                    }
                    return await ApiService.searchUsers(textEditingValue.text);
                  },
                  displayStringForOption: (User option) => option.name,
                  onSelected: (User selection) {
                    _openConversationWithUser(selection.id);
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search user...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF23393E), width: 1.5),
                        ),
                      ),
                      onSubmitted: (_) => onFieldSubmitted(),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 260,
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final User option = options.elementAt(index);
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: option.profile?.profileImage != null
                                      ? NetworkImage(option.profile!.profileImage!)
                                      : null,
                                  backgroundColor: const Color(0xFF23393E),
                                  child: option.profile?.profileImage == null
                                      ? Text(
                                          option.username.substring(0, 1).toUpperCase(),
                                          style: const TextStyle(color: Colors.white, fontSize: 10),
                                        )
                                      : null,
                                ),
                                title: Text(option.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                subtitle: Text('@${option.username}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (unread > 0) ...[
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
                  const SizedBox(height: 4),
                ],
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (value) {
                    if (value == 'archive') {
                      _archiveChat(conv);
                    } else if (value == 'delete') {
                      _deleteChat(conv);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'archive',
                      child: Row(
                        children: [
                          Icon(
                            conv.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                            size: 16,
                            color: const Color(0xFF23393E),
                          ),
                          const SizedBox(width: 8),
                          Text(conv.isArchived ? 'Unarchive' : 'Archive', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: const Row(
                        children: [
                          Icon(Icons.delete_outline, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(fontSize: 13, color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
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
        _isSelectMode
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF23393E),
                  border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _isSelectMode = false;
                              _selectedMessageIds.clear();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Selected: ${_selectedMessageIds.length} messages',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSelectMode = false;
                              _selectedMessageIds.clear();
                            });
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _selectedMessageIds.isEmpty
                              ? null
                              : _forwardSelectedMessages,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Forward'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _selectedMessageIds.isEmpty
                              ? null
                              : () async {
                                  final canDeleteForEveryone = _selectedMessageIds.every((id) {
                                    try {
                                      final msg = _messages.firstWhere((m) => m.id == id);
                                      return msg.senderId == _myUserId;
                                    } catch (_) {
                                      return false;
                                    }
                                  });

                                  if (canDeleteForEveryone) {
                                    final choice = await showDialog<String>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Selected Messages', style: TextStyle(fontWeight: FontWeight.bold)),
                                        content: Text('Do you want to delete these ${_selectedMessageIds.length} messages for yourself or for everyone?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, 'cancel'),
                                            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, 'me'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Delete for Me'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, 'everyone'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Delete for Everyone'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (choice == 'me') {
                                      await _deleteMessagesBulk(deleteType: 'me');
                                    } else if (choice == 'everyone') {
                                      await _deleteMessagesBulk(deleteType: 'everyone');
                                    }
                                  } else {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Selected Messages', style: TextStyle(fontWeight: FontWeight.bold)),
                                        content: Text('Are you sure you want to delete these ${_selectedMessageIds.length} messages for yourself?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await _deleteMessagesBulk(deleteType: 'me');
                                    }
                                  }
                                },
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.redAccent.withOpacity(0.4),
                            disabledForegroundColor: Colors.white.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Container(
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
    final isSelected = _selectedMessageIds.contains(msg.id);

    // Check if the message is a project invite link
    final isInviteText = msg.content.startsWith('PROJECT_INVITE::');
    final isRawInviteLink = !isInviteText && (msg.content.contains('/#/invite/') || msg.content.contains('/invite/'));
    
    String projectName = 'Project Invite';
    String inviteLink = '';
    String inviteCode = '';
    
    if (isInviteText) {
      final parts = msg.content.split('::');
      if (parts.length >= 3) {
        projectName = parts[1];
        inviteLink = parts[2];
      }
    } else if (isRawInviteLink) {
      inviteLink = msg.content.trim();
    }

    if (inviteLink.isNotEmpty) {
      try {
        final uri = Uri.parse(inviteLink);
        if (uri.fragment.isNotEmpty) {
          final fragmentUri = Uri.parse(uri.fragment);
          inviteCode = fragmentUri.pathSegments.last;
        } else {
          inviteCode = uri.pathSegments.last;
        }
      } catch (e) {
        inviteCode = inviteLink.split('/').last;
      }
    }

    final isInvite = isInviteText || isRawInviteLink;

    Widget bubbleContent;
    if (msg.isDeleted) {
      bubbleContent = Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: _highlightedMessageIds.contains(msg.id)
              ? Border.all(color: Colors.amber, width: 2)
              : Border.all(color: Colors.grey.shade200),
        ),
        child: const Text(
          'This message was deleted',
          style: TextStyle(
            color: Colors.black38,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    } else {
      bubbleContent = Container(
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
          border: _highlightedMessageIds.contains(msg.id)
              ? Border.all(color: Colors.amber, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (msg.replyTo != null) ...[
              GestureDetector(
                onTap: () => _scrollToAndHighlightMessage(msg.replyTo!.id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(6),
                    border: Border(
                      left: BorderSide(
                        color: isMe ? Colors.white70 : const Color(0xFF23393E),
                        width: 3,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.replyTo!.senderId == _myUserId ? 'You' : (_selected?.otherUser?.name ?? 'Other User'),
                        style: TextStyle(
                          color: isMe ? Colors.white : const Color(0xFF23393E),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        msg.replyTo!.isDeleted ? 'This message was deleted' : msg.replyTo!.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isMe ? Colors.white60 : Colors.black54,
                          fontSize: 12,
                          fontStyle: msg.replyTo!.isDeleted ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            isInvite
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          projectName,
                          style: TextStyle(
                            color: isMe ? Colors.white : const Color(0xFF23393E),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        inviteLink,
                        style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (inviteCode.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InviteHandlerScreen(inviteCode: inviteCode),
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.remove_red_eye_outlined,
                          size: 16,
                          color: isMe ? const Color(0xFF23393E) : Colors.white,
                        ),
                        label: Text(
                          'Preview Project',
                          style: TextStyle(
                            color: isMe ? const Color(0xFF23393E) : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMe ? Colors.white : const Color(0xFF23393E),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    msg.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
          ],
        ),
      );
    }

    Widget? menuButton;
    if (!msg.isDeleted && !_isSelectMode) {
      menuButton = PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 16, color: Colors.black38),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onSelected: (value) {
          if (value == 'reply') {
            setState(() {
              _replyingToMessage = msg;
            });
          } else if (value == 'forward') {
            _forwardMessage(msg);
          } else if (value == 'delete_me') {
            _deleteMessagesBulk(deleteType: 'me', targetIds: [msg.id]);
          } else if (value == 'delete_everyone') {
            _deleteMessagesBulk(deleteType: 'everyone', targetIds: [msg.id]);
          } else if (value == 'select') {
            setState(() {
              _isSelectMode = true;
              _selectedMessageIds.add(msg.id);
            });
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'reply',
            child: Row(
              children: [
                Icon(Icons.reply, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text('Reply', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'forward',
            child: Row(
              children: [
                Icon(Icons.forward, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text('Forward', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete_me',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 16, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete for me', style: TextStyle(fontSize: 13, color: Colors.red)),
              ],
            ),
          ),
          if (isMe)
            const PopupMenuItem(
              value: 'delete_everyone',
              child: Row(
                children: [
                  Icon(Icons.delete_forever, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete for everyone', style: TextStyle(fontSize: 13, color: Colors.red)),
                ],
              ),
            ),
          const PopupMenuItem(
            value: 'select',
            child: Row(
              children: [
                Icon(Icons.check_box_outlined, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text('Select', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () {
        if (_isSelectMode && !msg.isDeleted) {
          setState(() {
            if (isSelected) {
              _selectedMessageIds.remove(msg.id);
            } else {
              _selectedMessageIds.add(msg.id);
            }
          });
        }
      },
      child: Container(
        color: _isSelectMode && isSelected
            ? const Color(0xFF23393E).withOpacity(0.08)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isSelectMode) ...[
                Checkbox(
                  value: isSelected,
                  activeColor: const Color(0xFF23393E),
                  onChanged: msg.isDeleted
                      ? null
                      : (val) {
                          setState(() {
                            if (val == true) {
                              _selectedMessageIds.add(msg.id);
                            } else {
                              _selectedMessageIds.remove(msg.id);
                            }
                          });
                        },
                ),
                const SizedBox(width: 8),
              ],
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
              if (isMe && menuButton != null) ...[
                menuButton,
                const SizedBox(width: 4),
              ],
              Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  bubbleContent,
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 10, color: Colors.black38),
                    ),
                  ],
                ],
              ),
              if (!isMe && menuButton != null) ...[
                const SizedBox(width: 4),
                menuButton,
              ],
              if (isMe) const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplyPreview() {
    if (_replyingToMessage == null) return const SizedBox.shrink();
    final senderName = _replyingToMessage!.senderId == _myUserId ? 'You' : (_selected?.otherUser?.name ?? 'Other User');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: const Border(
          top: BorderSide(color: Color(0xFFEEEEEE)),
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF23393E),
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replying to $senderName',
                  style: const TextStyle(
                    color: Color(0xFF23393E),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _replyingToMessage!.isDeleted ? 'This message was deleted' : _replyingToMessage!.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontStyle: _replyingToMessage!.isDeleted ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            onPressed: () {
              setState(() {
                _replyingToMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_replyingToMessage != null) _buildReplyPreview(),
        Container(
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
        ),
      ],
    );
  }
}
