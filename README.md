# mincoin_install_script


use this script to setup mincoin un linux :)


#add user mincoin
adduser mincoin

#now give this user sudo access (more power!)
usermod -aG sudo mincoin

#switch to that user:
su - mincoin
cd ~/

#now download and run the install script:
wget https://raw.githubusercontent.com/2g4y1/mincoin_install_script/master/install.sh
sudo chmod +x saga_install.sh
sh saga_install.sh
