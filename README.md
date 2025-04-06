# WireConf
WireGuard CLI configuration tool / Shell script

Script manages **installation/uninstallation** of wireguard and resolvconf packages; Creation and deletion of **WireGuard configuration files**;  Creation and deletion of **users** belonging to specific WireGuard configurations of type server; Creating peer to peer WireGuard connections.

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
```bash
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
users | Display all users for selected configuration
help | Show help menu
exit | Exit the script