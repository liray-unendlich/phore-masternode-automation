# phore-masternode-automation
script of masternode setup. include updating.

this script helps your masternode setup, or update.
it supports automatic setup and update.

このスクリプトはマスターノードをセットアップ・アップデートしたい方用です。
自動的なセットアップ・アップデートを行います。
やっていること
1. 各種パッケージ・アップデート
2. phored, phore-cli, phore-tx のダウンロード・インストール
3. 初期設定の場合 -> phore.confを自動で設定し、プライベートキーの入力を待機
4. 初期ではない場合 -> その時点で終了
また最後にマスターノードのプライベートキーを入力せよと言われるので、忘れずに入力してください。
