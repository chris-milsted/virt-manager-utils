#Kickstart template for Ubuntu
#Platform: x86-64
#
# Customized for Server 18.04 minimal physical sever install
#
# See README.mkd for usage

# Load the minimal server preseed off cdrom
preseed preseed/file string /cdrom/preseed/ubuntu-server-minimal.seed

# I noticed a difference between 'ubuntu-server-minimal' and
# 'ubuntu-server-minimalvm' is the non-vm one omits the following lines.
# Well the 'standard' task installs silly things like a full 'bind9' server
# for caching dns.  Recommended to use a server that is designed just as a
# caching dns server like 'unbound' or 'pdns-recursor'
preseed --owner tasksel tasksel/skip-tasks string standard

# OPTIONAL: Change hostname from default 'preseed'
# If your DHCP hands out a hostname that will take precedence over this
# see: https://bugs.launchpad.net/ubuntu/+source/preseed/+bug/1452202
#preseed netcfg/hostname string minimal-vm

# Use local proxy
# Setup a server with apt-cacher-ng and enter that hostname here
#preseed mirror/http/proxy string http://my-local-cache:3142/

#System language
lang en_US

#Language modules to install
langsupport en_US

#System keyboard
keyboard us

#System mouse
mouse

#System timezone
timezone America/New_York

#Root password
rootpw --disabled

#Initial user (user with sudo capabilities)
user ubuntu --fullname "Ubuntu" --password ChangeMe

#Reboot after installation
reboot

#Use text mode install
text

#Install OS instead of upgrade
install

#Installation media
cdrom

#System bootloader configuration
bootloader --location=mbr

#Clear the Master Boot Record
zerombr yes

#Partition clearing information
# '--all' will give message in install log about only clearing first drive but
# this is still needed
clearpart --all --initlabel

#Advanced partition
# The last lv specified will take up the remaining space of the vg. To get
# around that add up all your disk sizes and set this value. It appears to
# factor in the size of non lvm partitions as well
preseed partman-auto-lvm/guided_size string 20480MB
part /boot --fstype=ext4 --size=512 --asprimary
part pv.1 --grow --size=1 --asprimary
volgroup vg0 pv.1
logvol / --fstype=ext4 --name=root --vgname=vg0 --size=19000MB

# Don't install recommended items by default
# This will also be set for built system at
# /etc/apt/apt.conf.d/00InstallRecommends
preseed base-installer/install-recommends boolean false

#System authorization infomation
auth --useshadow

#Network information
# If the system has a single interface the '--device' option isn't needed. If
# you do use it remember that in 18.04 the device names are different. For
# example I was seeing enp0s3 as the interface name.  I haven't tested this
# but you should be able to specify 'interface=enp0s3' as a boot paramater and
# it will be passed through to installer.  I have tested setting the device to
# 'auto' will have it automatically pick the first active interface
#network --bootproto=dhcp --device=enp0s3
network --device=auto

# This needs to be specified as boot parameters so it knows how to download
# this kickstart file but left here in case you use one network for initial
# load or something.
# Uncomment all these to use static ip
#d-i netcfg/disable_autoconfig boolean true
#d-i netcfg/get_ipaddress string 192.168.1.42
#d-i netcfg/get_netmask string 255.255.255.0
#d-i netcfg/get_gateway string 192.168.1.1
#d-i netcfg/get_nameservers string 192.168.1.1
#d-i netcfg/confirm_static boolean true

#Firewall configuration
# Not supported by ubuntu
firewall --enabled --ssh


# Policy for applying updates. May be "none" (no automatic updates),
# "unattended-upgrades" (install security updates automatically), or
# "landscape" (manage system with Landscape).
preseed pkgsel/update-policy select unattended-upgrades

#Do not configure the X Window System
skipx

%packages
vim
software-properties-common
gpg-agent
curl
openssh-server

%post --nochroot
(
    sed -i "s;quiet;quiet console=ttyS0;" /target/etc/default/grub
    sed -i "s;quiet;quiet console=ttyS0;g" /target/boot/grub/grub.cfg
) 1> /target/root/post_install.log 2>&1

echo "ubuntu        ALL=(ALL)       NOPASSWD: ALL" >> /mnt/sysimage/etc/sudoers.d/ubuntu

%end