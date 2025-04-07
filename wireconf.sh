#!/bin/sh

# Supported distributions:
# - debian
# - ubuntu
# - centos
# - fedora
# - arch

# If running on unsupported distribution, set this to true and
# uncomment the following line and set the DISTRO variable to distro closest to your distribution.
# Also you can skip the install step by installing wireguard, resolvconf and qrencode manually
# and the script will detect that the wg, resolvconf and qrencode commands are available
UNSUPPORTED_DISTRO=false
#DISTRO="debian"

# Check if the distribution is supported
SUPPORTED_DISTROS="debian ubuntu centos fedora arch"
if ! UNSUPPORTED_DISTRO; then
    if ! echo "$SUPPORTED_DISTROS" | grep -q "$DISTRO"; then
        echo "Unsupported distribution: $DISTRO"
        exit 1
    fi
fi

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
 create      Create a WireGuard configuration
 delete      Delete a WireGuard configuration
 list        List all WireGuard configurations
 user        Manage WireGuard users
 userqr      Generate and display QR code for client configuration
 users       List all WireGuard users
 help        Show this help menu
 exit        Exit the script

EOF
)

# Get system distribution
if [ "$UNSUPPORTED_DISTRO" = false ]; then
    if [ -f /etc/os-release ]; then
        DISTRO=$(grep -w ID /etc/os-release | cut -d= -f2)
        echo "Distribution: $DISTRO" # REMOVE LATER
    else
        echo "Distribution cannot be identified"
        exit 1
    fi
fi

# Detect if root
if [ "$(id -u)" -ne 0 ]; then
    ROOT_USER=false
else
    ROOT_USER=true
fi
echo "Root user: $ROOT_USER" # REMOVE LATER

# Detect if sudo is present
SUDO_PRESENT=true
if ! command -v sudo &> /dev/null; then
    SUDO_PRESENT=false
fi
echo "Sudo present: $SUDO_PRESENT" # REMOVE LATER

# Detect if doas is present
DOAS_PRESENT=true
if ! command -v doas &> /dev/null; then
    DOAS_PRESENT=false
fi
echo "Doas present: $DOAS_PRESENT" # REMOVE LATER

# Detect if wireguard is installed
if ! command -v wg &> /dev/null; then
    WIREGUARD_INSTALLED=false
else
    WIREGUARD_INSTALLED=true
fi
echo "WireGuard installed: $WIREGUARD_INSTALLED" # REMOVE LATER

# Detect if resolvconf is installed
if ! command -v resolvconf &> /dev/null; then
    RESOLVCONF_INSTALLED=false
else
    RESOLVCONF_INSTALLED=true
fi
echo "Resolvconf installed: $RESOLVCONF_INSTALLED" # REMOVE LATER

# Detect if qrencode is installed
if ! command -v qrencode &> /dev/null; then
    QRCODE_INSTALLED=false
else
    QRCODE_INSTALLED=true
fi
echo "Qrencode installed: $QRCODE_INSTALLED" # REMOVE LATER

# REMOVE LATER
printf "\n"

# Install WireGuard based on the distribution
install_wireguard() {
    echo "Installing WireGuard packages for $DISTRO"
    case "$DISTRO" in
        "debian" | "ubuntu")
            if [ "$ROOT_USER" = false ]; then
                if [ "$SUDO_PRESENT" = true ]; then
                    sudo apt-get update
                    if ! WIREGUARD_INSTALLED; then
                        sudo apt-get install -y wireguard
                    fi
                    if ! RESOLVCONF_INSTALLED; then
                        sudo apt-get install -y resolvconf
                    fi
                    if ! QRCODE_INSTALLED; then
                        sudo apt-get install -y qrencode
                    fi
                    sudo apt-get autoremove -y
                elif [ "$DOAS_PRESENT" = true ]; then
                    doas apt-get update
                    if ! WIREGUARD_INSTALLED; then
                        doas apt-get install -y wireguard
                    fi
                    if ! RESOLVCONF_INSTALLED; then
                        doas apt-get install -y resolvconf
                    fi
                    if ! QRCODE_INSTALLED; then
                        doas apt-get install -y qrencode
                    fi
                    doas apt-get autoremove -y
                fi
            else
                apt-get update
                if ! WIREGUARD_INSTALLED; then
                    apt-get install -y wireguard
                fi
                if ! RESOLVCONF_INSTALLED; then
                    apt-get install -y resolvconf
                fi
                if ! QRCODE_INSTALLED; then
                    apt-get install -y qrencode
                fi
                apt-get autoremove -y
            fi
            ;;
        "centos")
            if [ "$ROOT_USER" = false ]; then
                if [ "$SUDO_PRESENT" = true ]; then
                    sudo yum update -y
                    if ! WIREGUARD_INSTALLED; then
                        sudo yum install -y wireguard-tools
                    fi
                    if ! RESOLVCONF_INSTALLED; then
                        sudo yum install -y resolvconf
                    fi
                    if ! QRCODE_INSTALLED; then
                        sudo yum install -y qrencode
                    fi
                elif [ "$DOAS_PRESENT" = true ]; then
                    doas yum update -y
                    if ! WIREGUARD_INSTALLED; then
                        doas yum install -y wireguard-tools
                    fi
                    if ! RESOLVCONF_INSTALLED; then
                        doas yum install -y resolvconf
                    fi
                    if ! QRCODE_INSTALLED; then
                        doas yum install -y qrencode
                    fi
                fi
            else
                yum update -y
                if ! WIREGUARD_INSTALLED; then
                    yum install -y wireguard-tools
                fi
                if ! RESOLVCONF_INSTALLED; then
                    yum install -y resolvconf
                fi
                if ! QRCODE_INSTALLED; then
                    yum install -y qrencode
                fi
            fi
            ;;
        "fedora")
            if [ "$ROOT_USER" = false ]; then
                if [ "$SUDO_PRESENT" = true ]; then
                    sudo dnf update -y
                    if ! WIREGUARD_INSTALLED; then
                        sudo dnf install -y wireguard-tools
                    fi
                    if ! RESOLVCONF_INSTALLED; then
                        sudo dnf install -y resolvconf
                    fi
                    if ! QRCODE_INSTALLED; then
                        sudo dnf install -y qrencode
                    fi
                fi
            else
                dnf update -y
                if ! WIREGUARD_INSTALLED; then
                    dnf install -y wireguard-tools
                fi
                if ! RESOLVCONF_INSTALLED; then
                    dnf install -y resolvconf
                fi
                if ! QRCODE_INSTALLED; then
                    dnf install -y qrencode
                fi
            fi
            ;;
        "arch")
            if [ "$ROOT_USER" = false ]; then
                if [ "$SUDO_PRESENT" = true ]; then
                    if ! WIREGUARD_INSTALLED; then
                        sudo pacman -Sy --noconfirm wireguard-tools
                    fi
                    if ! RESOLVCONF_INSTALLED; then
                        sudo pacman -Sy --noconfirm resolvconf
                    fi
                    if ! QRCODE_INSTALLED; then
                        sudo pacman -Sy --noconfirm qrencode
                    fi
                elif [ "$DOAS_PRESENT" = true ]; then
                    if ! WIREGUARD_INSTALLED; then
                        doas pacman -Sy --noconfirm wireguard-tools
                    fi
                    if ! RESOLVCONF_INSTALLED; then
                        doas pacman -Sy --noconfirm resolvconf
                    fi
                    if ! QRCODE_INSTALLED; then
                        doas pacman -Sy --noconfirm qrencode
                    fi
                fi
            else
                if ! WIREGUARD_INSTALLED; then
                    pacman -Sy --noconfirm wireguard-tools
                fi
                if ! RESOLVCONF_INSTALLED; then
                    pacman -Sy --noconfirm resolvconf
                fi
                if ! QRCODE_INSTALLED; then
                    pacman -Sy --noconfirm qrencode
                fi
            fi
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            return 1
            ;;
    esac
}

uninstall_wireguard() {
    echo "Are you sure you want to uninstall WireGuard (wireguard, resolvconf, qrencode)? This action cannot be undone."
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
                if [ "$SUDO_PRESENT" = true ]; then
                    if WIREGUARD_INSTALLED; then
                        sudo apt-get remove -y wireguard
                    fi
                    if RESOLVCONF_INSTALLED; then
                        sudo apt-get remove -y resolvconf
                    fi
                    if QRCODE_INSTALLED; then
                        sudo apt-get remove -y qrencode
                    fi
                    sudo apt-get autoremove -y
                elif [ "$DOAS_PRESENT" = true ]; then
                    if WIREGUARD_INSTALLED; then
                        doas apt-get remove -y wireguard
                    fi
                    if RESOLVCONF_INSTALLED; then
                        doas apt-get remove -y resolvconf
                    fi
                    if QRCODE_INSTALLED; then
                        doas apt-get remove -y qrencode
                    fi
                    doas apt-get autoremove -y
                fi
            else
                if WIREGUARD_INSTALLED; then
                    apt-get remove -y wireguard
                fi
                if RESOLVCONF_INSTALLED; then
                    apt-get remove -y resolvconf
                fi
                if QRCODE_INSTALLED; then
                    apt-get remove -y qrencode
                fi
                apt-get autoremove -y
            fi
            ;;
        "centos")
            if [ "$ROOT_USER" = false ]; then
                if [ "$SUDO_PRESENT" = true ]; then
                    if WIREGUARD_INSTALLED; then
                        sudo yum remove -y wireguard-tools
                    fi
                    if RESOLVCONF_INSTALLED; then
                        sudo yum remove -y resolvconf
                    fi
                    if QRCODE_INSTALLED; then
                        sudo yum remove -y qrencode
                    fi
                    sudo yum autoremove -y
                elif [ "$DOAS_PRESENT" = true ]; then
                    if WIREGUARD_INSTALLED; then
                        doas yum remove -y wireguard-tools
                    fi
                    if RESOLVCONF_INSTALLED; then
                        doas yum remove -y resolvconf
                    fi
                    if QRCODE_INSTALLED; then
                        doas yum remove -y qrencode
                    fi
                    doas yum autoremove -y
                fi
            else
                if WIREGUARD_INSTALLED; then
                    yum remove -y wireguard-tools
                fi
                if RESOLVCONF_INSTALLED; then
                    yum remove -y resolvconf
                fi
                if QRCODE_INSTALLED; then
                    yum remove -y qrencode
                fi
                yum autoremove -y
            fi
            ;;
        "fedora")
            if [ "$ROOT_USER" = false ]; then
                if [ "$SUDO_PRESENT" = true ]; then
                    if WIREGUARD_INSTALLED; then
                        sudo dnf remove -y wireguard-tools
                    fi
                    if RESOLVCONF_INSTALLED; then
                        sudo dnf remove -y resolvconf
                    fi
                    if QRCODE_INSTALLED; then
                        sudo dnf remove -y qrencode
                    fi
                    sudo dnf autoremove -y
                elif [ "$DOAS_PRESENT" = true ]; then
                    doas dnf update
                    if WIREGUARD_INSTALLED; then
                        doas dnf remove -y wireguard-tools
                    fi
                    if RESOLVCONF_INSTALLED; then
                        doas dnf remove -y resolvconf
                    fi
                    if QRCODE_INSTALLED; then
                        doas dnf remove -y qrencode
                    fi
                    doas dnf autoremove -y
                fi
            else
                if WIREGUARD_INSTALLED; then
                    dnf remove -y wireguard-tools
                fi
                if RESOLVCONF_INSTALLED; then
                    dnf remove -y resolvconf
                fi
                if QRCODE_INSTALLED; then
                    dnf remove -y qrencode
                fi
                dnf autoremove -y
            fi
            ;;
        "arch")
            if [ "$ROOT_USER" = false ]; then
                if [ "$SUDO_PRESENT" = true ]; then
                    if WIREGUARD_INSTALLED; then
                        sudo pacman -Rns --noconfirm wireguard-tools
                    fi
                    if RESOLVCONF_INSTALLED; then
                        sudo pacman -Rns --noconfirm resolvconf
                    fi
                    if QRCODE_INSTALLED; then
                        sudo pacman -Rns --noconfirm qrencode
                    fi
                elif [ "$DOAS_PRESENT" = true ]; then
                    if WIREGUARD_INSTALLED; then
                        doas pacman -Rns --noconfirm wireguard-tools
                    fi
                    if RESOLVCONF_INSTALLED; then
                        doas pacman -Rns --noconfirm resolvconf
                    fi
                    if QRCODE_INSTALLED; then
                        doas pacman -Rns --noconfirm qrencode
                    fi
                fi
            else
                if WIREGUARD_INSTALLED; then
                    pacman -Rns --noconfirm wireguard-tools
                fi
                if RESOLVCONF_INSTALLED; then
                    pacman -Rns --noconfirm resolvconf
                fi
                if QRCODE_INSTALLED; then
                    pacman -Rns --noconfirm qrencode
                fi
            fi
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            return 1
            ;;
    esac
}

# Generate and display QR code for client configuration
generate_and_display_qr_code() {
    echo "PASS"
    printf "\n"
}



# Create WireGuard configuration
create_wireguard_config() {
    if ! check_wireguard_installed; then
        echo "WireGuard is not installed"
        install_wireguard
    fi
    
    echo "Creating a WireGuard configuration..."
    
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
    CORRECT_ANSWER=true
    while [ "$CORRECT_ANSWER" = false ]; do
        echo "Select a DNS server for the WireGuard server [1. System default]: "
        echo "1. System default"
        echo "2. Cloudflare"
        echo "3. Quad9"
        echo "4. AdGuard"
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
                CORRECT_ANSWER=false
                ;;
        esac
    done
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
        "delete")
            delete_wireguard_config
            ;;
        "list")
            list_wireguard_configs
            ;;
        "user")
            manage_wireguard_users
            ;;
        "userqr")
            generate_and_display_qr_code
            ;;
        "users")
            list_wireguard_users
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