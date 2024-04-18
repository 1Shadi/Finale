import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/Widgets/global_var.dart';
import '../../WelcomeScreen/welcome_screen.dart';

class HomeScreenProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String uid;

  Future<void> initializeData() async {
    final user = _auth.currentUser;
    if (user != null) {
      uid = user.uid;
      await getMyData();
      await getUserAddress();
    } else {
      // Handle when user is not logged in
    }
  }

  Future<void> getMyData() async {
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      userImageUrl = doc['userImage'];
      getUserName = doc['userName'];
      notifyListeners();
    } else {
      // Handle when user data is not found
    }
  }

  Future<void> getUserAddress() async {
    try {
      Position newPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      position = newPosition;

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position!.latitude, position!.longitude);
      Placemark placemark = placemarks[0];

      String newCompleteAddress =
          '${placemark.subThoroughfare} ${placemark.thoroughfare},'
          '${placemark.subThoroughfare} ${placemark.locality},'
          '${placemark.subAdministrativeArea},'
          '${placemark.administrativeArea} ${placemark.postalCode},'
          '${placemark.country},';

      completeAddress = newCompleteAddress;

      if (kDebugMode) {
        print(completeAddress);
      }

      notifyListeners();
    } catch (e) {
      // Handle errors while getting user address
      if (kDebugMode) {
        print('Error getting user address: $e');
      }
    }
  }

  void signOut(BuildContext context) {
    _auth.signOut().then((value) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
    });
  }
}
