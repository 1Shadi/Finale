import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String chatUserId;

  const ChatScreen({required this.currentUserId, required this.chatUserId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  void _sendReceivedMessage(String messageText) {
    _messageController.text = messageText;
    _sendMessage();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreMessages();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreMessages() async {
    // Load more messages here
  }

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
        duration: Duration(milliseconds: 300),
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
            margin: EdgeInsets.symmetric(vertical: 8.0),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: isMe ? Colors.blueAccent : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
                bottomLeft: isMe ? Radius.circular(0.0) : Radius.circular(12.0),
                bottomRight:
                    isMe ? Radius.circular(12.0) : Radius.circular(0.0),
              ),
            ),
            child: Text(
              messageText,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            messageTimestamp.toDate().toString(),
            style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatUserId),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('recipient', whereIn: [widget.chatUserId, widget.currentUserId])
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final messages = snapshot.data?.docs ?? [];
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageItem(context, messages[index]);
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
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
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
