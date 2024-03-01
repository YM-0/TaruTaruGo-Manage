import 'package:beacon_app/src/controller/geolocation_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// パスワード表示切替
final obscureTextProvider = StateProvider((ref) => true);

// ログイン成否テキスト
final loginInfoTextProvider = StateProvider((ref) => "");

// ログインID
final idProvider = StateProvider((ref) => "");

// ログインパスワード
final passwordProvider = StateProvider((ref) => "");

// 混雑状況テキスト
final congestionStateProvider = StateProvider((ref) => "未設定");

// 混雑状況アイコン
final congestionIconProvider = StateProvider((ref) => "");

// ユーザーID
final userIdProvider = StateProvider<User?>((ref) => null);

// 位置情報送信
final locationProvider = Provider((ref) {
  final userId = ref.watch(userIdProvider);
  // ユーザーIDがnullでないことを確認（nullの場合は例外を投げるか、または適切に処理）
  if (userId == null) throw Exception("User not logged in");
  return LocationService(userId);
});

final sendLocationFlagProvider = StateProvider((ref) => false);

// 画像パス1
final imagePath1Provider = StateProvider((ref) => "");

// 画像パス2
final imagePath2Provider = StateProvider((ref) => "");

// 画像パス3
final imagePath3Provider = StateProvider((ref) => "");

// Imageタップ時のダイアログ用
final selectedDialogValueProvider = StateProvider<int?>((ref) => 1);
