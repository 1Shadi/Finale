// import 'dart:io';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as Path;
//
// class UploadAdScreen extends StatefulWidget {
//   const UploadAdScreen({super.key});
//
//   @override
//   State<UploadAdScreen> createState() => _UploadAdScreenState();
// }
//
// class _UploadAdScreenState extends State<UploadAdScreen> {
//   File? _imageFile;
//   List<String> urlslist = [];
//
//   FirebaseAuth _auth = FirebaseAuth.instance;
//
//   double val = 0;
//
//   String itemPrice = '';
//   String itemModel = '';
//   String itemWeight = '';
//   String description = '';
//
//   Future<void> chooseImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<void> uploadFile() async {
//     int i = 1;
//     for (var img in [_imageFile]) {
//       setState(() {
//         val = i / 1;
//       });
//       var ref = FirebaseStorage.instance.ref().child('image/${Path.basename(img!.path)}');
//
//       await ref.putFile(img).whenComplete(() async {
//         await ref.getDownloadURL().then((value) {
//           urlslist.add(value);
//           i++;
//         });
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.orange, Colors.teal],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//           stops: [0.0, 1.0],
//           tileMode: TileMode.clamp,
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.orange, Colors.teal],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//                 stops: [0.0, 1.0],
//                 tileMode: TileMode.clamp,
//               ),
//             ),
//           ),
//           title: Text(
//             "Choose product's image",
//             style: const TextStyle(
//               color: Colors.black54,
//               fontFamily: 'Signatra',
//               fontSize: 30,
//             ),
//           ),
//           actions: [
//             ElevatedButton(
//               onPressed: () {
//                 if (_imageFile != null) {
//                   setState(() {
//                     uploadFile();
//                   });
//                 } else {
//                   Fluttertoast.showToast(
//                     msg: 'Please select an image.',
//                     gravity: ToastGravity.CENTER,
//                   );
//                 }
//               },
//               child: const Text(
//                 'Next',
//                 style: TextStyle(
//                   fontSize: 19,
//                   color: Colors.black54,
//                   fontFamily: 'Varela',
//                 ),
//               ),
//             ),
//           ],
//         ),
//         body: _imageFile == null
//             ? Center(
//           child: IconButton(
//             icon: Icon(Icons.add),
//             onPressed: chooseImage,
//           ),
//         )
//             : Center(
//           child: Image.file(_imageFile!),
//         ),
//       ),
//     );
//   }
// }
