import 'package:beacon_app/src/providers/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 画像ダイアログ表示ウィジェット
class ImageTapDialog extends ConsumerWidget {
  ImageTapDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedValue = ref.watch(selectedDialogValueProvider);

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RadioListTile(
            title: Text("写真を選択"),
            value: 1,
            groupValue: selectedValue,
            onChanged: (value) {
              ref.read(selectedDialogValueProvider.notifier).state = value;
            },
          ),
          RadioListTile(
            title: Text("写真を削除"),
            value: 2,
            groupValue: selectedValue,
            onChanged: (value) {
              ref.read(selectedDialogValueProvider.notifier).state = value;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop(); // ダイアログを閉じる
          },
        ),
        TextButton(
          child: Text("OK"),
          onPressed: () {
            // OKボタンが押された場合、選択された値を返す
            Navigator.of(context).pop(selectedValue);
          },
        ),
      ],
    );
  }
}
