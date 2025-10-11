#! /bin/bash
echo "Software Install Script for Ubuntu 25.10"

idx=0

# main option selection
print_options()
{
	echo "1: Express Install (Recommended)"
	echo "2: Uninstall redundant software"
	echo "3: Install software"
	echo "5: Configure system files"
	echo "6: Install games"
	echo "7: Check for software updates"
	echo "8: Exit"
}

# main option selection
select_option()
{
	echo "Please enter your option:"
	read INDEX

	case $INDEX in
		1) express_install ;;
		2) uninstall_software ;;
		3) install_software ;;
		4) configure_system ;;
		5) install_games ;;
		6) check_for_updates ;;
		7) exit ;;

		*) echo "INVALID NUMBER!" ;;
	esac
}

# uninstalls redundant software
uninstall_software()
{
	echo "Uninstalling not needed software..."
	sudo apt-get --purge remove -y rhythmbox rhythmbox-data librhythmbox-core10 remmina
	snap remove thunderbird

	# removes packages that were installed by other packages and are no longer needed
	sudo apt -y autoremove	

	check_process_exit
}

# installs software from default repository
install_software()
{
	echo "Installing software..."

	# install browser
	echo deb [arch=amd64 signed-by=/usr/share/keyrings/yandex.gpg] http://repo.yandex.ru/yandex-browser/deb stable main | sudo tee /etc/apt/sources.list.d/yandex-stable.list
	sudo wget -O- https://repo.yandex.ru/yandex-browser/YANDEX-BROWSER-KEY.GPG | gpg --dearmor | sudo tee /usr/share/keyrings/yandex.gpg
	sudo apt update
	sudo apt install -y yandex-browser-stable
	
	# install other software
	snap install keepassxc telegram-desktop discord steam remmina xournalpp
	snap install --classic sublime-text
	sudo apt install -y guake vlc bleachbit gimp vim curl ffmpeg timeshift obs-studio \
		gnome-shell-extension-manager easytag unrar simple-scan virtualbox \
		darktable rawtherapee

	# libfuse2t64: 			install FUSE to export a virtual filesystem to linux kernel (for e.g. AppImage)
	# v4l2loopback-dkms: 	virtual camera support
	sudo apt install -y libfuse2t64 v4l2loopback-dkms

	echo "Installing development software..."
	sudo apt install -y git openjdk-21-jdk adb
	# required for go compiling
	sudo apt install -y gcc-aarch64-linux-gnu
	# Install Docker
	sudo apt install -y docker.io docker-compose
	sudo usermod -a -G docker $USER
	# Install IDEs
	snap install --classic code
	snap install --classic intellij-idea-community
	
	check_process_exit
}

# configures development setup
configure_system()
{
	echo "Configuring development setup..."
	echo "Setting /etc/hosts..."
	echo '127.0.0.1 database' | sudo tee -a /etc/hosts
	echo '192.168.178.22 rickiekarp.net' | sudo tee -a /etc/hosts
	echo '192.168.178.22 api.rickiekarp.net' | sudo tee -a /etc/hosts
	echo '192.168.178.22 git.rickiekarp.net' | sudo tee -a /etc/hosts
	echo '192.168.178.22 cloud.rickiekarp.net' | sudo tee -a /etc/hosts
	echo '192.168.178.22 files.rickiekarp.net' | sudo tee -a /etc/hosts
	echo '192.168.178.22 test.rickiekarp.net' | sudo tee -a /etc/hosts

	echo "Setting desktop shortcuts..."
	cat >/home/rickie/.local/share/applications/shapass.desktop <<EOL
#!/usr/bin/env xdg-open
[Desktop Entry]
Type=Application
Name=SHAPass
Exec="/home/rickie/Programs/shapass/bin/shapass" %U
Categories=Application;
EOL

	check_process_exit
}

# installs games from default repository
install_games()
{
	echo "Installing games..."
	sudo apt install -y warzone2100 warzone2100-music

	check_process_exit
}

# easy install function
express_install()
{
	read -r -p "This option will execute all other listed functions. Continue? [y/n]" response
	case $response in 
	   [yY][eE][sS]|[yY]) 
		let idx=1
		uninstall_software
		check_for_updates
		install_software
		configure_system
		echo "DONE!"
	        ;;
	   *)
		echo "Exiting..."
		process_exit
 	       ;;
	esac
}

# checks the system for updates and installs them
check_for_updates()
{
	echo "Checking for software updates..."
	sudo apt-get update && sudo apt-get -y upgrade
}

# checks $idx variable
# if idx != 1, exit the program
check_process_exit()
{
	if [[ $idx -ne 1 ]]; then
		process_exit
	fi
}

# program exit selection
process_exit()
{
	read -r -p "Do you want to do something else? [y/n]" response
	case $response in 
	   [yY][eE][sS]|[yY]) 
		let idx=0
		print_options
		select_option
	        ;;
	   *)
		echo "DONE!"
 	       ;;
	esac
}

print_options
select_option
