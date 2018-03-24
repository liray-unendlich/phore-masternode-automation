#!/bin/bash
#please do this script as root.
######################################################################
#オプションの判定処理
while :
do
  case "$1" in
    -v | --version)
    version="$2" #get version data
    shift 2
    ;;
    -u | --update)
    install=0
    update=1
    shift
    ;;
    -i | --install)
    install=1
    update=0
    shift
    ;;
    -g | --generate)
    generate=1
    shift
    ;;
    -*)
    echo "エラー: 不明なオプションを入力しています: $1" > $2
    exit 1
    ;;
    *)
    break
    ;;
  esac
done

# Generate masternode private key
function generate_privkey() {
  mkdir -p /etc/masternodes/
  echo -e "rpcuser=test\nrpcpassword=passtest" >> /etc/masternodes/phore_test.conf 
  phored -daemon -conf=/etc/masternodes/phore_test.conf -datadir=/etc/masternodes >> mn.log
  sleep 5
  mngenkey=$(phore-cli -conf=/etc/masternodes/phore_test.conf -datadir=/etc/masternodes masternode genkey)
  phore-cli -conf=/etc/masternodes/phore_test.conf -datadir=/etc/masternodes stop >> mn.log
  sleep 5
  rm -r /etc/masternodes/
}
 
# Make masternode.conf for ppl
function create_mnconf() {
  echo phore-MN01 $ipaddress:11771 $mngenkey TRANSACTION_ID TRANSACTION_INDEX >> tmp_masternode.conf
  cat tmp_masternode.conf
}  
echo " "
echo " "
echo "*********** Phore マスターノード設定スクリプトへようこそ ***********"
echo 'Ubuntu16.04に必要なパッケージをすべてインストールします。'
echo 'その後Phoreのウォレットをコンパイルし、設定、実行します。'
echo '****************************************************************************'
echo '*** パッケージのインストール ***'
apt-get update -qqy
apt-get upgrade -qqy
apt-get dist-upgrade -qqy
apt-get install -qqy nano htop git wget
echo '*** ステップ 2/4 ***'
echo '*** ファイアウォールの設定・スタートを行います。 ***'
apt-get install -qqy ufw
ufw allow ssh/tcp >> mn.log
ufw limit ssh/tcp >> mn.log
ufw allow 11771/tcp >> mn.log
ufw logging on >> mn.log
ufw --force enable >> mn.log
ufw status >> mn.log
phore-cli stop &>> mn.log
./phore-cli stop &>> mn.log
echo '*** ステップ 3/4 ***'
if [ -e /usr/local/bin/phored -o -e phored ]; then
  echo '***ウォレットのバックアップを取ります。必要な場合はホーム直下のPHORE_日付 ***'
  echo '***という名前のディレクトリにアクセスしてください。***'
  mkdir PHORE_`date '+%Y%m%d'` >> mn.log
  mv /usr/local/bin/phored /usr/local/bin/phore-cli /usr/local/bin/phore-tx ~/PHORE_`date '+%Y%m%d'` &>> mn.log
  mv ~/phored ~/phore-cli ~/phore-tx ~/PHORE_`date '+%Y%m%d'` &>> mn.log
fi
echo '*** ステップ 4/4 ***'
echo '***phoreウォレットのインストールを開始します。***'
wget -nv https://github.com/phoreproject/Phore/releases/download/v${version}/phore-${version}-x86_64-linux-gnu.tar.gz >> mn.log
tar -xvzf phore-${version}-x86_64-linux-gnu.tar.gz >> mn.log
cd phore-${version}/bin
mv phore* /usr/local/bin/
cd
rm phore-${version}-x86_64-linux-gnu.tar.gz 
rm -r phore-${version}
if [ $update -eq 1 ]; then
  echo "アップデートを行います。"
  phored -daemon
  phore-cli getinfo
  echo "アップデートは完了しました。"
  echo "バージョンデータが新しくなっているかご確認ください。"
  echo "ご確認後、マスターノードをphore-qtから再起動させるのをお忘れなきようお願いいたします。"
  echo "***終了***"
elif [ $install -eq 1 ]; then
  echo '*** インストールとしてウォレットの起動・初期設定を行います。 ***'
  mkdir .phore
  rpcusr=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
  rpcpass=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
  ipaddress=$(curl -s inet-ip.info)
  if [ $generate -eq 1 ]; then
    generate_privkey
  else
    echo "マスターノードプライベートキー(ステップ2の結果)を入力もしくはペーストしてください。"
    read mngenkey
    while [ ${#mngenkey} -ne 51 ]
    do
      echo "入力されたプライベートキーは正しくありません。もう一度確認してください。"
      read mngenkey
    done
  fi
  echo -e "rpcuser=$rpcusr\nrpcpassword=$rpcpass\nrpcallowip=127.0.0.1\nlisten=1\nserver=1\ndaemon=1\nstaking=0\nmasternode=1\nlogtimestamps=1\nmaxconnections=256\nexternalip=$ipaddress\nbind=$ipaddress\nmasternodeaddr=$ipaddress:11771\nmasternodeprivkey=$mngenkey\n" > ~/.phore/phore.conf
  echo '*** 設定が完了しましたので、ウォレットを起動して同期を開始します。 ***'
  phored -daemon &>> mn.log
  echo '10秒後に getinfo コマンドの出力結果を表示します。'
  sleep 10
  phore-cli getinfo
  echo '同期が完了すれば、phore-qtのウォレットからマスターノードを実行できます！'
  echo '最後に、masternode.conf の例をお見せします。こちらをご利用ください。'
  echo " "
  create_mnconf
  echo " "
  echo 'コマンド cat tmp_masternode.conf を入力することで再度表示可能です。'
else
  echo "入力が間違っているようです。アップデートの場合: '-u', 新規インストールの場合: '-i'をオプションとしてください。"
　echo "終了します。"
fi
