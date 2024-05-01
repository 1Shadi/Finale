import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat.dart';

class MessageSenderScreen extends StatefulWidget {
  final String currentUserId;

  const MessageSenderScreen({required this.currentUserId});

  @override
  _MessageSenderScreenState createState() => _MessageSenderScreenState();
}

class _MessageSenderScreenState extends State<MessageSenderScreen> {
  late Future<List<String>> _fetchChatUsersFuture;

  @override
  void initState() {
    super.initState();
    _fetchChatUsersFuture = _fetchChatUsers();
  }

  Future<List<String>> _fetchChatUsers() async {
    try {
      final currentUser = widget.currentUserId;
      print('Current user: $currentUser');

      if (currentUser == null || currentUser.isEmpty) {
        print('Error: currentUser is null or empty');
        return [];
      }

      // Query messages where the current user is the sender
      final QuerySnapshot senderMessages = await FirebaseFirestore.instance
          .collection('messages')
          .where('sender', isEqualTo: currentUser)
          .get();
      print('Sender messages: ${senderMessages.docs}');

      // Query messages where the current user is the recipient
      final QuerySnapshot recipientMessages = await FirebaseFirestore.instance
          .collection('messages')
          .where('recipient', isEqualTo: currentUser)
          .get();
      print('Recipient messages: ${recipientMessages.docs}');

      // Extract unique users from sender and recipient messages
      final Set<String> chatUsers = {};

      // Add recipients from sender messages
      senderMessages.docs.forEach((doc) {
        final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('recipient')) {
          final recipientId = data['recipient'] as String?;
          if (recipientId != null) {
            chatUsers.add(recipientId);
          }
        }
      });

      // Add senders from recipient messages
      recipientMessages.docs.forEach((doc) {
        final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('sender')) {
          final senderId = data['sender'] as String?;
          if (senderId != null) {
            chatUsers.add(senderId);
          }
        }
      });

      print('Fetched chat users: $chatUsers');
      return chatUsers.toList(); // Convert Set to List
    } catch (error) {
      print('Error fetching chat users: $error');
      return []; // Return an empty list in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: FutureBuilder<List<String>>(
        future: _fetchChatUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final chatUsers = snapshot.data!;
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final users = snapshot.data?.docs ?? [];
                  if (users.isEmpty) {
                    return CircularProgressIndicator();
                  }
                  final userNames = snapshot.data!.docs;
                  if (userNames.length < chatUsers.length) {
                    print('Not enough user data, waiting for more data...');
                    return CircularProgressIndicator();
                  }
                  List<Widget> userListTiles = [];
                  for (int i = 0; i < chatUsers.length; i++) {
                    final userName = userNames[i].data() as Map<String, dynamic>;
                    userListTiles.add(
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                currentUserId: widget.currentUserId,
                                chatUserId: chatUsers[i],
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(userName['userName'] ?? ''),
                          subtitle: Text(chatUsers[i]),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: userListTiles,
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
}
