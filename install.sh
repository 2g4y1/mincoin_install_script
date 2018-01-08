#+++++++++++++++++++#
#Installation of Tor#
#+++++++++++++++++++#

echo "deb http://deb.torproject.org/torproject.org xenial main" | sudo tee -a /etc/apt/sources.list
echo "deb-src http://deb.torproject.org/torproject.org xenial main" | sudo tee -a /etc/apt/sources.list
gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
apt update
sudo apt install tor deb.torproject.org-keyring -y

#Autostart Tor and config
sudo sed -i 's/#RunAsDaemon/RunAsDaemon/g' /etc/tor/torrc
echo "HiddenServiceDir /var/lib/tor/hidden_service/" | sudo tee -a /etc/tor/torrc
echo "HiddenServicePort 9334 127.0.0.1:9334" | sudo tee -a /etc/tor/torrc
systemctl restart tor

#+++++++++++++++++++#
#Installation of MNC#
#+++++++++++++++++++#

wget "https://github.com/mincoin/mincoin/releases/download/v0.8.8.0/mincoin-0.8.8.0-linux.tar.gz"
tar xf mincoin-0.8.8.0-linux.tar.gz
mincoin-0.8.8.0-linux/bin/64/mincoind



########
#Now copy the username and the password and copy to /root/.mincoin/mincoin.conf
########

nano /root/.mincoin/mincoin.conf

########
#Paste your clipboard by rightclick in putty
########


wget "https://github.com/mincoin/mincoin/releases/download/v0.8.8.0/Mincoin-1553460-bootstrap.dat"
mv Mincoin-1553460-bootstrap.dat /root/.mincoin/bootstrap.dat


########
#Use the next command to determite your onion address and write it to 
# /root/.mincoin/mincoin.conf as externalip=output from nextcommand
########

cat /var/lib/tor/hidden_service/hostname
nano /root/.mincoin/mincoin.conf #add line with externalip=output from above

echo "timeout=750" | sudo tee -a /root/.mincoin/mincoin.conf
echo "tor=127.0.0.1:9050" | sudo tee -a /root/.mincoin/mincoin.conf
echo "discover=1" | sudo tee -a /root/.mincoin/mincoin.conf
echo "upnp=1" | sudo tee -a /root/.mincoin/mincoin.conf
echo "txindex=1" | sudo tee -a /root/.mincoin/mincoin.conf
echo "daemon=1" | sudo tee -a /root/.mincoin/mincoin.conf
echo "listen=1" | sudo tee -a /root/.mincoin/mincoin.conf

mincoin-0.8.8.0-linux/bin/64/mincoind -reindex
#Now you need to wait...
