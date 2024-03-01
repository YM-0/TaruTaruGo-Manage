import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 混雑状況管理クラス
class CrowdingStateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? userId;

  // ユーザーIDを受け取る
  CrowdingStateService(this.userId);

  // 混雑状況を送信する関数
  Future<void> sendCrowdingState(String crowdingState) async {
    final userDoc = _firestore.collection('users').doc(userId?.uid);
    // 混雑状況とタイムスタンプをFirestoreに更新
    await userDoc.update({
      'crowding_situation': crowdingState,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
