import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../SearchProduct/search_product.dart';
import '../../core/Widgets/global_var.dart';
import '../../core/Widgets/listview.dart';
import '../ProfileScreen/profile_screen.dart';
import '../UploadAdScreen/upload_ad_screen.dart';
import '../WelcomeScreen/welcome_screen.dart';
import '../chats/chat_contact.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      uid = currentUser.uid;
      userEmail = currentUser.email!;
      getMyData();
    }
  }

  Future<void> getMyData() async {
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      userImageUrl = userData['userImage'];
      getUserName = userData['userName'];
    });
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
          automaticallyImplyLeading: false,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessageSenderScreen(currentUserId: uid,)),
                );
              },
              child: const Text('Your Chats'),
            ),
            IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      sellerId: uid,
                    ),
                  ),
                );
                await getMyData();
              },
              icon: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.person, color: Colors.black),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchProduct()),
                );
              },
              icon: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.search, color: Colors.orange),
              ),
            ),
            IconButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WelcomeScreen()),
                );
              },
              icon: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.logout, color: Colors.orange),
              ),
            ),
          ],
          title: const Text(
            'Home Screen',
            style: TextStyle(
              color: Colors.black54,
              fontFamily: 'Signatra',
              fontSize: 30,
            ),
          ),
          centerTitle: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.teal],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('items')
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final items = snapshot.data!.docs;
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = items[index].data() as Map<String, dynamic>;
                  return ListViewWidget(
                    docId: items[index].id,
                    itemColor: item['itemColor'] ?? '',
                    urlslist:
                        (item['urlImage'] as List<dynamic>).cast<String>(),
                    userImg: item['imgPro'] ?? '',
                    name: item['userName'] ?? '',
                    date: item['time']?.toDate() ?? DateTime.now(),
                    userId: item['id'] ?? '',
                    itemModel: item['itemModel'] ?? '',
                    postId: item['postId'] ?? '',
                    itemPrice: item['itemPrice'] ?? '',
                    description: item['description'] ?? '',
                    lat: item['lat'] ?? 0.0,
                    lng: item['lng'] ?? 0.0,
                    address: item['address'] ?? '',
                    userNumber: item['userNumber'] ?? '',
                  );
                },
              );
            } else {
              return const Center(
                child: Text('No items found'),
              );
            }
          },
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            tooltip: 'Add Post',
            backgroundColor: Colors.black54,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UploadAdScreen(),
                ),
              );
            },
            child: const Icon(Icons.cloud_upload, color: Colors.white),
          ),
        ),
      ),
    );
  }
}




//
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key, required this.currentUserId, required this.sellerId});
//
//   final String currentUserId;
//   final String sellerId;
//
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with Seller'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('chats')
//                     .doc(widget.currentUserId)
//                     .collection(widget.sellerId)
//                     .orderBy('timestamp', descending: true)
//                     .snapshots(),
//                 builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   }
//
//                   final messages = snapshot.data!.docs;
//                   return ListView.builder(
//                     controller: _scrollController,
//                     reverse: true,
//                     itemCount: messages.length,
//                     itemBuilder: (context, index) {
//                       final message = messages[index].data() as Map<String, dynamic>?;
//                       if (message == null) {
//                         return SizedBox();
//                       }
//                       final sender = message['sender'];
//                       final text = message['text'];
//                       final isCurrentUser = sender == widget.currentUserId;
//
//                       return Align(
//                         alignment: isCurrentUser
//                             ? Alignment.centerRight
//                             : Alignment.centerLeft,
//                         child: Column(
//                           crossAxisAlignment: isCurrentUser
//                               ? CrossAxisAlignment.end
//                               : CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               margin: const EdgeInsets.symmetric(horizontal: 8.0),
//                               padding: const EdgeInsets.all(8.0),
//                               decoration: BoxDecoration(
//                                 color: isCurrentUser
//                                     ? Colors.blue
//                                     : Colors.black54,
//                                 borderRadius: BorderRadius.circular(12.0),
//                               ),
//                               child: Text(
//                                 text,
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                               child: Text(
//                                 isCurrentUser ? 'You' : sender,
//                                 style: TextStyle(
//                                   color: isCurrentUser ? Colors.blue : Colors.black54,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 },
//               )),
//           Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type your message...',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: () {
//                     _sendMessage();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _sendMessage() {
//     String messageText = _messageController.text.trim();
//
//     if (messageText.isNotEmpty) {
//       FirebaseFirestore.instance
//           .collection('chats')
//           .doc(widget.currentUserId)
//           .collection(widget.sellerId)
//           .add({
//         'text': messageText,
//         'sender': widget.currentUserId,
//         'timestamp': Timestamp.now(),
//       });
//       _messageController.clear();
//       _scrollController.animateTo(
//         0.0,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }
// }
//
// class YourChatsScreen extends StatefulWidget {
//   const YourChatsScreen({super.key});
//
//   @override
//   _YourChatsScreenState createState() => _YourChatsScreenState();
// }
//
// class _YourChatsScreenState extends State<YourChatsScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Your Chats'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore
//             .collection('chats')
//             .where('sender', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//             .where('recipient', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(
//               child: Text('No chats'),
//             );
//           }
//
//           final chats = snapshot.data!.docs;
//           return ListView.builder(
//             itemCount: chats.length,
//             itemBuilder: (context, index) {
//               final chat = chats[index];
//               final sellerId = chat.id;
//               final messages = (chat.data() as Map<String, dynamic>? ??
//                   {})['messages'] as List<dynamic>? ??
//                   [];
//               final latestMessage = messages.isNotEmpty ? messages.last : null;
//               final sender = latestMessage?['sender'];
//               final text = latestMessage?['text'];
//               final isCurrentUser =
//                   sender == FirebaseAuth.instance.currentUser?.uid;
//
//               return FutureBuilder<DocumentSnapshot>(
//                 future: _firestore.collection('users').doc(sender).get(),
//                 builder:
//                     (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
//                   if (userSnapshot.connectionState == ConnectionState.waiting) {
//                     return CircularProgressIndicator();
//                   }
//
//                   if (!userSnapshot.hasData || userSnapshot.data == null) {
//                     return SizedBox();
//                   }
//
//                   final senderData =
//                   userSnapshot.data!.data() as Map<String, dynamic>;
//                   final senderName = senderData['userName'];
//
//                   return ListTile(
//                     title: Text(isCurrentUser ? 'You' : senderName),
//                     subtitle: Text(text ?? ''),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ChatScreen(
//                             currentUserId:
//                             FirebaseAuth.instance.currentUser!.uid,
//                             sellerId: sellerId,
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }