import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/Widgets/global_var.dart';
import '../../core/Widgets/listview.dart';
import '../HomeScreen/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String sellerId;

  ProfileScreen({Key? key, required this.sellerId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String adUserName = ''; // Initialize adUserName with an empty string
  String? adUserImageUrl;

  @override
  void initState() {
    super.initState();
    getResult();
    uid = FirebaseAuth.instance.currentUser!.uid;

  }

  void getResult() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get()
          .then((DocumentSnapshot snapshot) {
        setState(() {
          if (snapshot.exists) {
            adUserName = snapshot['userName'];
            adUserImageUrl = snapshot['userImage'];
          }
        });
      }).catchError((error) {
        print("Error fetching user data: $error");
      });
    }
  }

  Widget _buildUserImage() {
    if (adUserImageUrl != null && adUserImageUrl!.isNotEmpty) {
      return Container(
        width: 50,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(adUserImageUrl!),
            fit: BoxFit.fill,
          ),
        ),
      );
    } else {
      // If adUserImageUrl is null or empty, show a default image
      return Container(
        width: 50,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/images/logo.png'), // Adjust the asset path accordingly
            fit: BoxFit.fill,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange, Colors.teal],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
          title: Row(
            children: [
              _buildUserImage(),
              const SizedBox(width: 10),
              Text(adUserName, style: const TextStyle(color: Colors.black)),
            ],
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange, Colors.teal],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
        ),
        body:
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('items')
              .where('id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Something went wrong',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              );
            } else {
              final data = snapshot.data;
              if (data == null || data.docs.isEmpty) {
                return const Center(child: Text('There is no task'));
              } else {
                return ListView.builder(
                  itemCount: data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final doc = data.docs[index];
                    final itemColor = doc.get('itemColor'); // Access the field safely
                    return ListViewWidget(
                      docId: doc.id,
                      itemColor: itemColor ?? 'No color', // Provide a default value if itemColor is null
                      img1: doc['urlImage1'],
                      img2: doc['urlImage2'],
                      img3: doc['urlImage3'],
                      img4: doc['urlImage4'],
                      img5: doc['urlImage5'],
                      userImg: doc['imgPro'],
                      name: doc['userName'],
                      date: doc['time'].toDate(),
                      userId: doc['id'],
                      itemModel: doc['itemModel'],
                      postId: doc['postId'],
                      itemPrice: doc['itemPrice'],
                      description: doc['description'],
                      lat: doc['lat'],
                      lng: doc['lng'],
                      address: doc['address'],
                      userNumber: doc['userNumber'],
                    );
                  },
                );
              }
            }
          },
        ),
      ),
    );
  }
}
