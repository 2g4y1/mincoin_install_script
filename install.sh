#!/bin/bash

FILE_NAME="https://github.com/mincoin/mincoin/releases/download/v0.8.8.0/mincoin-0.8.8.0-linux.tar.gz"
bootstrap="https://github.com/mincoin/mincoin/releases/download/v0.8.8.0/Mincoin-1615424-bootstrap.dat"

echo "=================================================================="
echo "Tor Install"
echo "=================================================================="
echo "deb http://deb.torproject.org/torproject.org xenial main" | sudo tee -a /etc/apt/sources.list
echo "deb-src http://deb.torproject.org/torproject.org xenial main" | sudo tee -a /etc/apt/sources.list
gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
sudo apt update
sudo apt install tor deb.torproject.org-keyring -y

echo "Configure Tor and enable autostart..."
sudo sed -i 's/#RunAsDaemon/RunAsDaemon/g' /etc/tor/torrc
echo "HiddenServiceDir /var/lib/tor/hidden_service/" | sudo tee -a /etc/tor/torrc
echo "HiddenServicePort 9334 127.0.0.1:9334" | sudo tee -a /etc/tor/torrc
sudo systemctl restart tor
echo "Tor successfully installed."
sleep 5
sudo chown -R mincoin /var/lib/tor
address=$(cat /var/lib/tor/hidden_service/hostname)


echo "=================================================================="
echo "MinCoin Install"
echo "=================================================================="
echo "Installing, this will take appx 2 min to run..."

echo -n "Installing pwgen..."
sudo apt-get install pwgen 

PASSWORD=$(pwgen -s 64 1)
USER=$(pwgen -s 64 1)

echo -n "Installing with RPC User: $USER - RPC PASS: $PASSWORD - Onion Address: $address..."
sleep 7
#begin optional swap section
echo "Setting up disk swap..."
sleep 1
free -h 
sudo fallocate -l 4G /swapfile 
ls -lh /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab sudo bash -c "
echo 'vm.swappiness = 10' >> /etc/sysctl.conf"
free -h
echo "SWAP setup complete..."
sleep 1
#end optional swap section

echo "Installing packages and updates..."
sudo apt-get update -y
sudo apt-get upgrade -y
#sudo apt-get dist-upgrade -y
sudo apt-get install build-essential libssl-dev libdb++-dev libboost-all-dev libqrencode-dev -y

echo "Downloading MinCoin wallet..."
wget $FILE_NAME
tar -zxvf mincoin-0.8.8.0-linux.tar.gz
mv mincoin-0.8.8.0-linux mincoin
chmod +x mincoin/bin/64/mincoind
sudo cp mincoin/bin/64/mincoind /usr/local/bin

echo "INITIAL START: IGNORE ANY CONFIG ERROR MSGs..." 
mincoind

echo "Loading wallet, be patient, wait..." 
sleep 30
mincoind getmininginfo
mincoind stop

echo "creating config..." 
sleep 1
cat <<EOF > ~/.mincoin/mincoin.conf
rpcuser=$USER
rpcpassword=$PASSWORD
externalip=$address
timeout=750
tor=127.0.0.1:9050
discover=1
upnp=1
txindex=1
listen=1
addnode=mincoinus7355vly.onion:9334
addnode=fkhwktieszixa2d2.onion:9334
addnode=cyixu5mrodmjbkpr.onion:9334
addnode=jv2b2fijqdcnxfhg.onion:9334
addnode=119.9.108.125:9334
addnode=104.130.211.223:9334
addnode=103.233.194.91:45258
addnode=45.76.131.172:44218
addnode=54.39.20.116:42100
addnode=68.96.198.176:43844
addnode=172.126.77.172:47086
addnode=144.217.166.96:37604
addnode=74.208.166.158:43216
addnode=78.129.218.88:49700
addnode=139.162.128.92:36606
addnode=80.208.231.152:48340
addnode=213.32.6.132:32968
addnode=66.70.180.59:46374
addnode=174.4.199.52:36474
EOF

echo "setting basic security..."
sudo apt-get install fail2ban -y
sudo apt-get install -y ufw
sudo apt-get update -y

#add a firewall & fail2ban
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow 9334/tcp
sudo ufw allow 9050/tcp
sudo ufw logging off #to avoid to much logs
sudo ufw status
echo "Confirm 'y' to enable firewall"
sudo ufw enable

#fail2ban:
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
echo "basic security completed..."

echo "Downloading bootstrap.dat and reindexing..."
echo "Please be patient"
wget $bootstrap -O ~/.mincoin/bootstrap.dat
mincoind -reindex


echo "Mincoin succesfully installedYour mincoin.conf:"
cat ~/.mincoin/mincoin.conf
