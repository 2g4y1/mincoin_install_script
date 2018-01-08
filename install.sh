#!/bin/bash


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
mincoin-0.8.8.0-linux/bin/64/mincoind


PASSWORD=$(head -c 16  /dev/random | md5sum | cut -f 1 -d\ )
USER=$(head -c 16  /dev/random | md5sum | cut -f 1 -d\ )

"rpcuser=1234" > /root/.mincoin/mincoin.conf
"rpcpassword=5678" > /root/.mincoin/mincoin.conf
sed -i "s/#1234/$USER/g" /root/.mincoin/mincoin.conf
sed -i "s/#4567/$PASSWORD/g" /root/.mincoin/mincoin.conf

systemctl stop mincoind
wget "https://github.com/mincoin/mincoin/releases/download/v0.8.8.0/Mincoin-1553460-bootstrap.dat"
mv Mincoin-1553460-bootstrap.dat /root/.mincoin/bootstrap.dat


external="`cat /var/lib/tor/hidden_service/hostname`"
external="externalip=$external
$external > /root/.mincoin/mincoin.conf
"timeout=750" > /root/.mincoin/mincoin.conf
"tor=127.0.0.1:9050" > /root/.mincoin/mincoin.conf
"discover=1" > /root/.mincoin/mincoin.conf
"upnp=1" > /root/.mincoin/mincoin.conf
"txindex=1" > /root/.mincoin/mincoin.conf

#Autostart Mincoin
echo "/root/mincoin-0.8.8.0-linux/bin/64/mincoind -daemon" | sudo tee -a /etc/rc.local
