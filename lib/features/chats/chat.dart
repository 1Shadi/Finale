import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tabeeby_app/features/navbar/navbar.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String chatUserId;
  final String? userName;

  const ChatScreen(
      {super.key,
      required this.currentUserId,
      required this.chatUserId,
      this.userName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late String recipientUserName = '';

  Future<void> fetchRecipientUserName() async {
    try {
      final DocumentSnapshot recipientSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.chatUserId)
          .get();

      if (recipientSnapshot.exists) {
        setState(() {
          recipientUserName = recipientSnapshot['userName'];
        });
      }
    } catch (e) {
      print('Error fetching recipient user name: $e');
    }
  }


  void _sendReceivedMessage(String messageText) {
    _messageController.text = messageText;
    _sendMessage();
  }

  @override
  void initState() {
    print(widget.currentUserId);
    print(widget.chatUserId);
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreMessages();
      }
    });
    fetchRecipientUserName();

  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreMessages() async {}

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      await FirebaseFirestore.instance.collection('messages').add({
        'sender': widget.currentUserId,
        'recipient': widget.chatUserId,
        'text': messageText,
        'timestamp': Timestamp.now(),
      });
      _messageController.clear();
      _scrollController.animateTo(
        _scrollController.position.pixels + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessageItem(BuildContext context, DocumentSnapshot message) {
    final messageData = message.data() as Map<String, dynamic>;
    final messageText = messageData['text'];
    final messageSender = messageData['sender'];
    final messageRecipient = messageData['recipient'];
    final messageTimestamp = messageData['timestamp'];

    final isMe = messageSender == widget.currentUserId;

    return GestureDetector(
      onTap: () {
        final messageText = messageData['text'];
        _sendReceivedMessage(messageText);
      },
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: isMe ? Colors.blueAccent : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12.0),
                topRight: const Radius.circular(12.0),
                bottomLeft: isMe
                    ? const Radius.circular(0.0)
                    : const Radius.circular(12.0),
                bottomRight: isMe
                    ? const Radius.circular(12.0)
                    : const Radius.circular(0.0),
              ),
            ),
            child: Text(
              messageText,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            messageTimestamp.toDate().toString(),
            style: const TextStyle(fontSize: 12.0, color: Colors.white70),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.teal],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(widget.userName ?? recipientUserName),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.chevron_left)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('messages')
                      .where('sender', isEqualTo: widget.currentUserId)
                      .where('recipient', isEqualTo: widget.chatUserId)
                      .orderBy('timestamp')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final messagesSent = snapshot.data?.docs ?? [];
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('messages')
                            .where('sender', isEqualTo: widget.chatUserId)
                            .where('recipient', isEqualTo: widget.currentUserId)
                            .orderBy('timestamp')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final messagesReceived = snapshot.data?.docs ?? [];
                            final allMessages = [
                              ...messagesSent,
                              ...messagesReceived
                            ];
                            allMessages.sort((a, b) =>
                                (a['timestamp'] as Timestamp)
                                    .compareTo(b['timestamp'] as Timestamp));
                            return ListView.builder(
                              controller: _scrollController,
                              itemCount: allMessages.length,
                              itemBuilder: (context, index) {
                                return _buildMessageItem(
                                    context, allMessages[index]);
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
