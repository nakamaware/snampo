## 概要

<!-- Issueの背景・目的・概要 -->

アプリを新規インストール (入れ直し) した直後に初めてミッションを完了した場合のみ、履歴にユーザー撮影写真が保存されず、所要時間が 0 秒と表示されることがある。

### 原因

- `missionProgressStore` の `startProgress` が `ref.listen` 内の `Future(() async { ... })` で遅延実行され、永続ストレージ初期化や `build` 完了前後と重なると、撮影時の `savePhoto` が `state.value == null` のため何も記録されない。
- 「到着」押下時 `_resolveCurrentProgress` が `progress == null` のフォールバックでその瞬間に `startProgress` すると、`startedAt` が完了時刻とほぼ同じになり `formatMissionDuration` 上 0 秒になる。
- 撮影直後のミッション画面上では `cameraStore` のプレビューにより写真が表示されているように見える一方、チェックポイントにパスが載っていない場合がある。

### 再現手順 (想定)

1. アプリをアンインストール後、新規インストールする。
2. ミッションを開始し、ミッション情報表示後できるだけ早く各スポットで撮影する (またはストレージ初期化が遅い端末で同様のタイミングを取る)。
3. 「到着」で完了し、履歴画面を開く。

### 期待する動作

- 撮影したユーザー写真が履歴 (およびサムネイル) に反映される。
- ミッション開始から完了までの所要時間が妥当に表示される。

### 実際の動作

- 履歴のスポットに `userPhotoPath` が無い (一覧でプレースホルダ画像)。
- 所要時間が「0 秒」に見える ( `startedAt` ≒ `completedAt` )。

## タスク

<!-- 実装に必要なタスクを記入してください (Issueの場合は、「#<IssueNumber>」でリンクできます) -->

- [ ] `startProgress` / `clearProgress` を、スナップ撮影より前に確実に完了させる (遅延 `Future` の見直し、ミッション `data` 表示ガードなど)。
- [ ] `savePhoto` が `current == null` で黙って失敗しないよう、キュー・再試行・またはユーザーへのエラー表示を検討する。
- [ ] (必要なら) `_resolveCurrentProgress` の `progress == null` 時に `startProgress` で `startedAt` を上書きしないよう、完了済みミッションと矛盾しない設計にする。

## 備考

<!-- その他、Issueに関連する情報があれば記入してください -->

- 参照: `frontend/lib/features/mission/presentation/page/mission_page.dart` ( `Future(() async { ... })` 、 `_resolveCurrentProgress` )、`frontend/lib/features/mission/presentation/store/mission_progress_store.dart` ( `savePhoto` )。
- 関連: 履歴機能 (`feat/75-add-history` など) と `missionProgressStore` の統合箇所。
