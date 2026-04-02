---
name: init
description: This skill should be used when the user asks to "initialize core-nexus", "set up core-nexus", "select language for core-nexus", "configure core-nexus plugin", or runs "/core-nexus:init".
---

## 前提

- Core Nexus プラグインのインストール直後に1回実行する
- 再実行すると既存スキルを上書きする

## 手順

1. `bash skills/init/scripts/init.sh` を実行する
2. 言語選択メニューが表示される。ユーザーに番号で選択してもらう:
   - `1` ja - 日本語
   - `2` en - English
   - `3` es - Español
   - `4` other → `/core-nexus:translate` を案内
3. インストール完了メッセージを確認する
4. `/reload-plugins` を実行してスキルを有効化する
5. `ls skills/` でインストールされたスキル一覧を表示し、ユーザーに報告する

## エラー時

- 言語ディレクトリが見つからない場合: `available/` 配下に対象言語フォルダが存在するか確認する
- スキルが0件の場合: 言語フォルダ内にスキルディレクトリが配置されているか確認する
