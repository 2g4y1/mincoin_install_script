#add user mincoin
sudo adduser mincoin

#now give this user sudo access (more power!)
sudo usermod -aG sudo mincoin

#switch to that user:
su - mincoin
cd ~/

#now download and run the install script:
wget https://raw.githubusercontent.com/2g4y1/mincoin_install_script/master/install.sh
sudo chmod +x install.sh
sh install.sh
