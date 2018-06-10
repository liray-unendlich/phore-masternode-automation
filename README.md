# phore-masternode-automation
script of masternode setup. include updating.

this script helps your masternode setup, or update.
it supports automatic setup and update.


[![tipsensu] (https://img.shields.io/badge/TipMe-Phore%20via%20LINE-green.svg)](https://line.me/R/oaMessage/@utx6777n/?./withdraw%20phr%200.1%20PW7DqjKXaaVeFRegsfZq5GC5j73G3Ct3kf)

[![tipsensuで投げる](https://img.shields.io/badge/TipMe-Phore%20via%20Twitter-blue.svg)](https://twitter.com/intent/tweet?text=%40tipsensu%20tip%20phr%20%40PhoreJapan%201)

## In English

## What the script do?
1. Install package and configure firewall
2. Install phored, phore-cli, phore-tx
3. generate private key and run daemon

## How To Use
### Update
```
curl -s https://raw.githubusercontent.com/liray-unendlich/phore-masternode-automation/master/masternode-setup.sh | bash -s -- -u -v 1.2.2
```
### Install
```
curl -s https://raw.githubusercontent.com/liray-unendlich/phore-masternode-automation/master/masternode-setup.sh | bash -s -- -i -g -v 1.2.2
```

After the script, you will see a line like this
```
PhoreMN1 192.22.111.192:11771 88xrxxxxxxxxxxxxxxxxxxxxxxx7K 6b4c9xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx7ee23 0
```

### Option
- -v | --version : set version
- -u | --update : update your client
- -i | --install : install client
- -g | --generate : generate private key in the script


## In Japanese
このスクリプトはマスターノードをセットアップ・アップデートしたい方用です。
自動的なセットアップ・アップデートを行います。
詳細なガイドは Phore_Masternode_guide_v1.5_JP.pdf をご覧ください。
## やっていること
1. 各種パッケージ・アップデート
2. phored, phore-cli, phore-tx のダウンロード・インストール
3. 新規インストールの場合プライベートキーを入力する必要があります。
## 使い方
### アップデート
```
curl -s https://raw.githubusercontent.com/liray-unendlich/phore-masternode-automation/master/JPN-masternode-setup.sh | bash -s -- -u -v 1.2.2
```
### インストール
```
curl -s https://raw.githubusercontent.com/liray-unendlich/phore-masternode-automation/master/JPN-masternode-setup.sh | bash -s -- -i -g -v 1.2.2
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
