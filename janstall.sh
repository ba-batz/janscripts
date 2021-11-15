#!/bin/sh

printf "username: "; read -r "NAMEUSER"
printf "hostname: "; read -r "NAMEHOST"

# Set system clock
ln -sf /usr/share/zoneinfo/Europe/Vienna /etc/localtime
hwclock --systohc

# Localization
mv ./locale.gen /etc/locale.gen
locale-gen
mv ./locale.conf /etc/locale.conf

# Boot Loader
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg

# Add user(s)
passwd

useradd -m -G games,wheel,video,dbus "$NAMEUSER"
passwd "$NAMEUSER"

# Network configuration
echo "$NAMEHOST" > /etc/hostname
mv ./hosts /etc/hosts 
sed -i "s/myhostname/$NAMEHOST/g" /etc/hosts



pacman -Syu --noconfirm networkmanager networkmanager-s6
s6-rc-bundle-update -c /etc/s6/rc/compiled add default NetworkManager

# Add Repositories
pacman -S --noconfirm artix-archlinux-support

pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Change configs
mv ./pacman.conf /etc/pacman.conf
mv ./makepkg.conf /etc/makepkg.conf

# Desktop Enviroment
pacman -Syu --noconfirm xfce4 xfce4-goodies

# Other startup Services
pacman -S --noconfirm tlp tlp-s6 lightdm lightdm-s6 elogind eloging-s6 backlight-s6
s6-rc-bundle-update -c /etc/s6/compiled add default tlp
s6-rc-bundle-update -c /etc/s6/compiled add default lightdm
s6-rc-bundle-update -c /etc/s6/compiled add default elogind
s6-rc-bundle-update -c /etc/s6/compiled add default backlight

# Replace sudo with doas
pacman -Rns --noconfirm sudo
pacman -Syu --noconfirm doas
ln -sfT doas /usr/local/bin/sudo
mv ./doas.conf /etc/doas.conf

# Themeing Desktop
pacman -S --noconfirm x-arc-darker papirus-icon-theme
#pacman -S --noconfirm lightdm-gtk-greeter


# Graphics
#pacman -S --noconfirm xf86-video-intel mesa libva libva-intel-driver vulkan-intel
#mv ./20-intel.conf /etc/X11/xorg.conf.d/20-intel.conf

pacman -S --noconfirm xf86-video-amdgpu mesa libva libva-mesa-driver amdvlk
mv ./20-amdgpu.conf /etc/X11/xorg.conf.d/20-amdgpu.conf

# dash instead of bash
pacman -S --noconfirm dash dashbinsh
ln -sfT dash /usr/bin/sh

# Update microcode
#pacman -S --noconfirm intel-ucode
pacman -S --noconfirm amd-ucode

# Make updates automatic
echo "pacman -Scc --noconfirm && pacman -Syu --noconfirm &" >> /etc/xprofile

# Fonts
pacman -S --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji ttc-iosevka ttf-dejavu ttf-ms-fonts ttf-nerd-fonts-symbols ttf-roboto-mono otf-fira-sans otf-hasklig


# Minecraft
pacman -S --noconfirm gamemode gnome-keyring orca minecraft-launcher

# Prepare for manual instalation
mv ./xfce.sh /home/$NAMEUSER/ 
