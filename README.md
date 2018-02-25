# mincoin_install_script


#use this script to setup mincoin un linux :)
#Copy paste one command at once

#add user mincoin

sudo adduser mincoin #set password and press enter for some times


#now give this user sudo access (more power!)

sudo usermod -aG sudo mincoin


#switch to that user:

su - mincoin


#now download and run the install script:

wget https://raw.githubusercontent.com/2g4y1/mincoin_install_script/master/install.sh

sudo chmod +x install.sh

sh install.sh


#Wait until the script finishes

sudo cat /var/lib/tor/hidden_service/hostname

#write the output to .mincoin/mincoin.conf as externalip=sdnfgasjdgnfagjadfng.onion

mincoind -reindex
