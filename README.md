# phore-masternode-automation
script of masternode setup. include updating.

this script helps your masternode setup, or update.
it supports automatic setup and update.

このスクリプトはマスターノードをセットアップ・アップデートしたい方用です。
自動的なセットアップ・アップデートを行います。
## やっていること
1. 各種パッケージ・アップデート
2. phored, phore-cli, phore-tx のダウンロード・インストール
3. 新規インストールの場合プライベートキーを入力する必要があります。
## 使い方
### アップデート
```
wget https://raw.githubusercontent.com/liray-unendlich/phore-masternode-automation/master/JPN-masternode-setup.sh
sudo sh JPN-masternode-setup.sh -v 1.2.2 -u
```
### インストール
```
wget https://raw.githubusercontent.com/liray-unendlich/phore-masternode-automation/master/JPN-masternode-setup.sh
sudo sh JPN-masternode-setup.sh -v 1.2.2 -i -g
```

この場合すでにphore.confにはプライベートキーなどの必要情報が全て入力されているので、後はmasternode.confを入力するだけでマスターノードを作ることが出来ます。
スクリプトの最後に、masternode.confに入力する行が出ますので、コピーして入力後、トランザクションID, indexを編集しましょう。

### オプション説明
- -v | --version : バージョンを指定します。 ex. -v 1.2.2
- -u | --update : クライアントのアップデート ex. -u
- -i | --install : クライアントの新規インストール ex. -i
- -g | --generate : プライベートキーの発行 ex. -g
マスターノードを新規にインストールされる場合は -i オプションを
既存のマスターノードをアップデートする場合は -u オプションをご利用ください。
