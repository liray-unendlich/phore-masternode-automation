#!/bin/bash
#please do this script as root.
######################################################################
#Check option
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
    echo "Error: Invalid option: $1" > $2
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
echo "*********** Welcome to the Phore (PHR) Masternode Setup Script ***********"
echo 'This script will install all required updates & package for Ubuntu 16.04 !'
echo 'This script will install phore masternode.'
echo 'You can run this script on VPS only.'
echo '****************************************************************************'
echo '*** Installing package ***'
apt-get update -qqy
apt-get upgrade -qqy
apt-get dist-upgrade -qqy
apt-get install -qqy nano htop git wget
echo '*** Step 2/4 ***'
echo '*** Configuring firewall ***'
apt-get install -qqy ufw
ufw allow ssh/tcp >> mn.log
ufw limit ssh/tcp >> mn.log
ufw allow 11771/tcp >> mn.log
ufw logging on >> mn.log
ufw --force enable >> mn.log
ufw status >> mn.log
phore-cli stop &>> mn.log
./phore-cli stop &>> mn.log
echo '*** Step 3/4 ***'
if [ -e /usr/local/bin/phored -o -e phored ]; then
  echo '***Backup your existing phored. If you want to restore, please check PHORE_DATE ***'
  mkdir PHORE_`date '+%Y%m%d'` >> mn.log
  mv /usr/local/bin/phored /usr/local/bin/phore-cli /usr/local/bin/phore-tx ~/PHORE_`date '+%Y%m%d'` &>> mn.log
  mv ~/phored ~/phore-cli ~/phore-tx ~/PHORE_`date '+%Y%m%d'` &>> mn.log
fi
echo '*** Step 4/4 ***'
echo '***Installing phore wallet daemon***'
wget -nv https://github.com/phoreproject/Phore/releases/download/v${version}/phore-${version}-x86_64-linux-gnu.tar.gz >> mn.log
tar -xvzf phore-${version}-x86_64-linux-gnu.tar.gz >> mn.log
cd phore-${version}/bin
mv phore* /usr/local/bin/
cd
rm phore-${version}-x86_64-linux-gnu.tar.gz 
rm -r phore-${version}
if [ $update -eq 1 ]; then
  echo "Updating"
  phored -daemon
  phore-cli getinfo
  echo "Finish Updating"
  echo "Check version data."
  echo "After checking, please restart Phore masternode from phore-qt"
  echo "***End***"
elif [ $install -eq 1 ]; then
  echo '*** Install and configuring masternode settings ***'
  mkdir .phore
  rpcusr=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
  rpcpass=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
  ipaddress=$(curl -s inet-ip.info)
  if [ $generate -eq 1 ]; then
    generate_privkey
  else
    echo "Enter or paste masternode private key"
    read mngenkey
    while [ ${#mngenkey} -ne 51 ]
    do
      echo "Invalid masternode private key. please reinput."
      read mngenkey
    done
  fi
  echo -e "rpcuser=$rpcusr\nrpcpassword=$rpcpass\nrpcallowip=127.0.0.1\nlisten=1\nserver=1\ndaemon=1\nstaking=0\nmasternode=1\nlogtimestamps=1\nmaxconnections=256\nexternalip=$ipaddress\nbind=$ipaddress\nmasternodeaddr=$ipaddress:11771\nmasternodeprivkey=$mngenkey\n" > ~/.phore/phore.conf
  echo '*** Start syncing ***'
  phored -daemon &>> mn.log
  echo 'After 10sec, I will show you the outputs of getinfo'
  sleep 10
  phore-cli getinfo
  echo 'After fully syncing, you can start phore masternode.'
  echo 'There is example line for masternode.conf. Please copy this line and paste to your masternode.conf'
  echo " "
  create_mnconf
  echo " "
  echo 'You can check the line by entering  **cat tmp_masternode.conf** '
else
  echo "Invalid command, or argument. If you want to update, use '-u', to install, use '-i'."
　echo "**END**"
fi
