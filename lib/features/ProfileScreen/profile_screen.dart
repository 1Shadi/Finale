import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/Widgets/global_var.dart';
import '../../core/Widgets/listview.dart';
import '../HomeScreen/home_screen.dart';

class ProfileScreen extends StatefulWidget {

  String sellerId;

  ProfileScreen({super.key, required this.sellerId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  _buildBackButton()
  {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white,),
      onPressed: ()
      {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      },
    );
  }

  _buildUserImage()
  {
    return Container(
      width: 50,
      height: 40,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: NetworkImage(adUserImageUrl),
              fit: BoxFit.fill
          )
      ),
    );
  }

  getResult() {
    FirebaseFirestore.instance
        .collection('items')
        .where('id', isEqualTo: widget.sellerId)
        .where('status', isEqualTo: 'approved')
        .get()
        .then((results) {
      setState(() {
        items = results;
        adUserName = items!.docs[0].get('userName');
        adUserImageUrl = items!.docs[0].get('imgPro');

      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getResult();
  }
  QuerySnapshot? items;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepOrange,
            Colors.teal,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: _buildBackButton(),
          title: Row(
            children: [
              _buildUserImage(),
              const SizedBox(width: 10,),
              Text(adUserName),
            ],
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepOrange,
                  Colors.teal,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
        )
        ,
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('items')
              .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              // .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                final items = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = items[index].data() as Map<String, dynamic>;
                    return ListViewWidget(
                      docId: items[index].id,
                      itemColor: item['itemColor'] ?? '',
                      img1: item['urlImage1'] ?? '',
                      img2: item['urlImage2'] ?? '',
                      img3: item['urlImage3'] ?? '',
                      img4: item['urlImage4'] ?? '',
                      img5: item['urlImage5'] ?? '',
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
            } else {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
          },

        ),
      ),

    );
  }
}
