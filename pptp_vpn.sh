#!/bin/bash
[ $(id -u) != "0" ] && { echo -e "\033[31mError: You must be root to run this script\033[0m"; exit 1; } 

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#    适用于CentOS / RedHat 5+ Debian 6+和Ubuntu 12+的LNMP / LAMP / LANMP  等系统  #
#            CentOS安装PPTP VPN专用系统               #
#             QQ     28423999078                               #
#######################################################################
"

[ ! -e '/usr/bin/curl' ] && yum -y install curl

VPN_IP=`curl ipv4.icanhazip.com`

VPN_USER="linuxeye"
VPN_PASS="linuxeye"

VPN_LOCAL="192.168.0.150"
VPN_REMOTE="192.168.0.151-200"


while :; do echo
    read -p "设置用户名: " VPN_USER 
    [ -n "$VPN_USER" ] && break
done

while :; do echo
    read -p "设置密码: " VPN_PASS
    [ -n "$VPN_PASS" ] && break
done
clear


if [ -f /etc/redhat-release -a -n "`grep ' 7\.' /etc/redhat-release`" ];then
    #CentOS_REL=7
    if [ ! -e /etc/yum.repos.d/epel.repo ];then
        cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux 7 - \$basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/\$basearch
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=\$basearch
failovermethod=priority
enabled=1
gpgcheck=0
EOF
    fi
    for Package in wget make openssl gcc-c++ ppp pptpd iptables iptables-services 
    do
        yum -y install $Package
    done
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
elif [ -f /etc/redhat-release -a -n "`grep ' 6\.' /etc/redhat-release`" ];then
    #CentOS_REL=6
    for Package in wget make openssl gcc-c++ iptables ppp 
    do
        yum -y install $Package
    done
    sed -i 's@net.ipv4.ip_forward.*@net.ipv4.ip_forward = 1@g' /etc/sysctl.conf
    rpm -Uvh http://poptop.sourceforge.net/yum/stable/rhel6/pptp-release-current.noarch.rpm
    yum -y install pptpd
else
    echo -e "\033[31mDoes not support this OS, Please contact the author! \033[0m"
    exit 1
fi

echo "1" > /proc/sys/net/ipv4/ip_forward

sysctl -p /etc/sysctl.conf

[ -z "`grep '^localip' /etc/pptpd.conf`" ] && echo "localip $VPN_LOCAL" >> /etc/pptpd.conf # Local IP address of your VPN server
[ -z "`grep '^remoteip' /etc/pptpd.conf`" ] && echo "remoteip $VPN_REMOTE" >> /etc/pptpd.conf # Scope for your home network
[ -z "`grep '^stimeout' /etc/pptpd.conf`" ] && echo "stimeout 172800" >> /etc/pptpd.conf

if [ -z "`grep '^ms-dns' /etc/ppp/options.pptpd`" ];then
     cat >> /etc/ppp/options.pptpd << EOF
ms-dns 223.5.5.5 # Aliyun DNS Primary
ms-dns 114.114.114.114 # 114 DNS Primary
ms-dns 8.8.8.8 # Google DNS Primary
ms-dns 209.244.0.3 # Level3 Primary
ms-dns 208.67.222.222 # OpenDNS Primary
EOF
fi

echo "$VPN_USER pptpd $VPN_PASS *" >> /etc/ppp/chap-secrets

ETH=`route | grep default | awk '{print $NF}'`
[ -z "`grep '1723 -j ACCEPT' /etc/sysconfig/iptables`" ] && iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport 1723 -j ACCEPT
[ -z "`grep 'gre -j ACCEPT' /etc/sysconfig/iptables`" ] && iptables -I INPUT 5 -p gre -j ACCEPT 
iptables -t nat -A POSTROUTING -o $ETH -j MASQUERADE
iptables -I FORWARD -p tcp --syn -i ppp+ -j TCPMSS --set-mss 1356
service iptables save
sed -i 's@^-A INPUT -j REJECT --reject-with icmp-host-prohibited@#-A INPUT -j REJECT --reject-with icmp-host-prohibited@' /etc/sysconfig/iptables 
sed -i 's@^-A FORWARD -j REJECT --reject-with icmp-host-prohibited@#-A FORWARD -j REJECT --reject-with icmp-host-prohibited@' /etc/sysconfig/iptables 
service iptables restart
chkconfig iptables on

service pptpd restart
chkconfig pptpd on
clear

echo -e "请务必开启PPP加密"
echo -e "您现在可以连接VPN 了\033[32m${VPN_IP}\033[0m"

echo -e "用户名: \033[32m${VPN_USER}\033[0m"
echo -e "密码: \033[32m${VPN_PASS}\033[0m"