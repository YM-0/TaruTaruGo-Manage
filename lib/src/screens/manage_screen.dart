import 'dart:io';

import 'package:beacon_app/src/controller/crowding_state_controller.dart';
import 'package:beacon_app/src/controller/geolocation_controller.dart';
import 'package:beacon_app/src/providers/provider.dart';
import 'package:beacon_app/src/widget/image_tap_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

// 管理画面ウィジェット
class MangeScreen extends ConsumerWidget {
  const MangeScreen({super.key});

  // ボタンタップ時、混雑状況を設定しFirestoreに送信する関数
  void _onButtonTap(BuildContext context, WidgetRef ref,
      CrowdingStateService crowdingStateService, String status, String icon) {
    // 混雑状況とアイコンを更新
    ref.read(congestionStateProvider.notifier).state = status;
    ref.read(congestionIconProvider.notifier).state = icon;
    // Firestoreに送信
    crowdingStateService.sendCrowdingState(ref.watch(congestionStateProvider));
  }

  // 画像を選択し、Firebase Storageにアップロードする関数
  Future<void> _selectImage(
      BuildContext context, WidgetRef ref, num flag) async {
    final _firestore = FirebaseFirestore.instance;
    final _firestorage = FirebaseStorage.instance.ref();
    final picker = ImagePicker();
    // ギャラリーから画像を選択
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final user = ref.watch(userIdProvider);
      final int timestamp = DateTime.now().microsecondsSinceEpoch;
      // ファイルのパス
      final File file = File(pickedFile.path);
      // パスを/で区切った最後の値をnameに入れる
      final String name = file.path.split('/').last;
      final String path = '${timestamp}_$name';
      final TaskSnapshot task = await _firestorage
          .child('users/${user?.uid}/photos') // フォルダ名
          .child(path) // ファイル名
          .putFile(file); // 画像ファイル

      // アップロードした画像のURLを取得
      final String imageURL = await task.ref.getDownloadURL();
      // アップロードした画像の保存先を取得
      final String imagePath = task.ref.fullPath;

      final userDoc = _firestore.collection('users').doc(user?.uid);

      // Firestoreに画像情報を保存
      switch (flag) {
        case 1:
          ref.read(imagePath1Provider.notifier).state = pickedFile.path;
          await userDoc.update({
            'shop_image1': {'image_path': imagePath, 'image_url': imageURL}
          });
          break;
        case 2:
          ref.read(imagePath2Provider.notifier).state = pickedFile.path;
          await userDoc.update({
            'shop_image2': {'image_path': imagePath, 'image_url': imageURL}
          });
          break;
        case 3:
          ref.read(imagePath3Provider.notifier).state = pickedFile.path;
          await userDoc.update({
            'shop_image3': {'image_path': imagePath, 'image_url': imageURL}
          });
          break;
        default:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 状態管理プロバイダーから混雑状況、アイコン、位置情報送信フラグを取得
    final congestionState = ref.watch(congestionStateProvider);
    final congestionIcon = ref.watch(congestionIconProvider);
    final sendLocationFlag = ref.watch(sendLocationFlagProvider);

    // 画像パスを取得
    String imagePath1 = ref.watch(imagePath1Provider);
    String imagePath2 = ref.watch(imagePath2Provider);
    String imagePath3 = ref.watch(imagePath3Provider);

    Color textColor = Colors.black;

    // 画像ファイルオブジェクトを初期化
    File? imageFile1;
    File? imageFile2;
    File? imageFile3;
    if (imagePath1 != "") {
      imageFile1 = File(imagePath1);
    }
    if (imagePath2 != "") {
      imageFile2 = File(imagePath2);
    }
    if (imagePath3 != "") {
      imageFile3 = File(imagePath3);
    }

    // 位置情報サービスと混雑状況サービスを初期化
    LocationService locationService =
        LocationService(ref.watch(userIdProvider));
    CrowdingStateService crowdingStateService =
        CrowdingStateService(ref.watch(userIdProvider));

    // 位置情報の送信が未開始の場合、送信を開始
    if (!sendLocationFlag) {
      locationService.startSendingLocation();
      Future.microtask(
          () => ref.read(sendLocationFlagProvider.notifier).state = true);
    }

    // 混雑状況に応じてテキストカラーを変更
    if (congestionState == AppLocalizations.of(context)!.vacant) {
      textColor = Colors.blue;
    } else if (congestionState == AppLocalizations.of(context)!.usually) {
      textColor = Colors.green;
    } else if (congestionState ==
        AppLocalizations.of(context)!.slightly_crowded) {
      textColor = Colors.yellow;
    } else if (congestionState == AppLocalizations.of(context)!.crowded) {
      textColor = Colors.orange;
    } else if (congestionState == AppLocalizations.of(context)!.full) {
      textColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(41, 42, 42, 1),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.manage,
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              child: Text(
                AppLocalizations.of(context)!.crowding_situation,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
                height: 110,
                width: double.infinity,
                child: Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  margin: const EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              congestionState,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 20,
                          child: congestionIcon.isNotEmpty
                              ? Image.asset(
                                  congestionIcon,
                                  height: 50,
                                )
                              : SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                )),
            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Wrap(
                children: [
                  buttonCard(
                    AppLocalizations.of(context)!.vacant,
                    "assets/images/vacant.png",
                    Colors.blue,
                    () => _onButtonTap(
                        context,
                        ref,
                        crowdingStateService,
                        AppLocalizations.of(context)!.vacant,
                        "assets/images/vacant.png"),
                  ),
                  buttonCard(
                      AppLocalizations.of(context)!.usually,
                      "assets/images/usually.png",
                      Colors.green,
                      () => _onButtonTap(
                          context,
                          ref,
                          crowdingStateService,
                          AppLocalizations.of(context)!.usually,
                          "assets/images/usually.png")),
                  buttonCard(
                      AppLocalizations.of(context)!.slightly_crowded,
                      "assets/images/slightly_crowded.png",
                      Colors.yellow,
                      () => _onButtonTap(
                          context,
                          ref,
                          crowdingStateService,
                          AppLocalizations.of(context)!.slightly_crowded,
                          "assets/images/slightly_crowded.png")),
                  buttonCard(
                      AppLocalizations.of(context)!.crowded,
                      "assets/images/crowded.png",
                      Colors.orange,
                      () => _onButtonTap(
                          context,
                          ref,
                          crowdingStateService,
                          AppLocalizations.of(context)!.crowded,
                          "assets/images/crowded.png")),
                  buttonCard(
                      AppLocalizations.of(context)!.full,
                      "assets/images/full.png",
                      Colors.red,
                      () => _onButtonTap(
                          context,
                          ref,
                          crowdingStateService,
                          AppLocalizations.of(context)!.full,
                          "assets/images/full.png"))
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              child: Text(
                AppLocalizations.of(context)!.shop_image,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Wrap(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (imageFile1 == null) {
                        _selectImage(context, ref, 1);
                      } else {
                        ref.read(selectedDialogValueProvider.notifier).state =
                            1;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ImageTapDialog();
                          },
                        ).then((value) {
                          if (value == 1) {
                            _selectImage(context, ref, 1);
                          } else if (value == 2) {
                            ref.read(imagePath1Provider.notifier).state = "";
                            imageFile1 = null;
                          }
                        });
                      }
                    },
                    child: Container(
                      height: 100,
                      width: 110,
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(60, 150, 150, 150),
                      ),
                      child: imageFile1 != null
                          ? Image.file(
                              imageFile1,
                              fit: BoxFit.contain,
                            )
                          : Center(
                              child: Text(
                                  AppLocalizations.of(context)!.image_select)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (imageFile2 == null) {
                        _selectImage(context, ref, 2);
                      } else {
                        ref.read(selectedDialogValueProvider.notifier).state =
                            1;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ImageTapDialog();
                          },
                        ).then((value) {
                          if (value == 1) {
                            _selectImage(context, ref, 2);
                          } else if (value == 2) {
                            ref.read(imagePath2Provider.notifier).state = "";
                            imageFile2 = null;
                          }
                        });
                      }
                    },
                    child: Container(
                      height: 100,
                      width: 110,
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(60, 150, 150, 150),
                      ),
                      child: imageFile2 != null
                          ? Image.file(
                              imageFile2,
                              fit: BoxFit.contain,
                            )
                          : Center(
                              child: Text(
                                  AppLocalizations.of(context)!.image_select)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (imageFile3 == null) {
                        _selectImage(context, ref, 3);
                      } else {
                        ref.read(selectedDialogValueProvider.notifier).state =
                            1;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ImageTapDialog();
                          },
                        ).then((value) {
                          if (value == 1) {
                            _selectImage(context, ref, 3);
                          } else if (value == 2) {
                            ref.read(imagePath3Provider.notifier).state = "";
                            imageFile3 = null;
                          }
                        });
                      }
                    },
                    child: Container(
                      height: 100,
                      width: 110,
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(60, 150, 150, 150),
                      ),
                      child: imageFile3 != null
                          ? Image.file(
                              imageFile3!,
                              fit: BoxFit.contain,
                            )
                          : Center(
                              child: Text(
                                  AppLocalizations.of(context)!.image_select)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// 混雑状況ボタンのUI
Widget buttonCard(String title, String image, Color color, VoidCallback onTap) {
  return Container(
    padding: EdgeInsets.all(5),
    height: 100,
    width: 120,
    child: Card(
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                image,
                height: 45,
              ),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
