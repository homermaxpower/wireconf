#!/bin/sh

# WireConf Menu Text
MENU_TEXT=$(cat << 'EOF'
     _  _  _ _             ______             ___
    | || || (_)           / _____)           / __)
    | || || |_  ____ ____| /      ___  ____ | |__
    | ||_|| | |/ ___) _  ) |     / _ \|  _ \|  __)
    | |___| | | |  ( (/ /| \____| |_| | | | | |
    \_______|_|_|  \____)\______)___/ |_| |_|_|

  -------------------------------------------------

  WireGuard Configuration Shell Script
  (installation, configuration, user management)

  Type "help" for more information.

EOF
)

# Help Menu Text
HELP_TEXT=$(cat << 'EOF'

 Command:    Description:
 install     Install WireGuard
 delete      Delete WireGuard
 help        Show this help menu
 exit        Exit the script

EOF
)

# Installations for different distros
install_debian() {
    echo "Installing WireGuard"
    apt-get update
    apt-get install -y wireguard resolvconf
}

install_centos() {
    echo "Installing WireGuard"
    yum update -y
    yum install -y wireguard-tools resolvconf
}

install_fedora() {
    echo "Installing WireGuard"
    dnf update -y
    dnf install -y wireguard-tools resolvconf
}

install_arch() {
    echo "Installing WireGuard"
    pacman -Sy --noconfirm wireguard-tools resolvconf
}

# Install WireGuard based on the distribution
install_wireguard() {
    case "$DISTRO" in
        "debian")
            install_debian
            ;;
        "ubuntu")
            install_debian
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

delete_wireguard() {
    echo "Are you sure you want to delete WireGuard? This action cannot be undone. Type 'yes' to confirm."
    read -p "Type 'yes' to confirm: " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Operation cancelled."
        return 1
    fi
    echo "Removing WireGuard"
    case "$DISTRO" in
        "debian" | "ubuntu")
            apt-get purge -y wireguard resolvconf
            apt-get autoremove -y
            ;;
        "centos")
            yum remove -y wireguard-tools resolvconf
            yum autoremove -y
            ;;
        "fedora")
            dnf remove -y wireguard-tools resolvconf
            dnf autoremove -y
            ;;
        "arch")
            pacman -Rns --noconfirm wireguard-tools resolvconf
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            return 1
            ;;
    esac
}

user_input=""

printf "%s" "$MENU_TEXT"

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
    printf "> "
    # shellcheck disable=SC2162
    read user_input
    
    case "$user_input" in
        "install")
            install_wireguard
            ;;
        "delete")
            delete_wireguard
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