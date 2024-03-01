import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beacon_app/src/providers/provider.dart';

class LocationService {
  Timer? _timer;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? userId;

  LocationService(this.userId);

  Future<void> startSendingLocation() async {
    debugPrint("geolocation");
    // 位置情報サービスのパーミッションを確認
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // パーミッションが永続的に拒否されている場合の処理
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // 10秒ごとに位置情報を取得してFirestoreに送信
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      // 緯度・経度コンソール出力
      debugPrint(position.toString());
      _sendLocationToFirestore(position);
    });
  }

  Future<void> _sendLocationToFirestore(Position position) async {
    final userDoc = _firestore.collection('users').doc(userId?.uid);
    await userDoc.update({
      'geolocation': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void stopSendingLocation() {
    _timer?.cancel();
  }
}
