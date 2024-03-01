import 'package:beacon_app/src/controller/user_controller.dart';
import 'package:beacon_app/src/screens/manage_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon_app/src/providers/provider.dart';

// ログイン画面ウィジェット
class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 状態管理プロバイダーを使用して、ログインフォームの各種状態を管理
    final obscureText = ref.watch(obscureTextProvider);
    final id = ref.watch(idProvider); // ユーザーID
    final password = ref.watch(passwordProvider); // パスワード
    final loginInfoText = ref.watch(loginInfoTextProvider); // // ログインテキスト

    final _auth = FirebaseAuth.instance;

    // UserServiceのインスタンスを作成
    UserService userService = UserService();

    // パスワードの表示/非表示を切り替える関数
    void _togglePasswordVisibility() {
      if (obscureText) {
        ref.read(obscureTextProvider.notifier).state = false;
      } else {
        ref.read(obscureTextProvider.notifier).state = true;
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(children: [
            const SizedBox(
              height: 100,
            ),
            Text(
              AppLocalizations.of(context)!.title,
              style: TextStyle(
                  fontFamily: "Bauhaus93",
                  fontSize: 50,
                  color: Color.fromRGBO(90, 150, 130, 1)),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Column(
                children: [
                  TextFormField(
                    // ユーザーID入力
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.id,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String value) {
                      ref.read(idProvider.notifier).state = value;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    // パスワード入力
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // パスワードの表示/非表示を切り替え
                          obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    onChanged: (String value) {
                      ref.read(passwordProvider.notifier).state = value;
                    },
                  ),
                ],
              ),
            ),
            // ログイン試行結果のテキスト表示
            Text(
              loginInfoText,
              style: TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: () async {
                // 次画面テスト用
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => MangeScreen()),
                // );
                try {
                  // Firebase Authを使用したログイン試行
                  UserCredential user = await _auth.signInWithEmailAndPassword(
                      email: id, password: password);
                  debugPrint(AppLocalizations.of(context)!.login_success);
                  // ログイン成功
                  FocusScope.of(context).unfocus(); // キーボードを隠す
                  ref.read(userIdProvider.notifier).state =
                      FirebaseAuth.instance.currentUser;
                  // ユーザードキュメントの確認・作成
                  await userService.createUserDocument(user.user!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MangeScreen()),
                  );
                } catch (e) {
                  // ログイン失敗
                  ref.read(loginInfoTextProvider.notifier).state =
                      AppLocalizations.of(context)!.login_error;
                }
              },
              child: Text(AppLocalizations.of(context)!.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
