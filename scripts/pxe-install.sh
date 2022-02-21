#!/bin/bash

mkdir /var/isos && cd /var/isos
scp dsgarcia@10.0.1.1:/home/dsgarcia/Documents/isos/{oel79.iso,oel85.iso} /var/isos/
yum install dhcp-server tftp-server vsftpd syslinux -y
mkdir /var/ftp/pub/ks && cd /var/ftp/pub/ks
scp dsgarcia@10.0.1.1:/home/dsgarcia/Documents/ks/{oel7_stig.ks,oel8_stig.ks} ./
cat >> /etc/dhcp/dhcpd.conf << EOF
#DHCP configuration for PXE boot server
ddns-update-style interim;
ignore client-updates;
authoritative;
allow booting;
allow bootp;
allow unknown-clients;
subnet 10.0.1.0
netmask 255.255.255.0
{
range 10.0.1.20 10.0.1.200;
option domain-name-servers 10.0.1.2;
option domain-name "thedanagarcia.com";
option routers 10.0.1.1;
option broadcast-address 10.0.1.255;
default-lease-time 600;
max-lease-time 7200;
#PXE boot server
next-server 10.0.1.2;
filename "pxelinux.0";
}
EOF
sed -i 's/anonymous_enable=NO/anonymous_enable=YES/g' /etc/vsftpd/vsftpd.conf
sed -i 's/write_enable=YES/write_enable=NO/g' /etc/vsftpd/vsftpd.conf
systemctl start dhcpd.service && systemctl enable dhcpd.service
systemctl start tftp.service && systemctl enable tftp.service
systemctl enable vsftpd.service && systemctl start vsftpd.service
firewall-cmd --permanent --zone=public --add-service={dhcp,proxy-dhcp,tftp,ftp}
firewall-cmd --reload
cp -v /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
cp -v /usr/share/syslinux/menu.c32 /var/lib/tftpboot/
cp -v /usr/share/syslinux/mboot.c32 /var/lib/tftpboot/
cp -v /usr/share/syslinux/chain.c32 /var/lib/tftpboot/
cp -v /usr/share/syslinux/ldlinux.c32 /var/lib/tftpboot/
cp -v /usr/share/syslinux/libutil.c32 /var/lib/tftpboot/
cp -v /usr/share/syslinux/libcom32.c32 /var/lib/tftpboot/
mkdir /var/lib/tftpboot/pxelinux.cfg
mkdir -p /var/lib/tftpboot/networkboot/oel7
mkdir -p /var/lib/tftpboot/networkboot/oel8
mkdir /var/ftp/pub/oel7
mkdir /var/ftp/pub/oel8
mkdir /iso_image/oel7
mkdir /iso_image/oel8
mount -o loop /isos/oel79.iso /iso_image/oel7
mount -o loop /isos/oel85.iso /iso_image/oel8
cp -rf /iso_image/oel7/* /var/ftp/pub/oel7
cp -rf /iso_image/oel8/* /var/ftp/pub/oel8
cp /var/ftp/pub/oel7/images/pxeboot/{initrd.img,vmlinuz} /var/lib/tftpboot/networkboot/oel7/
cp /var/ftp/pub/oel8/images/pxeboot/{initrd.img,vmlinuz} /var/lib/tftpboot/networkboot/oel8/
cat >> /var/lib/tftpboot/pxelinux.cfg/default << EOF
default menu.c32
prompt 0
timeout 30
menu title OCI ONSR PXE Menu

label Install Oracle Linux 7.9 - STIG
kernel /networkboot/oel7/vmlinuz
append initrd=/networkboot/oel7/initrd.img inst.repo=ftp://10.0.1.2/pub/oel7 inst.ks=ftp://10.0.1.2/pub/ks/oel7_stig.ks

label Install Oracle Linux 8.5 - STIG
kernel /networkboot/oel8/vmlinuz
append initrd=/networkboot/oel8/initrd.img inst.repo=ftp://10.0.1.2/pub/oel8 inst.ks=ftp://10.0.1.2/pub/ks/oel8_stig.ks
EOF
chmod 777 -R /var/lib/tftpboot
chmod 777 -R /var/ftp
chcon -R -t tftpdir_rw_t /var/lib/tftpboot
chcon -R -t public_content_t /var/ftp
umount /iso_image/oel7
umount /iso_image/oel8