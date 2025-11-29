# snampo

A new Flutter project.

## セットアップ

セットアップ手順については、プロジェクトルートの [`README.md`](../README.md) を参照してください。

## コード品質ツール

このプロジェクトでは、コードの品質を保つために以下のツールを使用しています。

### リンター・静的解析

プロジェクトでは [very_good_analysis](https://pub.dev/packages/very_good_analysis) を使用してコードの静的解析を行っています。

リンターの設定は `analysis_options.yaml` で管理されています：

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  errors:
    invalid_annotation_target: ignore
```

`invalid_annotation_target` エラーは無視するように設定されています（freezedなどのコード生成ツールとの互換性のため）。

### コード生成

このプロジェクトでは、以下のコード生成ツールを使用しています：

- **freezed**: イミュータブルなクラスとユニオン型の生成
- **json_serializable**: JSONシリアライゼーションコードの生成
