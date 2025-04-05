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

 COMMAND:    DESCRIPTION:
 install     Install WireGuard
 uninstall   Uninstall WireGuard
 help        Show this help menu
 exit        Exit the script

EOF
)

# Get system distribution
if [ -f /etc/os-release ]; then
    DISTRO=$(grep -w ID /etc/os-release | cut -d= -f2)
else
    echo "Distribution cannot be identified"
    exit 1
fi

# Detect if root or normal user
if [ "$(id -u)" -ne 0 ]; then
    ROOT_USER=false
else
    ROOT_USER=true
fi

# Install WireGuard based on the distribution
install_wireguard() {
    echo "Installing WireGuard packages for $DISTRO"
    case "$DISTRO" in
        "debian" | "ubuntu")
            if [ "$ROOT_USER" = false ]; then
                sudo apt-get update
                sudo apt-get install -y wireguard resolvconf
            else
                apt-get update
                apt-get install -y wireguard resolvconf
            fi
            ;;
        "centos")
            if [ "$ROOT_USER" = false ]; then
                sudo yum update -y
                sudo yum install -y wireguard-tools resolvconf
            else
                yum update -y
                yum install -y wireguard-tools resolvconf
            fi
            ;;
        "fedora")
            if [ "$ROOT_USER" = false ]; then
                sudo dnf update -y
                sudo dnf install -y wireguard-tools resolvconf
            else
                dnf update -y
                dnf install -y wireguard-tools resolvconf
            fi
            ;;
        "arch")
            if [ "$ROOT_USER" = false ]; then
                sudo pacman -Sy --noconfirm wireguard-tools resolvconf
            else
                pacman -Sy --noconfirm wireguard-tools resolvconf
            fi
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            return 1
            ;;
    esac
}

uninstall_wireguard() {
    echo "Are you sure you want to uninstall WireGuard? This action cannot be undone."
    printf "Type 'yes' to confirm: "
    # shellcheck disable=SC2162
    read confirm
    if [ "$confirm" != "yes" ]; then
        echo "Operation cancelled."
        return 1
    fi
    echo "Uninstalling WireGuard packages"
    case "$DISTRO" in
        "debian" | "ubuntu")
            if [ "$ROOT_USER" = false ]; then
                sudo apt-get purge -y wireguard resolvconf
                sudo apt-get autoremove -y
            else
                apt-get purge -y wireguard resolvconf
                apt-get autoremove -y
            fi
            ;;
        "centos")
            if [ "$ROOT_USER" = false ]; then
                sudo yum remove -y wireguard-tools resolvconf
                sudo yum autoremove -y
            else
                yum remove -y wireguard-tools resolvconf
                yum autoremove -y
            fi
            ;;
        "fedora")
            if [ "$ROOT_USER" = false ]; then
                sudo dnf remove -y wireguard-tools resolvconf
                sudo dnf autoremove -y
            else
                dnf remove -y wireguard-tools resolvconf
                dnf autoremove -y
            fi
            ;;
        "arch")
            if [ "$ROOT_USER" = false ]; then
                sudo pacman -Rns --noconfirm wireguard-tools resolvconf
            else
                pacman -Rns --noconfirm wireguard-tools resolvconf
            fi
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            return 1
            ;;
    esac
}

# Check if WireGuard is installed
check_wireguard_installed() {
    if [ -f /usr/bin/wg ]; then
        return 0
    elif [ -f /bin/wg ]; then
        return 0
    else
        return 1
    fi
}

# Create WireGuard configuration
create_wireguard_config() {
    if ! check_wireguard_installed; then
        echo "WireGuard is not installed"
        install_wireguard
    fi
}

user_input=""

echo "$MENU_TEXT"
printf "\n"

# Main loop
while [ "$user_input" != "exit" ]; do
    printf "> "
    # shellcheck disable=SC2162
    read user_input
    
    case "$user_input" in
        "install")
            install_wireguard
            ;;
        "uninstall")
            uninstall_wireguard
            ;;
        "create")
            create_wireguard_config
            ;;
        "help")
            echo "$HELP_TEXT"
            printf "\n"
            ;;
        "exit")
            echo "Goodbye!"
            printf "\n"
            exit 0
            ;;
        *)
            echo "Unknown command. Type 'help' for available commands."
            printf "\n"
            ;;
    esac
done

# Exit
exit 0