import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:tabeeby_app/features/HomeScreen/home_screen.dart';
import 'package:tabeeby_app/features/navbar/navbar.dart';
import 'package:uuid/uuid.dart';

import '../../core/DialogBox/loading_dialog.dart';
import '../../core/Widgets/global_var.dart';

class UploadAdScreen extends StatefulWidget {
  const UploadAdScreen({Key? key}) : super(key: key);

  @override
  State<UploadAdScreen> createState() => _UploadAdScreenState();
}

class _UploadAdScreenState extends State<UploadAdScreen> {
  String postId = const Uuid().v4();
  bool uploading = false, next = false;
  final List<File> _image = [];
  List<String> urlslist = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String name = '';
  String phoneNo = '';
  double val = 0;
  String itemPrice = '';
  String itemModel = '';
  String itemWeight = '';
  String description = '';
  String address = '';
  double? latitude;
  double? longitude;

  Future<void> chooseImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image.add(File(pickedFile.path));
      });
    }
  }

  // Future<void> uploadFile() async {
  //   int i = 1;
  //   for (var img in _image) {
  //     setState(() {
  //       val = i / _image.length;
  //     });
  //     var ref = FirebaseStorage.instance
  //         .ref()
  //         .child('image/${Path.basename(img.path)}');
  //
  //     await ref.putFile(img).whenComplete(() async {
  //       await ref.getDownloadURL().then((value) {
  //         urlslist.add(value);
  //         i++;
  //       });
  //     });
  //   }
  // }

  Future<void> uploadFile() async {
    List<String> downloadUrls = [];
    int i = 1;
    try {
      for (var img in _image) {
        setState(() {
          val = i / _image.length;
        });
        var ref = FirebaseStorage.instance
            .ref()
            .child('image/${Path.basename(img.path)}');

        await ref.putFile(img);

        var downloadUrl = await ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
        i++;
      }

      // After all images are uploaded, set the urlslist and proceed to upload data
      setState(() {
        urlslist = downloadUrls;
      });

      // Empty the _image list to free up memory
      _image.clear();
    } catch (error) {
      print('Error uploading file: $error');
      Fluttertoast.showToast(
        msg: 'An error occurred while uploading file',
      );
    }
  }

  Future<void> uploadData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance.collection('items').doc(postId).set({
          'userName': name,
          'id': currentUser.uid,
          'postId': postId,
          'userNumber': phoneNo,
          'itemPrice': itemPrice,
          'itemModel': itemModel,
          'itemWeight': itemWeight,
          'description': description,
          'urlslist': urlslist,
          'imgPro': userImageUrl,
          'lst': latitude,
          'lng': longitude,
          'address': address,
          'time': DateTime.now(),
          'status': 'approved',
        });

        Fluttertoast.showToast(
          msg: 'Data added successfully....',
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NavBar(currentUserId: currentUser.uid),
          ),
        );
      }
    } catch (error) {
      print('Error uploading data: $error');
      Fluttertoast.showToast(
        msg: 'An error occurred while uploading data',
      );
    }
  }

  getNameOfUser() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get()
          .then((snapshot) async {
        if (snapshot.exists) {
          setState(() {
            name = snapshot.data()!['userName'];
            phoneNo = snapshot.data()!['userNumber'];
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getNameOfUser();
    getLocation();
  }

  void getLocation() {}

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
          title: Text(
            next ? "Please write product info" : "Choose product image(s)",
            style: const TextStyle(
              color: Colors.black54,
              fontFamily: 'Signatra',
              fontSize: 30,
            ),
          ),
          actions: [
            next
                ? Container()
                : ElevatedButton(
                    onPressed: () {
                      if (_image.isNotEmpty) {
                        setState(() {
                          uploading = true;
                          next = true;
                        });
                      } else {
                        Fluttertoast.showToast(
                          msg: 'Please select product images',
                          gravity: ToastGravity.CENTER,
                        );
                      }
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.black54,
                        fontFamily: 'Varela',
                      ),
                    ),
                  ),
          ],
        ),
        body: next
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 5.0),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Enter Product Price',
                        ),
                        onChanged: (value) {
                          setState(() {
                            itemPrice = value;
                          });
                        },
                      ),
                      const SizedBox(height: 5.0),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Enter Product Name',
                        ),
                        onChanged: (value) {
                          setState(() {
                            itemModel = value;
                          });
                        },
                      ),
                      const SizedBox(height: 5.0),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Enter Product Weight',
                        ),
                        onChanged: (value) {
                          setState(() {
                            itemWeight = value;
                          });
                        },
                      ),
                      const SizedBox(height: 5.0),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Enter the address',
                        ),
                        onChanged: (value) {
                          setState(() {
                            address = value;
                          });
                        },
                      ),
                      const SizedBox(height: 5.0),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Write a description',
                        ),
                        onChanged: (value) {
                          setState(() {
                            description = value;
                          });
                        },
                      ),
                      const SizedBox(height: 15.0),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const LoadingAlertDialog(
                                  message: 'Uploading...',
                                );
                              },
                            );
                            uploadFile().whenComplete(() {
                              FirebaseFirestore.instance
                                  .collection('items')
                                  .doc(postId)
                                  .set({
                                'userName': name,
                                'id': _auth.currentUser!.uid,
                                'postId': postId,
                                'userNumber': phoneNo,
                                'itemPrice': itemPrice,
                                'itemModel': itemModel,
                                'itemWeight': itemWeight,
                                'description': description,
                                'urlImage': urlslist,
                                'imgPro': userImageUrl,
                                'lst': latitude,
                                'lng': longitude,
                                'address': address,
                                'time': DateTime.now(),
                                'status': 'approved',
                              });
                              Fluttertoast.showToast(
                                msg: 'Data added successfully....',
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NavBar(currentUserId: _auth.currentUser!.uid),
                                ),
                              );
                            }).catchError((onError) {
                              print(onError);
                            });
                          },
                          child: const Text(
                            'Upload',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    child: GridView.builder(
                      itemCount: _image.length + 1,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context, index) {
                        return index == 0
                            ? Center(
                                child: IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    !uploading
                                        ? chooseImage(ImageSource.gallery)
                                        : null;
                                  },
                                ),
                              )
                            : Container(
                                margin: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(_image[index - 1]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                      },
                    ),
                  ),
                  uploading
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Uploading...',
                                style: TextStyle(fontSize: 20),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CircularProgressIndicator(
                                value: val,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
      ),
    );
  }
}
