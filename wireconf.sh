#!/bin/bash

# WireConf Menu Text
MENU_TEXT=$(cat << 'EOF'
     _  _  _ _             ______             ___
    | || || (_)           / _____)           / __)
    | || || |_  ____ ____| /      ___  ____ | |__
    | ||_|| | |/ ___) _  ) |     / _ \|  _ \|  __)
    | |___| | | |  ( (/ /| \____| |_| | | | | |
    \_______|_|_|  \____)\______)___/ |_| |_|_|

  -------------------------------------------------

  WireGuard Configuration BASH Script for Debian
  (installation, configuration, user management)

  Type "help" for more information.

EOF
)

# Help Menu Text
HELP_TEXT=$(cat << 'EOF'

 Command:    Description:
 install     Install WireGuard
 help        Show this help menu
 exit        Exit the script

EOF
)

# Installations for different distros
install_debian() {
    echo "Installing WireGuard on Debian"
}

install_ubuntu() {
    echo "Installing WireGuard on Ubuntu"
}

install_centos() {
    echo "Installing WireGuard on CentOS"
}

install_fedora() {
    echo "Installing WireGuard on Fedora"
}

install_arch() {
    echo "Installing WireGuard on Arch"
}

# Install WireGuard based on the distribution
install_wireguard() {
    case "$DISTRO" in
        "debian")
            install_debian
            ;;
        "ubuntu")
            install_ubuntu
            ;;
        "centos")
            install_centos
            ;;
        "fedora")
            install_fedora
            ;;
        "arch")
            install_arch
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            return 1
            ;;
    esac
}

user_input=""

echo -n "$MENU_TEXT"

# Get system distribution
if [ -f /etc/os-release ]; then
    DISTRO=$(grep -w ID /etc/os-release | cut -d= -f2)
    echo "$DISTRO"
else
    echo "Distribution cannot be identified"
    exit 1
fi

# Main loop
while [ "$user_input" != "exit" ]; do
    # shellcheck disable=SC2162
    read -p "> " user_input
    
    case "$user_input" in
        "install")
            install_wireguard
            ;;
        "help")
            echo "$HELP_TEXT"
            ;;
        "exit")
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Unknown command. Type 'help' for available commands."
            ;;
    esac
done

# Exit
exit 0