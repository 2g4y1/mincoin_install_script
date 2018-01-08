#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#+++++++++++++++++++#
#Installation of Tor#
#+++++++++++++++++++#

echo "deb http://deb.torproject.org/torproject.org xenial main" | sudo tee -a /etc/apt/sources.list
echo "deb-src http://deb.torproject.org/torproject.org xenial main" | sudo tee -a /etc/apt/sources.list
gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
apt update
apt install tor deb.torproject.org-keyring -y

#Autostart Tor
sed -i 's/#RunAsDaemon/RunAsDaemon/g' /etc/tor/torrc
echo "HiddenServiceDir /var/lib/tor/hidden_service/" | sudo tee -a /etc/tor/torrc
echo "HiddenServicePort 9334 127.0.0.1:9334" | sudo tee -a /etc/tor/torrc
systemctl restart tor

#+++++++++++++++++++#
#Installation of MNC#
#+++++++++++++++++++#

wget "https://github.com/mincoin/mincoin/releases/download/v0.8.8.0/mincoin-0.8.8.0-linux.tar.gz"
tar xf mincoin-0.8.8.0-linux.tar.gz

touch /root/.mincoin/mincoin.conf
PASSWORD=$(head -c 32  /dev/random | md5sum | cut -f 1 -d\ )
USER=$(head -c 16  /dev/random | md5sum | cut -f 1 -d\ )

echo "rpcuser=1234" | sudo tee -a /root/.mincoin/mincoin.conf
echo "rpcpassword=5678" | sudo tee -a /root/.mincoin/mincoin.conf
sed -i "s/1234/$USER/g" /root/.mincoin/mincoin.conf
sed -i "s/4567/$PASSWORD/g" /root/.mincoin/mincoin.conf
mincoin-0.8.8.0-linux/bin/64/mincoind
systemctl stop mincoind
wget "https://github.com/mincoin/mincoin/releases/download/v0.8.8.0/Mincoin-1553460-bootstrap.dat"
mv Mincoin-1553460-bootstrap.dat /root/.mincoin/bootstrap.dat


external="`cat /var/lib/tor/hidden_service/hostname`"
external="externalip=$external
echo "timeout=750" | sudo tee -a /root/.mincoin/mincoin.conf
echo $external | sudo tee -a /root/.mincoin/mincoin.conf
echo "tor=127.0.0.1:9050" | sudo tee -a /root/.mincoin/mincoin.conf
echo "discover=1" | sudo tee -a /root/.mincoin/mincoin.conf
echo "upnp=1" | sudo tee -a /root/.mincoin/mincoin.conf
echo "txindex=1" | sudo tee -a /root/.mincoin/mincoin.conf


#Autostart Mincoin
echo "/root/mincoin-0.8.8.0-linux/bin/64/mincoind -daemon" | sudo tee -a /etc/rc.local
