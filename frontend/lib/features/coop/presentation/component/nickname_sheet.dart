import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/settings/presentation/store/nickname_store.dart';

/// 名前を変えるシートを表示し、保存した名前を返す (閉じたら null)
///
/// 「みんなで」画面とロビーで使う。[onSave] を渡すと、保存を押したときに呼び、終わるまで
/// シートを開いたままにする。エラーの文を返すとシートに表示して閉じない。
/// [duplicateWarning] は、入力中の名前がほかのメンバーと同じときの注意 (なければ null)。
Future<SavedNickname?> showNicknameSheet(
  BuildContext context, {
  required SavedNickname current,
  required String helperText,
  Future<String?> Function(SavedNickname saved)? onSave,
  String? Function(String name)? duplicateWarning,
}) => showModalBottomSheet<SavedNickname>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder:
      (context) => _NicknameSheet(
        current: current,
        helperText: helperText,
        onSave: onSave,
        duplicateWarning: duplicateWarning,
      ),
);

// controller はシートと同じ寿命にする。閉じるアニメーションの間も TextField を描画するため
class _NicknameSheet extends HookWidget {
  const _NicknameSheet({
    required this.current,
    required this.helperText,
    required this.onSave,
    required this.duplicateWarning,
  });

  final SavedNickname current;
  final String helperText;
  final Future<String?> Function(SavedNickname saved)? onSave;
  final String? Function(String name)? duplicateWarning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = useTextEditingController(text: current.nickname.value);
    useListenable(controller);
    // 🎲 で決めた名前。入力がこれと同じならおまかせとして保存する
    final autoName = useState<String?>(
      current.isAuto ? current.nickname.value : null,
    );
    final isSaving = useState(false);
    final saveError = useState<String?>(null);
    useEffect(() {
      // すぐ打ち直せるように、今の名前を全選択しておく
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.text.length,
      );
      return null;
    }, const []);

    final input = controller.text.trim();
    final canSave =
        input.isNotEmpty && input != current.nickname.value && !isSaving.value;
    final warning = input.isEmpty ? null : duplicateWarning?.call(input);

    Future<void> save() async {
      if (!canSave) return;
      final saved = SavedNickname(
        Nickname.orAuto(input),
        isAuto: input == autoName.value,
      );
      if (onSave case final onSave?) {
        isSaving.value = true;
        saveError.value = null;
        final error = await onSave(saved);
        if (!context.mounted) return;
        isSaving.value = false;
        if (error != null) {
          saveError.value = error;
          return;
        }
      }
      if (context.mounted) Navigator.of(context).pop(saved);
    }

    void reroll() {
      final name = Nickname.auto().value;
      autoName.value = name;
      saveError.value = null;
      controller.value = TextEditingValue(
        text: name,
        selection: TextSelection.collapsed(offset: name.length),
      );
    }

    return PopScope(
      canPop: !isSaving.value,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('名前を変える', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              enabled: !isSaving.value,
              maxLength: Nickname.maxLength,
              textInputAction: TextInputAction.done,
              onChanged: (_) => saveError.value = null,
              onSubmitted: (_) => save(),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'あなたの名前',
                helperText: warning ?? helperText,
                helperMaxLines: 2,
                helperStyle:
                    warning == null
                        ? null
                        : TextStyle(color: theme.colorScheme.tertiary),
                errorText: input.isEmpty ? '名前を入力してください' : saveError.value,
                errorMaxLines: 2,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.casino_outlined),
                  tooltip: 'おまかせで決める',
                  onPressed: isSaving.value ? null : reroll,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: canSave ? save : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child:
                    isSaving.value
                        ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// おまかせで付けた名前であることを示すバッジ
class AutoNicknameBadge extends StatelessWidget {
  /// [AutoNicknameBadge] を作成する
  const AutoNicknameBadge({this.small = false, super.key});

  /// メンバー一覧の行の中に置く小さい表示にするか
  final bool small;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 5 : 6,
          vertical: small ? 1 : 2,
        ),
        child: Text(
          'おまかせ',
          style: (small
                  ? theme.textTheme.labelSmall?.copyWith(fontSize: 10)
                  : theme.textTheme.labelSmall)
              ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
        ),
      ),
    );
  }
}
