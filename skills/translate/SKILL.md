---
name: translate
description: This skill should be used when the user asks to "translate skills to another language", "add a new language to core-nexus", "create skills in my language", or "localize core-nexus skills".
---

## 概要

`available/` 配下の既存言語スキルを基に、新しい言語版を生成する。

## 手順

1. `ls available/` で既存の言語ディレクトリを確認する
2. ユーザーにソース言語（翻訳元）とターゲット言語（翻訳先）を確認する
3. ソース言語のスキルを順番に読み、ターゲット言語に翻訳する:
   - SKILL.md の `description` は英語のまま維持する（トリガー精度のため）
   - SKILL.md の body 部分を翻訳する
   - スキル名（ディレクトリ名）は変更しない
4. `available/{target_lang}/` に翻訳したスキルを配置する
5. `optional/` ディレクトリがソース言語にある場合、同様に翻訳する
6. 完了後、翻訳したスキル一覧を報告する
7. `/core-nexus:init` の実行を案内する

## 注意事項

- description は英語で記述する（Claude のスキル検出は英語 description が最も精度が高い）
- 技術用語（コマンド名、パス、ツール名）は翻訳しない
- 既存の翻訳がある場合は上書き前にユーザーに確認する
