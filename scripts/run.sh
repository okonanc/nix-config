#!/bin/sh
read -p 'connect to wifi (Y/N): ' confirm 
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
	while IFS=';' read -r ssid pass
	do
		nmcli device wifi connect $ssid password $pass
		echo 'wifi connection established'
	done < ./.wifi
fi

printf 'copy secret ...'
cp secret.key /tmp

mkdir -p /key
cp secret.bin /key
echo 'done'

read -p 'run disko (Y/N): ' confirm 
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
	nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./disk-config.nix
	echo 'disko done'
fi

read -p 'generate system files (Y/N): ' confirm 
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
	nixos-generate-config --no-filesystems --root /mnt
	echo 'generate system done'
fi

read -p 'copy config files (Y/N): ' confirm 
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
	cp disk-config.nix /mnt/etc/nixos
	cp configuration.nix /mnt/etc/nixos
	echo 'copy configs done'
fi


read -p 'install (Y/N): ' confirm 
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
	nixos-install
	echo 'installation done'
fi

read -p 'reboot (Y/N): ' confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
	reboot
fi

