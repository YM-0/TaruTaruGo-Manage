import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // ドキュメントが存在しない場合は新規作成
      return userDoc.set({
        'uid': user.uid,
        'crowding_situation': "",
        'geolocation': {'latitude': "", 'longitude': ""},
        'shop_image1': {'imagePath': "", 'imageURL': ""},
        'shop_image2': {'imagePath': "", 'imageURL': ""},
        'shop_image3': {'imagePath': "", 'imageURL': ""},
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }
}
