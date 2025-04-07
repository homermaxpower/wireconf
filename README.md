# WireConf
WireGuard CLI configuration tool / Shell script

Script manages: **installation/uninstallation** of neccessary packages; Creation and deletion of **WireGuard configuration files**;  Creation and deletion of **users** belonging to specific WireGuard configurations;

Script uses package manager from each of the supported distributions to install packages.

**Script can be run as root**. If not run as root it will need either **sudo** or **doas** to do it's job during installation, creating configuration files and creating and adding clients to the server.

## Licence
GNU GENERAL PUBLIC LICENSE version 2

## Supported Distributions
1. Debian
2. Ubuntu
3. CentOS
4. Fedora
5. Arch

## Usage

### Running the script
```shell
git clone https://github.com/homermaxpower/wireconf.git && ./wireconf/wireconf.sh
```

### Commands
**Command** | **Description**
--------|------------
install | Install WireGuard
uninstall | Uninstall WireGuard
create | Create new WireGuard configuration
delete | Select and delete WireGuard configuration
list | List WireGuard configurations
user | Create/Delete a user for selected configuration
userqr | Generate and display QR code for client configuration
users | Display all users for selected configuration
help | Show help menu
exit | Exit the script

### Workaround for unsupported distributions
**Workaround in the begginning of the script:**
```shell
# If running on unsupported distribution, set this to true and
# uncomment the following line and set the DISTRO variable to distro closest to your distribution.
# Also you can skip the install step by installing wireguard, resolvconf and qrencode manually
# and the script will detect that the wg, resolvconf and qrencode commands are available
UNSUPPORTED_DISTRO=false
#DISTRO="debian"
```