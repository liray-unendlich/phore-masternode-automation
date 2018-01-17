#!/bin/bash
#please do this script as root.
######################################################################

clear
echo "*********** Welcome to the Phore (PHR) Masternode Setup Script ***********"
echo 'This script will install all required updates & package for Ubuntu 16.04 !'
echo 'This script will install openbazaar server client.'
echo 'You can run this script on VPS only.'
echo '****************************************************************************'
sleep 3
echo '*** Step 1/4 ***'
echo '*** Installing package ***'
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
echo '*** Done 1/4 ***'
sleep 1
echo '*** Step 2/4 ***'
echo '*** Starting & Configuring firewall ***'
sudo apt-get install -y ufw
sudo ufw allow ssh/tcp
sudo limit ssh/tcp
sudo ufw allow 11771/tcp
sudo ufw logging on
sudo ufw --force enable
sudo ufw status
sleep 1
echo '*** Done 2/4 ***'
sleep 1
echo '***step 3/4***'
echo '*** Stopping & Backup existing wallet to PHORE_date ***'
phore-cli stop
./phore-cli stop
mkdir PHORE_`date '+%Y%m%d'`
mv /usr/local/bin/phored /usr/local/bin/phore-cli /usr/local/bin/phore-tx ~/PHORE_`date '+%Y%m%d'`
mv ~/phored ~/phore-cli ~/phore-tx ~/PHORE_`date '+%Y%m%d'`
echo 'Setup swap file'
grep -q "swapfile" /etc/fstab
if [ $? -ne 0 ]; then
  echo 'cannot find swap file. Making it now...'
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap defaults 0 0' >> /etc/fstab
else
  echo 'find swap file. skipping this step.'
fi
echo '***Building Phore wallet***'
git clone https://github.com/phoreproject/Phore.git
cd Phore
chmod +x autogen.sh share/genbuild.sh src/leveldb/build_detect_platform
./autogen.sh
./configure --disable-dependency-tracking --enable-tests=no --without-gui --without-miniupnpc
sudo make
sudo make install
cd ..
sudo rm -r Phore
echo '*** Starting & configuring the wallet ***'
sleep 2
./phored -daemon
sleep 3
echo -n 'Dont worry about rpcuser~ errors.'
rpcusr=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
rpcpass=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
ipaddress=$(curl inet-ip.info)
echo -n "Please enter of paste masternode private key (result of masternode genkey)."
read mngenkey

echo -e "rpcuser=$rpcusr \nrpcpassword=$rpcpass \nrpcallowip=127.0.0.1 \nlisten=1 \nserver=1 \ndaemon=1 \nstaking=0 \nmasternode=1 \nlogtimestamps=1 \nmaxconnections=256 \nexternalip=$ipaddress \nbind=$ipaddress \nmasternodeaddr=$ipaddress:11771 \nmasternodeprivkey=$mngenkey \n" > ~/.phore/phore.conf

echo '*** Done 3/4 ***'
echo '*** Start syncing... ***'
./phored -daemon
echo 'Please wait for a minute. it will show you result of phore-cli getinfo'
sleep 60
./phore-cli getinfo
sleep 2
echo 'wait for syncing. after full syncing, you can start masternode on phore-qt on local.'
sleep 2
echo '*** Done 4/4 ***'