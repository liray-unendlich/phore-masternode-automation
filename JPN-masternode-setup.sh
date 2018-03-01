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
    -*)
    echo "エラー: 不明なオプションを入力しています: $1" > $2
    exit 1
    ;;
    *)
    break
    ;;
  esac
done

echo "*********** Phore マスターノード設定スクリプトへようこそ ***********"
echo 'Ubuntu16.04に必要なパッケージをすべてインストールします。'
echo 'その後Phoreのウォレットをコンパイルし、設定、実行します。'
echo '****************************************************************************'
sleep 1
echo '*** パッケージのインストール ***'
sleep 2
apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get install -y nano htop wget
sleep 1
echo '*** 完了 1/4 ***'
sleep 1
echo '*** ステップ 2/4 ***'
echo '*** ファイアウォールの設定・スタートを行います。 ***'
sudo apt-get install -y ufw
sudo ufw allow ssh/tcp
sudo limit ssh/tcp
sudo ufw allow 11771/tcp
sudo ufw logging on
sudo ufw --force enable
sudo ufw status
sleep 1
echo '*** 2/4 完了 ***'
sleep 1
echo '*** ステップ 3/4 ***'
echo '***ウォレットのバックアップを取ります。必要な場合はホーム直下のPHORE_日付 ***'
echo '***という名前のディレクトリにアクセスしてください。***'
phore-cli stop
./phore-cli stop
mkdir PHORE_`date '+%Y%m%d'`
sudo mv /usr/local/bin/phored /usr/local/bin/phore-cli /usr/local/bin/phore-tx ~/PHORE_`date '+%Y%m%d'`
sudo mv ~/phored ~/phore-cli ~/phore-tx ~/PHORE_`date '+%Y%m%d'`
echo '***phoreウォレットのインストールを開始します。***'
wget https://github.com/phoreproject/Phore/releases/download/v${version}/phore-${version}-x86_64-linux-gnu.tar.gz
tar -xvzf phore-${version}-x86_64-linux-gnu.tar.gz
cd phore-${version}/bin
sudo mv phore* /usr/local/bin/
cd
rm phore-${version}-x86_64-linux-gnu.tar.gz
sudo rm -r phore-${version}
if [ $update -eq 1 ]; then
  echo "アップデートを行います。"
  phored -daemon
  phore-cli getinfo
  echo "アップデートは完了しました。"
  echo "バージョンデータが新しくなっているかご確認ください。"
  echo "ご確認後、マスターノードをコントロールウォレットであるphore-qtから再始動させるのをお忘れなく。"
  echo "***終了***"
elif [ $install -eq 1 ]; then
  echo '*** インストールとしてウォレットの起動・初期設定を行います。 ***'
  sleep 1
  mkdir .phore
  rpcusr=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
  rpcpass=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
  ipaddress=$(curl inet-ip.info)
  echo -n "マスターノードプライベートキー(ステップ2の結果)を入力もしくはペーストしてください。"
  echo "***"
  read mngenkey
  echo -e "rpcuser=$rpcusr \nrpcpassword=$rpcpass \nrpcallowip=127.0.0.1 \nlisten=1 \nserver=1 \ndaemon=1 \nstaking=0 \nmasternode=1 \nlogtimestamps=1 \nmaxconnections=256 \nexternalip=$ipaddress \nbind=$ipaddress \nmasternodeaddr=$ipaddress:11771 \nmasternodeprivkey=$mngenkey \n" > ~/.phore/phore.conf
  echo '*** 設定が完了しましたので、ウォレットを起動して同期を開始します。 ***'
  phored -daemon
  echo '20秒後に getinfo コマンドの出力結果を表示します。'
  sleep 20
  phore-cli getinfo
  sleep 2
  echo '同期が完了すれば、phore-qtのウォレットからマスターノードを実行できます！'
  sleep 2
else
  echo "入力が間違っているようです。アップデートの場合: '-u', 新規インストールの場合: '-i'をオプションとしてください。"
　echo "終了します。"
fi
