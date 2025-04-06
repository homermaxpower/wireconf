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

create_wireguard_server_config() {
    echo "Creating a WireGuard server configuration..."
    
    # Detect a public IP address and ask to confirm or change it
    echo "Detecting your public IP address..."
    PUBLIC_IP=$(curl -4 -sSL ifconfig.me)
    echo "Your public IP address is [$PUBLIC_IP]: "
    # shellcheck disable=SC2162
    read user_input
    if [ "$user_input" != "" ]; then
        PUBLIC_IP=$user_input
    fi
    
    # Selecting a port for the WireGuard server (default: 51820)
    SERVER_PORT=51820
    echo "WireGuard server port [51820]: "
    # shellcheck disable=SC2162
    read user_input
    if [ "$user_input" != "" ]; then
        SERVER_PORT=$user_input
    fi
    
    # Selecting a DNS server for the WireGuard server with options
    RIGHT_CHOICE=true
    while [ "$RIGHT_CHOICE" = false ]; do
        echo "Select a DNS server for the WireGuard server [1. System default]: "
        echo "1. System default"
        printf "\n"
        echo "2. Cloudflare"
        printf "\n"
        echo "3. Quad9"
        printf "\n"
        echo "4. AdGuard"
        printf "\n"
        echo "5. Custom"
        printf "\n"
        echo "> "
        # shellcheck disable=SC2162
        read user_input
        case "$user_input" in
            "1" | "")
                DNS_SERVER=$(cat /etc/resolv.conf | grep -E -o "([0-9]{1,3}\.){3}[0-9]{1,3}" | head -n 1)
                ;;
            "2")
                DNS_SERVER="1.0.0.1"
                ;;
            "3")
                DNS_SERVER="9.9.9.9"
                ;;
            "4")
                DNS_SERVER="176.103.130.130"
                ;;
            "5")
                printf "\nEnter a custom DNS server: "
                # shellcheck disable=SC2162
                read user_input
                DNS_SERVER=$user_input
                ;;
            *)
                echo "Invalid option"
                RIGHT_CHOICE=false
                ;;
        esac
    done
}

create_wireguard_peer_config() {
    echo "Creating a WireGuard peer to peer configuration..."
}

# Create WireGuard configuration
create_wireguard_config() {
    if ! check_wireguard_installed; then
        echo "WireGuard is not installed"
        install_wireguard
    fi
    
    # Select a type of WireGuard configuration
    echo "Select a type of WireGuard configuration:"
    printf "\n"
    echo "1. Server"
    printf "\n"
    echo "2. Peer to Peer"
    printf "\n"
    echo "3. Exit"
    printf "\n"
    # shellcheck disable=SC2162
    read user_input
    case "$user_input" in
        "1")
            create_wireguard_server_config
            ;;
        "2")
            create_wireguard_peer_config
            ;;
    esac
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