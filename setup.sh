#!/bin/bash

## quit on error
set -e

TO_INSTALL="
apt-transport-https
ca-certificates
gnupg
curl
git
vlc
kazam
build-essential
gnome-tweaks
audacity
mediainfo-gui
ffmpeg
ssh
python3-pip"


TO_REMOVE="
thunderbird
rhythmbox"




RESET_ALL="\e[0m"
GRN="\e[32m"
RED="\e[91m"
SET_BOLD="\e[1m"

start_step (){
	echo -e "$SET_BOLD$GRN"
	echo -e "----------------------------------------------------------------"
	echo -e "   $1"
	echo -e "----------------------------------------------------------------"
	echo -e "$RESET_ALL"
	cd "$THIS_DIR"
}

## save current directory for later
THIS_DIR=$(pwd)


start_step "creating some directories"
mkdir -p ~/git/
mkdir -p ~/tmp/

start_step "Setting Bookmarks"
cp -f "$THIS_DIR/files/bookmarks" ~/.config/gtk-3.0/

start_step "Copying in Bash Aliases"
cp -f "$THIS_DIR/files/aliases" ~/.bash_aliases


start_step "Removing Some Clutter"
sudo apt remove -y $TO_REMOVE
sudo apt autoremove -y


start_step "Installing tools: $TO_INSTALL"
sudo apt update
sudo apt install -y $TO_INSTALL
sudo apt autoremove -y


start_step "Installing Audio Recorder"
sudo apt-add-repository -y ppa:audio-recorder/ppa
sudo apt update
sudo apt install -y audio-recorder


start_step "Installing Sublime"
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt update
sudo apt install -y sublime-text


start_step "Installing Sublime Settings"
mkdir -p ~/.config/sublime-text/Packages/User/
cp -f $THIS_DIR/files/Preferences.sublime-settings ~/.config/sublime-text/Packages/User/


start_step "Installing mimetype list"
cp -f $THIS_DIR/files/mimeapps.list ~/.config/


start_step "Installing Signal"
cd /tmp/
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
sudo tee /etc/apt/sources.list.d/signal-xenial.list
sudo apt update
sudo apt install -y signal-desktop


start_step "Installing Docker"
cd /tmp/
# Docker instruction say to remove these but then we end up
# removing and reinstalling every time the script is run
sudo apt remove -y docker docker-engine docker.io containerd runc
sudo apt update
sudo install -m 0755 -d /etc/apt/keyrings
sudo rm -f /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin



start_step "Installing docker-compose"
sudo apt install -y docker-compose
sudo usermod -a -G docker $USER



start_step "Installing voxl-docker"
mkdir -p ~/git
cd ~/git
if [ ! -d voxl-docker ]; then
	git clone https://gitlab.com/voxl-public/voxl-docker
fi
cd voxl-docker
./install-voxl-docker-script.sh


start_step "Installing ADB"
set +e
sudo apt install -y android-tools-adb android-tools-fastboot
sudo apt install -y adb fastboot
set -e

start_step "Installing gsutil"
sudo rm -f /etc/apt/sources.list.d/google-cloud-sdk.list
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-cli


start_step "Installing youtube-dl with pip"
sudo pip3 install --upgrade youtube_dl


start_step "Installing Slack"
sudo snap install slack --classic


start_step "Final Cleanup and Update"
sudo apt upgrade -y
sudo apt autoremove -y


start_step "all done, please reboot now"


