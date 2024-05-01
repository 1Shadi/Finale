import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../features/HomeScreen/home_screen.dart';
import '../../features/ImageSliderScreen/image_slider_screen.dart';
import '../../features/chats/chat.dart';

class ListViewWidget extends StatefulWidget {
  final String docId, itemColor, userImg, name, userId, itemModel, postId;
  final String itemPrice, description, address, userNumber;
  final DateTime date;
  final double lat, lng;
  final List<String> urlslist;

  const ListViewWidget({
    Key? key,
    required this.docId,
    required this.itemColor,
    required this.userImg,
    required this.name,
    required this.date,
    required this.userId,
    required this.itemModel,
    required this.postId,
    required this.itemPrice,
    required this.description,
    required this.lat,
    required this.lng,
    required this.address,
    required this.userNumber,
    required this.urlslist,
  }) : super(key: key);

  @override
  State<ListViewWidget> createState() => _ListViewWidgetState();
}

class _ListViewWidgetState extends State<ListViewWidget> {
  late String oldUserName, oldPhoneNumber, selectedDoc, uid;
  late String oldItemPrice, oldItemModel, oldItemDescription, oldItemName;
  late TextEditingController userNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController itemPriceController;
  late TextEditingController itemNameController;
  late TextEditingController itemModelController;
  late TextEditingController itemDescriptionController;
  late List<String> urlslist;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    // Initialize controllers with initial values
    userNameController = TextEditingController(text: widget.name);
    phoneNumberController = TextEditingController(text: widget.userNumber);
    itemPriceController = TextEditingController(text: widget.itemPrice);
    itemNameController = TextEditingController(text: widget.itemModel);
    itemModelController = TextEditingController(text: widget.itemModel);
    itemDescriptionController = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    // Dispose controllers
    userNameController.dispose();
    phoneNumberController.dispose();
    itemPriceController.dispose();
    itemNameController.dispose();
    itemModelController.dispose();
    itemDescriptionController.dispose();
    super.dispose();
  }

  Future<void> showDialogForUpdateData(Map<String, String> map) async {
    selectedDoc = map['docId']!; // Set the selectedDoc to the document ID
    userNameController.text =
        map['name']!; // Set initial values for text controllers
    phoneNumberController.text = map['userNumber']!;
    itemPriceController.text = map['itemPrice']!;
    itemNameController.text = map['itemModel']!;
    itemModelController.text = map['itemModel']!;
    itemDescriptionController.text = map['description']!;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Update Data',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'Bebas',
              letterSpacing: 2.0,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: userNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                  ),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  controller: phoneNumberController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your phone number',
                  ),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  controller: itemPriceController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your item price',
                  ),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  controller: itemNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your item name',
                  ),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  controller: itemModelController,
                  decoration: const InputDecoration(
                    hintText: 'Enter item model',
                  ),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  controller: itemDescriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Enter item description',
                  ),
                ),
                const SizedBox(height: 5.0),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                updateProfileNameOnExistingPost(userNameController.text);
                _updateUserName(
                    userNameController.text, phoneNumberController.text);

                FirebaseFirestore.instance
                    .collection('items')
                    .doc(selectedDoc)
                    .update({
                  'userName': userNameController.text,
                  'userNumber': phoneNumberController.text,
                  'itemPrice': itemPriceController.text,
                  'itemModel': itemNameController.text,
                  'description': itemDescriptionController.text,
                }).then((_) {
                  Fluttertoast.showToast(
                    msg: 'The task has been uploaded',
                    toastLength: Toast.LENGTH_LONG,
                    backgroundColor: Colors.grey,
                    fontSize: 18.0,
                  );
                }).catchError((onError) {
                  print(onError);
                });
              },
              child: const Text('Update Now'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateProfileNameOnExistingPost(String oldUserName) async {
    await FirebaseFirestore.instance
        .collection('items')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      for (int index = 0; index < snapshot.docs.length; index++) {
        String userProfileNameInPost = snapshot.docs[index]['user'];

        if (userProfileNameInPost != oldUserName) {
          FirebaseFirestore.instance
              .collection('items')
              .doc(snapshot.docs[index].id)
              .update(
            {
              'userName': oldUserName,
            },
          );
        }
      }
    });
  }

  Future<void> _updateUserName(
      String oldUserName, String oldPhoneNumber) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update(
      {
        'userName': oldUserName,
        'userNumber': oldPhoneNumber,
      },
    );
  }

  Future<void> getUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final items = await FirebaseFirestore.instance.collection('items').get();
      for (var item in items.docs) {
        final itemData = item.data() as Map<String, dynamic>;
        if (itemData['id'] == currentUser.uid) {
          setState(() {
            oldUserName = userData['userName'];
            oldPhoneNumber = userData['userNumber'];
            oldItemPrice =
                itemData['itemPrice']; // Assign itemPrice from itemData
            oldItemModel =
                itemData['itemModel']; // Assign itemModel from itemData
            oldItemDescription =
                itemData['description']; // Assign description from itemData
            oldItemName =
                itemData['itemModel']; // Assign itemName from itemData
          });
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 16.0,
        shadowColor: Colors.white10,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.orange],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onDoubleTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageSliderScreen(
                          title: widget.itemModel,
                          itemColor: widget.itemColor,
                          userNumber: widget.userNumber,
                          description: widget.description,
                          lat: widget.lat,
                          lng: widget.lng,
                          address: widget.address,
                          itemPrice: widget.itemPrice,
                          urlslist: widget.urlslist),
                    ),
                  );
                },
                child: Image.network(
                  widget.urlslist[0],
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 8.0,
                  bottom: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        widget.userImg,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          widget.itemModel,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          DateFormat('dd MMM, yyyy - hh:mm a')
                              .format(widget.date)
                              .toString(),
                          style: const TextStyle(
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                    widget.userId != uid
                        ? GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => ChatScreen(
                              //       currentUserId: uid,
                              //       sellerId: widget.userId,
                              //     ),
                              //   ),
                              // );


                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      currentUserId: FirebaseAuth.instance.currentUser!.uid,
                                      chatUserId: widget.userId,
                                    ),
                                  ),
                                );

                            },
                            child: const Icon(Icons.chat, color: Colors.white),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        currentUserId: uid,
                                        chatUserId: widget.userId,
                                      ),
                                    ),
                                  );
                                },
                                child:
                                    const Icon(Icons.chat, color: Colors.white),
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialogForUpdateData({
                                    'docId': widget.docId,
                                    'name': widget.name,
                                    'userNumber': widget.userNumber,
                                    'itemPrice': widget.itemPrice,
                                    'itemModel': widget.itemModel,
                                    'description': widget.description,
                                    // Add other fields as needed
                                  });
                                },
                                icon: const Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: Icon(
                                    Icons.edit_note,
                                    color: Colors.white,
                                    size: 27,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('items')
                                      .doc(widget.postId)
                                      .delete();

                                  Fluttertoast.showToast(
                                    msg: 'Post has been deleted',
                                    toastLength: Toast.LENGTH_LONG,
                                    backgroundColor: Colors.grey,
                                    fontSize: 18.0,
                                  );
                                },
                                icon: const Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: Icon(
                                    Icons.delete_forever,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
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
