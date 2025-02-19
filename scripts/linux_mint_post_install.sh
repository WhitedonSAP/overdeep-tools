#!/bin/bash

clear

## grub theme

# create custom grub file
#sudo touch /etc/default/grub.d/90_custom.cfg
#sudo echo -e 'GRUB_TIMEOUT="10"\nGRUB_TIMEOUT_STYLE="menu"' >> /etc/default/grub.d/90_custom.cfg

echo
# update grub config file
sudo update-grub

# pre-check if efi is available
if [[ "$(ls /sys/firmware/efi/efivars > /dev/null 2>&1; echo $?)" -eq '0' ]]
then
  boot_mode='uefi'
fi

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
sudo sed -i 's,/.snapshots,--timeshift-auto,' /lib/systemd/system/grub-btrfsd.service

# enable grub-btrfsd.service
sudo systemctl enable grub-btrfsd

# download timeshift-autosnap-apt
git clone https://github.com/wmutschl/timeshift-autosnap-apt.git
cd timeshift-autosnap-apt
sudo make install
# cleaning
cd ..
rm -rf timeshift-autosnap-apt
# config
read -p "This system is using a dedicated /boot partition? [Y/n]" bootpartask
if [ "$bootpartask" = 'N' ] || [ "$bootpartask" = 'n' ]
then
    sudo sed -i 's,snapshotBoot=true,snapshotBoot=false,' /etc/timeshift-autosnap-apt.conf
fi
echo
if [ "$boot_mode" != 'uefi' ]
then
    sudo sed -i 's,snapshotEFI=true,snapshotEFI=false,' /etc/timeshift-autosnap-apt.conf
fi

echo
echo "All Ok, Linux Mint configured with success"
