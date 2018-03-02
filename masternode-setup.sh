#!/bin/bash
#please do this script as root.
######################################################################
#check option
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

echo "*********** Welcome to the Phore (PHR) Masternode Setup Script ***********"
echo 'This script will install all required updates & package for Ubuntu 16.04 !'
echo 'This script will install openbazaar server client.'
echo 'You can run this script on VPS only.'
echo '****************************************************************************'
sleep 1
echo '*** Installing package ***'
sleep 2
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y nano htop git wget
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

echo '***Installing Phore wallet***'
wget https://github.com/phoreproject/Phore/releases/download/v${version}/phore-${version}-x86_64-linux-gnu.tar.gz
tar -xvzf phore-${version}-x86_64-linux-gnu.tar.gz
cd phore-${version}/bin
sudo mv phore* /usr/local/bin/
cd
rm phore-${version}-x86_64-linux-gnu.tar.gz
sudo rm -r phore-${version}
if [ $update -eq 1 ]; then
  echo "Start updating..."
  phored -daemon
  phore-cli getinfo
  echo "Finish updating. Your phore-daemon is restarted."
  echo "Please check your daemon version number."
  echo "After checking, please restart masternode from phore-qt on Windows or Mac."
  echo "***End***"
elif [ $install -eq 1 ]; then
  echo '*** Start Installing... ***'
  echo '*** Configuraring masternode ***'
  sleep 1
  mkdir .phore
  rpcusr=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
  rpcpass=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
  ipaddress=$(curl inet-ip.info)
  echo "Please enter or paste masternode private key (result of masternode genkey)."
  read mngenkey

  while [ ${#mngenkey} -ne 51 ]
  do
    echo "The masternode private key you entered is invalid. please re-input."
    read mngenkey
  done
  
  echo -e "rpcuser=$rpcusr \nrpcpassword=$rpcpass \nrpcallowip=127.0.0.1 \nlisten=1 \nserver=1 \ndaemon=1 \nstaking=0 \nmasternode=1 \nlogtimestamps=1 \nmaxconnections=256 \nexternalip=$ipaddress \nbind=$ipaddress \nmasternodeaddr=$ipaddress:11771 \nmasternodeprivkey=$mngenkey \n" > ~/.phore/phore.conf
  echo '*** Start syncing... ***'
  phored -daemon
  echo 'We will show result of "phore-cli getinfo" after 20 sec.'
  sleep 20
  phore-cli getinfo
  sleep 2
  echo 'After fully syncing, you can start masternode.'
  sleep 2
else
  echo "Invalid option: For Update: use '-u', Install: use '-i'"
　echo "***End***"
fi
