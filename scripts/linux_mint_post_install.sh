#!/bin/bash

clear

## grub theme

# create custom grub file
sudo touch /etc/default/grub.d/90_custom.cfg
sudo echo -e 'GRUB_TIMEOUT="10"\nGRUB_TIMEOUT_STYLE="menu"' >> /etc/default/grub.d/90_custom.cfg

echo
# update grub config file
sudo update-grub

echo
# install linux mint grub theme
read -p "This pc/notebook is using an HiDPI screen? [Y/n]" hidpiask
echo
if [ "$hidpiask" = 'Y' ] || [ "$hidpiask" = 'y' ]
then
    apt -y install --reinstall -o Dpkg::Options::="--force-confmiss" grub2-theme-mint-2k
elif [ "$hidpiask" = 'N' ] || [ "$hidpiask" = 'n' ]
then
    apt -y install --reinstall -o Dpkg::Options::="--force-confmiss" grub2-theme-mint
fi

## grub-btrfs

echo
# install deps
sudo apt -y install build-essential git inotify-tools

echo
# download and install grub-btrfs
git clone https://github.com/Antynea/grub-btrfs.git
cd grub-btrfs
sudo make install
# cleaning
cd ..
rm -rf grub-btrfs

echo
# regenerate grub config file (again)
sudo update-grub

# set up grub-btrfsd.service
sudo sed -i 's,/.snapshots,--timeshift-auto,' /etc/systemd/system/grub-btrfsd.service

# enable grub-btrfsd.service
sudo systemctl enable grub-btrfsd

echo
echo "All Ok, Linux Mint configured with success"
