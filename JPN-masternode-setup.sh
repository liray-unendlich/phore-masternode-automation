#!/bin/bash
#please do this script as root.
######################################################################
clear
echo "*********** Phore マスターノード設定スクリプトへようこそ ***********"
echo 'Ubuntu16.04に必要なパッケージをすべてインストールします。'
echo 'その後Phoreのウォレットをコンパイルし、設定、実行します。'
echo '****************************************************************************'
sleep 3
echo '*** ステップ 1/4 ***'
echo '*** パッケージのインストール ***'
sleep 2
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y nano htop git
sudo apt-get install -y software-properties-common
sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev libevent-dev
sudo apt-get install -y libboost-all-dev
sudo apt-get install -y libminiupnpc-dev
sudo apt-get install -y autoconf
sudo apt-get install -y automake
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
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
mv /usr/local/bin/phored /usr/local/bin/phore-cli /usr/local/bin/phore-tx ~/PHORE_`date '+%Y%m%d'`
mv ~/phored ~/phore-cli ~/phore-tx ~/PHORE_`date '+%Y%m%d'`
echo '***スワップファイルのセッティングを行います。***'
grep -q "swapfile" /etc/fstab
if [ $? -ne 0 ]; then
  echo 'スワップファイルが見つかりませんでした。作成を開始します。'
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap defaults 0 0' >> /etc/fstab
else
  echo 'swapfile が見つかりました。次のステップへ移行します。'
fi
echo '***phoreウォレットのビルドを開始します。***'
git clone https://github.com/phoreproject/Phore.git
cd Phore
chmod +x autogen.sh share/genbuild.sh src/leveldb/build_detect_platform
./autogen.sh
./configure --disable-dependency-tracking --enable-tests=no --without-gui --without-miniupnpc
sudo make
sudo make install
cd ..
sudo rm -r Phore
echo '*** ウォレットの起動・初期設定を行います。 ***'
sleep 2
phored -daemon
sleep 3
echo -n 'ここではrpcuser~エラーが出ますが気にしないでください。'
rpcusr=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
rpcpass=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
ipaddress=$(curl inet-ip.info)
echo -n "マスターノードプライベートキー(ステップ2の結果)を入力もしくはペーストしてください。"
read mngenkey
echo -e "rpcuser=$rpcusr \nrpcpassword=$rpcpass \nrpcallowip=127.0.0.1 \nlisten=1 \nserver=1 \ndaemon=1 \nstaking=0 \nmasternode=1 \nlogtimestamps=1 \nmaxconnections=256 \nexternalip=$ipaddress \nbind=$ipaddress \nmasternodeaddr=$ipaddress:11771 \nmasternodeprivkey=$mngenkey \n" > ~/.phore/phore.conf
echo '*** 3/4 完了 ***'
echo '*** 設定が完了しましたので、ウォレットを起動して同期を開始します。 ***'
phored -daemon
echo '1分後に getinfo コマンドの出力結果を表示します。'
sleep 60
phore-cli getinfo
sleep 2
echo '同期が完了すれば、phore-qtのウォレットからマスターノードを実行できます！'
sleep 2
echo '*** 4/4 完了 ***'
