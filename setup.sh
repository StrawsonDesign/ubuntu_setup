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
i7z
stress
net-tools
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
if [ -f /usr/bin/audio-recorder ]; then
	echo "audio-recorder already installed"
else
	sudo apt-add-repository -y ppa:audio-recorder/ppa
	sudo apt update
	sudo apt install -y audio-recorder
fi


start_step "Installing Sublime"
if [ -f /opt/sublime_text/sublime_text ]; then
	echo "sublime already installed"
else
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
	echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
	sudo apt update
	sudo apt install -y sublime-text
fi


start_step "Installing Sublime Settings"
mkdir -p ~/.config/sublime-text/Packages/User/
cp -f $THIS_DIR/files/Preferences.sublime-settings ~/.config/sublime-text/Packages/User/


start_step "Installing mimetype list"
cp -f $THIS_DIR/files/mimeapps.list ~/.config/



start_step "Installing QGroundControl"
if [ -f /usr/bin/QGroundControl.AppImage ]; then
	echo "QGroundControl already installed"
else
	sudo usermod -a -G dialout $USER
	sudo apt-get remove -y modemmanager -y
	sudo apt install -y gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl libqt5gui5 libfuse2
	cd ~/Desktop
	wget https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl.AppImage
	chmod +x QGroundControl.AppImage
fi



start_step "Installing Signal"
if [ -f /usr/bin/signal-desktop ]; then
	echo "signal already installed"
else
	cd /tmp/
	wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
	cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
	echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
	sudo tee /etc/apt/sources.list.d/signal-xenial.list
	sudo apt update
	sudo apt install -y signal-desktop
fi


start_step "Installing Docker"
if [ -f /usr/bin/docker ]; then
	echo "docker already installed"
else
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
fi


start_step "Installing docker-compose"
if [ -f /usr/bin/docker-compose ]; then
	echo "docker-compose already installed"
else
	sudo apt install -y docker-compose
	sudo usermod -a -G docker $USER
fi


start_step "Installing voxl-docker"
mkdir -p ~/git
cd ~/git
if [ ! -d voxl-docker ]; then
	git clone https://gitlab.com/voxl-public/voxl-docker
fi
cd voxl-docker
./install-voxl-docker-script.sh


start_step "Installing ADB"
if [ -f /usr/bin/adb ]; then
	echo "adb already installed"
else
	set +e
	sudo apt install -y android-tools-adb android-tools-fastboot
	sudo apt install -y adb fastboot
	set -e
fi

start_step "Installing gsutil"
if [ -f /usr/bin/gsutil ]; then
	echo "gsutil already installed"
else
	sudo rm -f /etc/apt/sources.list.d/google-cloud-sdk.list
	echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
	sudo apt-get update && sudo apt-get install google-cloud-cli
fi

start_step "Installing youtube-dl with pip"
if [ -f /usr/local/bin/youtube-dl ]; then
	echo "youtube-dl already installed"
else
	sudo pip3 install --upgrade youtube_dl
fi


start_step "Installing Slack"
if [ -f /usr/bin/slack ]; then
	echo "slack already installed"
else
	sudo snap install slack --classic
fi


start_step "Final Cleanup and Update"
sudo apt upgrade -y
sudo apt autoremove -y


start_step "all done, please reboot now"


